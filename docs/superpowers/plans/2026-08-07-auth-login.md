# Auth / Login System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Phone + OTP login in osooli-app wired to the Laravel API, with splash auto-login, placeholder home, clean architecture and GetX.

**Architecture:** Clean architecture per feature (`domain` → `data` → `presentation`), GetX for state/DI/navigation. `ApiClient` (http) and `TokenStorage` (flutter_secure_storage) are permanent singletons registered in an `InitialBinding`; each route has its own binding.

**Tech Stack:** Flutter, GetX (`get`), `http`, `flutter_secure_storage`, `pinput`.

## Global Constraints

- Base URL: `http://10.0.2.2:8000/api/v1` — single const `ApiClient.baseUrl`.
- Headers always: `Accept: application/json`, `Accept-Language: ar`; plus `Content-Type: application/json` on writes and `Authorization: Bearer <token>` when a token exists.
- Response envelope: success `{data: …}`; error `{message, errors?}`.
- Test OTP is `6666`; OTP length constant = 4 (`AuthConstants.otpLength`), server accepts 4–6.
- All UI strings via GetX translations (`'key'.tr`), Arabic + English.
- Brand: primary navy `#062A5B`, accent `#00775A`, error `#A8321F`, ground `#FEFEFE`, radius 40 buttons, Tajawal font.
- On 401 from any authed call: wipe storage, `Get.offAllNamed(Routes.login)`.
- Run tests with `flutter test`, static check with `flutter analyze` (use FVM if `fvm` is on PATH: `fvm flutter …`).

---

### Task 1: Packages + core error type

**Files:**
- Modify: `pubspec.yaml` (add `flutter_secure_storage: ^9.2.2`, `pinput: ^5.0.0`)
- Create: `lib/core/errors/api_exception.dart`
- Test: `test/core/api_exception_test.dart`

**Interfaces:**
- Produces: `ApiException implements Exception { final int? statusCode; final String message; final Map<String, List<String>> fieldErrors; String? firstError(String field); }` and factory `ApiException.fromResponse(int statusCode, Map<String, dynamic>? body)`.

- [ ] **Step 1: Add packages**

In `pubspec.yaml` dependencies add:

```yaml
  flutter_secure_storage: ^9.2.2
  pinput: ^5.0.0
```

Run: `flutter pub get` — expect success.

- [ ] **Step 2: Write failing test**

```dart
// test/core/api_exception_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:osooliapp/core/errors/api_exception.dart';

void main() {
  test('fromResponse reads message and field errors', () {
    final e = ApiException.fromResponse(422, {
      'message': 'Invalid verification code',
      'errors': {
        'otp': ['Invalid verification code']
      },
    });
    expect(e.statusCode, 422);
    expect(e.message, 'Invalid verification code');
    expect(e.firstError('otp'), 'Invalid verification code');
    expect(e.firstError('phone'), isNull);
  });

  test('fromResponse falls back to generic message key', () {
    final e = ApiException.fromResponse(500, null);
    expect(e.message, 'error_server');
  });
}
```

- [ ] **Step 3: Run test, verify it fails** (`flutter test test/core/api_exception_test.dart`)

- [ ] **Step 4: Implement**

```dart
// lib/core/errors/api_exception.dart
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  final Map<String, List<String>> fieldErrors;

  const ApiException({
    this.statusCode,
    required this.message,
    this.fieldErrors = const {},
  });

  factory ApiException.fromResponse(int statusCode, Map<String, dynamic>? body) {
    final errors = <String, List<String>>{};
    final raw = body?['errors'];
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is List) {
          errors['$key'] = value.map((e) => '$e').toList();
        }
      });
    }
    final message = body?['message'] as String? ?? _fallbackFor(statusCode);
    return ApiException(
      statusCode: statusCode,
      message: message,
      fieldErrors: errors,
    );
  }

  const ApiException.network()
      : statusCode = null,
        message = 'error_network',
        fieldErrors = const {};

  static String _fallbackFor(int statusCode) {
    switch (statusCode) {
      case 429:
        return 'error_rate_limited';
      case 401:
        return 'error_unauthorized';
      default:
        return 'error_server';
    }
  }

  String? firstError(String field) {
    final list = fieldErrors[field];
    return (list == null || list.isEmpty) ? null : list.first;
  }

  @override
  String toString() => 'ApiException($statusCode, $message)';
}
```

Note: `message` may be either server-provided Arabic text or a translation key (`error_*`). UI layers call `.tr` on it — for non-key strings `.tr` returns the string unchanged, so both cases render correctly.

- [ ] **Step 5: Run test, verify pass; commit** — `git add -A && git commit -m "feat(core): ApiException with field errors"`

---

### Task 2: TokenStorage

**Files:**
- Create: `lib/core/storage/token_storage.dart`

**Interfaces:**
- Produces: `class TokenStorage { Future<void> saveSession({required String token, required Map<String, dynamic> ownerJson}); Future<String?> get token; Future<Map<String, dynamic>?> get ownerJson; Future<void> clear(); }`

- [ ] **Step 1: Implement** (thin wrapper over a plugin — no unit test; covered by analyze)

```dart
// lib/core/storage/token_storage.dart
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _ownerKey = 'auth_owner';

  final FlutterSecureStorage _storage;

  TokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveSession({
    required String token,
    required Map<String, dynamic> ownerJson,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _ownerKey, value: jsonEncode(ownerJson));
  }

  Future<String?> get token => _storage.read(key: _tokenKey);

  Future<Map<String, dynamic>?> get ownerJson async {
    final raw = await _storage.read(key: _ownerKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _ownerKey);
  }
}
```

- [ ] **Step 2: `flutter analyze` clean; commit** — `git commit -am "feat(core): secure TokenStorage"`

---

### Task 3: ApiClient

**Files:**
- Create: `lib/core/network/api_client.dart`
- Test: `test/core/api_client_test.dart`

**Interfaces:**
- Consumes: `TokenStorage.token`, `ApiException`.
- Produces: `class ApiClient { ApiClient({required TokenStorage tokenStorage, http.Client? httpClient, void Function()? onUnauthorized}); Future<Map<String, dynamic>> get(String path); Future<Map<String, dynamic>> post(String path, {Map<String, dynamic>? body, bool authorized = true}); }` — returns the decoded JSON map (the full envelope), throws `ApiException` on non-2xx or network failure.

- [ ] **Step 1: Write failing tests** (use `http.testing.MockClient`)

```dart
// test/core/api_client_test.dart
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:osooliapp/core/errors/api_exception.dart';
import 'package:osooliapp/core/network/api_client.dart';
import 'package:osooliapp/core/storage/token_storage.dart';

class FakeTokenStorage implements TokenStorage {
  String? stored;
  FakeTokenStorage([this.stored]);
  @override
  Future<String?> get token async => stored;
  @override
  Future<Map<String, dynamic>?> get ownerJson async => null;
  @override
  Future<void> saveSession({required String token, required Map<String, dynamic> ownerJson}) async {}
  @override
  Future<void> clear() async => stored = null;
}

void main() {
  test('post sends json body and returns decoded envelope', () async {
    late http.Request captured;
    final client = ApiClient(
      tokenStorage: FakeTokenStorage(),
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({'data': {'message': 'ok', 'expires_in': 300}}),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final result =
        await client.post('/auth/request-otp', body: {'phone': '0511111111'}, authorized: false);

    expect(captured.url.toString(), '${ApiClient.baseUrl}/auth/request-otp');
    expect(captured.headers['Accept-Language'], 'ar');
    expect(captured.headers.containsKey('Authorization'), isFalse);
    expect(jsonDecode(captured.body)['phone'], '0511111111');
    expect(result['data']['expires_in'], 300);
  });

  test('attaches bearer token when authorized', () async {
    late http.Request captured;
    final client = ApiClient(
      tokenStorage: FakeTokenStorage('17|abc'),
      httpClient: MockClient((request) async {
        captured = request;
        return http.Response(jsonEncode({'data': {}}), 200);
      }),
    );

    await client.get('/me');
    expect(captured.headers['Authorization'], 'Bearer 17|abc');
  });

  test('throws ApiException with body on 422', () async {
    final client = ApiClient(
      tokenStorage: FakeTokenStorage(),
      httpClient: MockClient((request) async => http.Response(
            jsonEncode({
              'message': 'Invalid verification code',
              'errors': {'otp': ['Invalid verification code']}
            }),
            422,
          )),
    );

    expect(
      () => client.post('/auth/verify-otp', body: {}, authorized: false),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 422)
          .having((e) => e.firstError('otp'), 'otp error', 'Invalid verification code')),
    );
  });

  test('fires onUnauthorized on 401', () async {
    var fired = false;
    final client = ApiClient(
      tokenStorage: FakeTokenStorage('17|abc'),
      onUnauthorized: () => fired = true,
      httpClient: MockClient(
          (request) async => http.Response(jsonEncode({'message': 'Unauthenticated.'}), 401)),
    );

    await expectLater(() => client.get('/me'), throwsA(isA<ApiException>()));
    expect(fired, isTrue);
  });
}
```

- [ ] **Step 2: Run tests, verify fail**

- [ ] **Step 3: Implement**

```dart
// lib/core/network/api_client.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../errors/api_exception.dart';
import '../storage/token_storage.dart';

class ApiClient {
  static const baseUrl = 'http://10.0.2.2:8000/api/v1';
  static const _timeout = Duration(seconds: 20);

  final TokenStorage _tokenStorage;
  final http.Client _http;
  final void Function()? onUnauthorized;

  ApiClient({
    required TokenStorage tokenStorage,
    http.Client? httpClient,
    this.onUnauthorized,
  })  : _tokenStorage = tokenStorage,
        _http = httpClient ?? http.Client();

  Future<Map<String, dynamic>> get(String path) => _send('GET', path);

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authorized = true,
  }) =>
      _send('POST', path, body: body, authorized: authorized);

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authorized = true,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Accept-Language': 'ar',
    };
    if (body != null) headers['Content-Type'] = 'application/json';
    if (authorized) {
      final token = await _tokenStorage.token;
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }

    http.Response response;
    try {
      final uri = Uri.parse('$baseUrl$path');
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      response =
          await http.Response.fromStream(await _http.send(request).timeout(_timeout));
    } on SocketException {
      throw const ApiException.network();
    } on TimeoutException {
      throw const ApiException.network();
    } on http.ClientException {
      throw const ApiException.network();
    }

    Map<String, dynamic>? decoded;
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      } on FormatException {
        decoded = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded ?? const {};
    }

    if (response.statusCode == 401) onUnauthorized?.call();
    throw ApiException.fromResponse(response.statusCode, decoded);
  }
}
```

- [ ] **Step 4: Run tests, verify pass; commit** — `git commit -am "feat(core): ApiClient with auth headers and error mapping"`

---

### Task 4: Auth domain layer

**Files:**
- Create: `lib/features/auth/domain/entities/owner.dart`
- Create: `lib/features/auth/domain/repositories/auth_repository.dart`
- Create: `lib/features/auth/domain/usecases/request_otp.dart`
- Create: `lib/features/auth/domain/usecases/verify_otp.dart`
- Create: `lib/features/auth/domain/usecases/logout.dart`

**Interfaces:**
- Produces:
  - `class Owner { final int id; final String name; final String nationalId; final String phone; final String? email; }`
  - `abstract class AuthRepository { Future<int> requestOtp(String phone); Future<Owner> verifyOtp({required String phone, required String otp}); Future<void> logout(); Future<Owner?> savedOwner(); Future<bool> hasSession(); }` — `requestOtp` returns `expires_in` seconds.
  - Usecases are thin callables: `RequestOtp(this.repository); Future<int> call(String phone)`, `VerifyOtp… Future<Owner> call({required String phone, required String otp})`, `Logout… Future<void> call()`.

- [ ] **Step 1: Implement** (pure declarations — no tests of their own; exercised via repository tests)

```dart
// lib/features/auth/domain/entities/owner.dart
class Owner {
  final int id;
  final String name;
  final String nationalId;
  final String phone;
  final String? email;

  const Owner({
    required this.id,
    required this.name,
    required this.nationalId,
    required this.phone,
    this.email,
  });
}
```

```dart
// lib/features/auth/domain/repositories/auth_repository.dart
import '../entities/owner.dart';

abstract class AuthRepository {
  /// Returns the OTP expiry in seconds.
  Future<int> requestOtp(String phone);

  /// Verifies the code, persists the session, returns the owner.
  Future<Owner> verifyOtp({required String phone, required String otp});

  /// Revokes the token server-side (best effort) and clears local session.
  Future<void> logout();

  Future<Owner?> savedOwner();

  Future<bool> hasSession();
}
```

```dart
// lib/features/auth/domain/usecases/request_otp.dart
import '../repositories/auth_repository.dart';

class RequestOtp {
  final AuthRepository repository;
  const RequestOtp(this.repository);

  Future<int> call(String phone) => repository.requestOtp(phone);
}
```

```dart
// lib/features/auth/domain/usecases/verify_otp.dart
import '../entities/owner.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp {
  final AuthRepository repository;
  const VerifyOtp(this.repository);

  Future<Owner> call({required String phone, required String otp}) =>
      repository.verifyOtp(phone: phone, otp: otp);
}
```

```dart
// lib/features/auth/domain/usecases/logout.dart
import '../repositories/auth_repository.dart';

class Logout {
  final AuthRepository repository;
  const Logout(this.repository);

  Future<void> call() => repository.logout();
}
```

- [ ] **Step 2: `flutter analyze` clean; commit** — `git commit -am "feat(auth): domain entities, repository interface, usecases"`

---

### Task 5: Auth data layer

**Files:**
- Create: `lib/features/auth/data/models/owner_model.dart`
- Create: `lib/features/auth/data/datasources/auth_remote_datasource.dart`
- Create: `lib/features/auth/data/repositories/auth_repository_impl.dart`
- Test: `test/features/auth/owner_model_test.dart`
- Test: `test/features/auth/auth_repository_impl_test.dart`

**Interfaces:**
- Consumes: `ApiClient.post/get`, `TokenStorage`, domain types from Task 4.
- Produces:
  - `class OwnerModel extends Owner { factory OwnerModel.fromJson(Map<String, dynamic> json); Map<String, dynamic> toJson(); }`
  - `class AuthRemoteDataSource { AuthRemoteDataSource(this.client); Future<int> requestOtp(String phone); Future<({String token, OwnerModel owner})> verifyOtp({required String phone, required String otp}); Future<void> logout(); }`
  - `class AuthRepositoryImpl implements AuthRepository { AuthRepositoryImpl({required AuthRemoteDataSource remote, required TokenStorage storage}); }`

- [ ] **Step 1: Write failing model test**

```dart
// test/features/auth/owner_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:osooliapp/features/auth/data/models/owner_model.dart';

void main() {
  test('fromJson/toJson round-trips', () {
    final json = {
      'id': 33,
      'name': 'محمد عبدالله الحقباني',
      'national_id': '1006272601',
      'phone': '0511111111',
      'email': null,
    };
    final model = OwnerModel.fromJson(json);
    expect(model.id, 33);
    expect(model.nationalId, '1006272601');
    expect(model.email, isNull);
    expect(model.toJson(), json);
  });
}
```

- [ ] **Step 2: Run, verify fail; implement model**

```dart
// lib/features/auth/data/models/owner_model.dart
import '../../domain/entities/owner.dart';

class OwnerModel extends Owner {
  const OwnerModel({
    required super.id,
    required super.name,
    required super.nationalId,
    required super.phone,
    super.email,
  });

  factory OwnerModel.fromJson(Map<String, dynamic> json) => OwnerModel(
        id: json['id'] as int,
        name: json['name'] as String,
        nationalId: json['national_id'] as String,
        phone: json['phone'] as String,
        email: json['email'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'national_id': nationalId,
        'phone': phone,
        'email': email,
      };
}
```

- [ ] **Step 3: Implement datasource + repository**

```dart
// lib/features/auth/data/datasources/auth_remote_datasource.dart
import '../../../../core/network/api_client.dart';
import '../models/owner_model.dart';

class AuthRemoteDataSource {
  final ApiClient client;
  const AuthRemoteDataSource(this.client);

  Future<int> requestOtp(String phone) async {
    final res = await client.post(
      '/auth/request-otp',
      body: {'phone': phone},
      authorized: false,
    );
    return (res['data']?['expires_in'] as int?) ?? 300;
  }

  Future<({String token, OwnerModel owner})> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final res = await client.post(
      '/auth/verify-otp',
      body: {'phone': phone, 'otp': otp},
      authorized: false,
    );
    final data = res['data'] as Map<String, dynamic>;
    return (
      token: data['token'] as String,
      owner: OwnerModel.fromJson(data['owner'] as Map<String, dynamic>),
    );
  }

  Future<void> logout() => client.post('/auth/logout');
}
```

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
import '../../../../core/errors/api_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/owner.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/owner_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final TokenStorage storage;

  const AuthRepositoryImpl({required this.remote, required this.storage});

  @override
  Future<int> requestOtp(String phone) => remote.requestOtp(phone);

  @override
  Future<Owner> verifyOtp({required String phone, required String otp}) async {
    final result = await remote.verifyOtp(phone: phone, otp: otp);
    await storage.saveSession(
      token: result.token,
      ownerJson: result.owner.toJson(),
    );
    return result.owner;
  }

  @override
  Future<void> logout() async {
    try {
      await remote.logout();
    } on ApiException {
      // Local sign-out must succeed even if the server call fails.
    }
    await storage.clear();
  }

  @override
  Future<Owner?> savedOwner() async {
    final json = await storage.ownerJson;
    return json == null ? null : OwnerModel.fromJson(json);
  }

  @override
  Future<bool> hasSession() async => await storage.token != null;
}
```

- [ ] **Step 4: Write failing repository test**

```dart
// test/features/auth/auth_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:osooliapp/core/errors/api_exception.dart';
import 'package:osooliapp/core/storage/token_storage.dart';
import 'package:osooliapp/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:osooliapp/features/auth/data/models/owner_model.dart';
import 'package:osooliapp/features/auth/data/repositories/auth_repository_impl.dart';

class MemoryTokenStorage implements TokenStorage {
  String? storedToken;
  Map<String, dynamic>? storedOwner;

  @override
  Future<void> saveSession({required String token, required Map<String, dynamic> ownerJson}) async {
    storedToken = token;
    storedOwner = ownerJson;
  }

  @override
  Future<String?> get token async => storedToken;

  @override
  Future<Map<String, dynamic>?> get ownerJson async => storedOwner;

  @override
  Future<void> clear() async {
    storedToken = null;
    storedOwner = null;
  }
}

const _owner = OwnerModel(
  id: 33,
  name: 'محمد',
  nationalId: '1006272601',
  phone: '0511111111',
);

class FakeRemote implements AuthRemoteDataSource {
  bool logoutThrows = false;
  bool logoutCalled = false;

  @override
  // ignore: avoid_field_initializers_in_const_classes
  get client => throw UnimplementedError();

  @override
  Future<int> requestOtp(String phone) async => 300;

  @override
  Future<({String token, OwnerModel owner})> verifyOtp(
          {required String phone, required String otp}) async =>
      (token: '17|abc', owner: _owner);

  @override
  Future<void> logout() async {
    logoutCalled = true;
    if (logoutThrows) throw const ApiException(statusCode: 500, message: 'error_server');
  }
}

void main() {
  test('verifyOtp persists token and owner', () async {
    final storage = MemoryTokenStorage();
    final repo = AuthRepositoryImpl(remote: FakeRemote(), storage: storage);

    final owner = await repo.verifyOtp(phone: '0511111111', otp: '6666');

    expect(owner.id, 33);
    expect(storage.storedToken, '17|abc');
    expect(storage.storedOwner?['national_id'], '1006272601');
    expect(await repo.hasSession(), isTrue);
    expect((await repo.savedOwner())?.name, 'محمد');
  });

  test('logout clears session even when server errors', () async {
    final storage = MemoryTokenStorage();
    final remote = FakeRemote()..logoutThrows = true;
    final repo = AuthRepositoryImpl(remote: remote, storage: storage);
    await repo.verifyOtp(phone: '0511111111', otp: '6666');

    await repo.logout();

    expect(remote.logoutCalled, isTrue);
    expect(storage.storedToken, isNull);
    expect(await repo.hasSession(), isFalse);
  });
}
```

Note: `FakeRemote` implementing a concrete class needs the `client` getter stubbed; if the analyzer complains, change `AuthRemoteDataSource` to take the field privately (`final ApiClient _client`) and expose nothing — then the fake only overrides the three methods. Prefer that: make `client` private (`_client`) in the datasource.

- [ ] **Step 5: Run all tests, verify pass; commit** — `git commit -am "feat(auth): data layer with session persistence"`

---

### Task 6: Phone validator

**Files:**
- Create: `lib/features/auth/domain/validators/phone_validator.dart`
- Test: `test/features/auth/phone_validator_test.dart`

**Interfaces:**
- Produces: `class PhoneValidator { static bool isValid(String input); static String normalize(String input); }` — `normalize` strips spaces/dashes; validity accepts `05\d{8}`, `9665\d{8}`, `+9665\d{8}`.

- [ ] **Step 1: Write failing test**

```dart
// test/features/auth/phone_validator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:osooliapp/features/auth/domain/validators/phone_validator.dart';

void main() {
  test('accepts the three server formats', () {
    expect(PhoneValidator.isValid('0511111111'), isTrue);
    expect(PhoneValidator.isValid('9665111111 11'), isTrue);
    expect(PhoneValidator.isValid('+9665-1111-1111'), isTrue);
  });

  test('rejects wrong formats', () {
    expect(PhoneValidator.isValid('051111111'), isFalse); // 9 digits
    expect(PhoneValidator.isValid('0611111111'), isFalse); // not 05
    expect(PhoneValidator.isValid('abc'), isFalse);
    expect(PhoneValidator.isValid(''), isFalse);
  });

  test('normalize strips separators', () {
    expect(PhoneValidator.normalize('+966 51 111-1111'), '+966511111111');
  });
}
```

- [ ] **Step 2: Run, verify fail; implement**

```dart
// lib/features/auth/domain/validators/phone_validator.dart
class PhoneValidator {
  static final _pattern = RegExp(r'^(05\d{8}|9665\d{8}|\+9665\d{8})$');

  static String normalize(String input) =>
      input.replaceAll(RegExp(r'[\s\-]'), '');

  static bool isValid(String input) => _pattern.hasMatch(normalize(input));
}
```

- [ ] **Step 3: Run tests, verify pass; commit** — `git commit -am "feat(auth): phone validator"`

---

### Task 7: Theme, colors, translations

**Files:**
- Modify: `lib/core/constants/app_colors.dart` (currently empty)
- Modify: `lib/core/theme/app_theme.dart` (currently empty)
- Modify: `lib/core/lang/app_translations.dart` (add auth keys)
- Modify: `lib/main.dart` (use `AppTheme.light`)

**Interfaces:**
- Produces: `AppColors.primary/.accent/.error/.ground/.textSoft`, `AppTheme.light` (ThemeData).

- [ ] **Step 1: Implement colors + theme**

```dart
// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF062A5B);
  static const accent = Color(0xFF00775A);
  static const error = Color(0xFFA8321F);
  static const ground = Color(0xFFFEFEFE);
  static const textSoft = Color(0xFF6B7A8C);
  static const fieldFill = Color(0xFFF4F6F9);
}
```

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        fontFamily: 'Tajawal',
        scaffoldBackgroundColor: AppColors.ground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          error: AppColors.error,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
            ),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.fieldFill,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.error, width: 1.2),
          ),
        ),
      );
}
```

In `lib/main.dart` replace the inline `ThemeData` with:

```dart
import 'core/theme/app_theme.dart';
// …
      theme: AppTheme.light,
```

- [ ] **Step 2: Add translation keys** — merge into both maps in `app_translations.dart`:

```dart
        // en_US additions
        'login_title': 'Welcome back',
        'login_subtitle': 'Sign in with your registered phone number',
        'phone_label': 'Phone number',
        'phone_hint': '05XXXXXXXX',
        'phone_invalid': 'Enter a valid Saudi phone number',
        'send_code': 'Send code',
        'otp_title': 'Verification code',
        'otp_subtitle': 'Enter the code sent to',
        'otp_invalid': 'Enter the complete code',
        'verify': 'Verify',
        'resend_code': 'Resend code',
        'resend_in': 'Resend in',
        'logout': 'Sign out',
        'home_welcome': 'Welcome',
        'error_network': 'Check your internet connection',
        'error_server': 'Something went wrong, try again',
        'error_rate_limited': 'Too many attempts, try again later',
        'error_unauthorized': 'Session expired, sign in again',
```

```dart
        // ar_SA additions
        'login_title': 'مرحباً بعودتك',
        'login_subtitle': 'سجّل الدخول برقم جوالك المسجل',
        'phone_label': 'رقم الجوال',
        'phone_hint': '05XXXXXXXX',
        'phone_invalid': 'أدخل رقم جوال سعودي صحيح',
        'send_code': 'إرسال الرمز',
        'otp_title': 'رمز التحقق',
        'otp_subtitle': 'أدخل الرمز المرسل إلى',
        'otp_invalid': 'أدخل الرمز كاملاً',
        'verify': 'تحقق',
        'resend_code': 'إعادة إرسال الرمز',
        'resend_in': 'إعادة الإرسال خلال',
        'logout': 'تسجيل الخروج',
        'home_welcome': 'مرحباً',
        'error_network': 'تحقق من اتصالك بالإنترنت',
        'error_server': 'حدث خطأ ما، حاول مرة أخرى',
        'error_rate_limited': 'محاولات كثيرة، حاول بعد قليل',
        'error_unauthorized': 'انتهت الجلسة، سجّل الدخول مجدداً',
```

- [ ] **Step 3: `flutter analyze` clean; commit** — `git commit -am "feat(core): theme, colors, auth translations"`

---

### Task 8: Controllers + bindings

**Files:**
- Create: `lib/features/auth/presentation/controllers/splash_controller.dart`
- Create: `lib/features/auth/presentation/controllers/login_controller.dart`
- Create: `lib/features/auth/presentation/controllers/otp_controller.dart`
- Create: `lib/features/auth/presentation/bindings/auth_binding.dart`
- Create: `lib/core/bindings/initial_binding.dart`
- Create: `lib/core/constants/auth_constants.dart`
- Test: `test/features/auth/login_controller_test.dart`
- Test: `test/features/auth/otp_controller_test.dart`

**Interfaces:**
- Consumes: usecases (Task 4), `PhoneValidator` (Task 6), `Routes` names (Task 9 adds them; declare in this task as used below).
- Produces:
  - `AuthConstants.otpLength = 4`, `AuthConstants.defaultOtpExpiry = 300`
  - `LoginController { final phoneController = TextEditingController(); RxBool isLoading; RxnString error; Future<void> submit(); }` — on success navigates `Get.toNamed(Routes.otp, arguments: {'phone': normalized, 'expiresIn': seconds})`.
  - `OtpController { RxBool isLoading; RxnString error; RxInt secondsLeft; RxBool get canResend; String otp (set via onOtpChanged); Future<void> verify(); Future<void> resend(); String get phone; }` — on success `Get.offAllNamed(Routes.home)`.
  - `SplashController.onReady` → `/home` if session else `/onboarding`.
  - `InitialBinding` registers `TokenStorage`, `ApiClient` (with 401 → clear+login), `AuthRemoteDataSource`, `AuthRepositoryImpl` as `AuthRepository` — all `permanent: true`.
  - `AuthBinding` (used by login/otp routes) registers usecases + controllers lazily.

- [ ] **Step 1: Implement constants + controllers**

```dart
// lib/core/constants/auth_constants.dart
class AuthConstants {
  static const otpLength = 4;
  static const defaultOtpExpiry = 300; // seconds
}
```

```dart
// lib/features/auth/presentation/controllers/splash_controller.dart
import 'package:get/get.dart';

import '../../../../routes/app_pages.dart';
import '../../domain/repositories/auth_repository.dart';

class SplashController extends GetxController {
  final AuthRepository repository;
  SplashController(this.repository);

  @override
  Future<void> onReady() async {
    super.onReady();
    // Brief pause so the logo is visible.
    await Future.delayed(const Duration(milliseconds: 900));
    final hasSession = await repository.hasSession();
    Get.offAllNamed(hasSession ? Routes.home : Routes.onboarding);
  }
}
```

```dart
// lib/features/auth/presentation/controllers/login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/errors/api_exception.dart';
import '../../../../routes/app_pages.dart';
import '../../domain/usecases/request_otp.dart';
import '../../domain/validators/phone_validator.dart';

class LoginController extends GetxController {
  final RequestOtp requestOtp;
  LoginController(this.requestOtp);

  final phoneController = TextEditingController();
  final isLoading = false.obs;
  final error = RxnString();

  Future<void> submit() async {
    final phone = PhoneValidator.normalize(phoneController.text);
    if (!PhoneValidator.isValid(phone)) {
      error.value = 'phone_invalid';
      return;
    }
    error.value = null;
    isLoading.value = true;
    try {
      final expiresIn = await requestOtp(phone);
      Get.toNamed(
        Routes.otp,
        arguments: {'phone': phone, 'expiresIn': expiresIn},
      );
    } on ApiException catch (e) {
      error.value = e.firstError('phone') ?? e.message;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}
```

```dart
// lib/features/auth/presentation/controllers/otp_controller.dart
import 'dart:async';

import 'package:get/get.dart';

import '../../../../core/constants/auth_constants.dart';
import '../../../../core/errors/api_exception.dart';
import '../../../../routes/app_pages.dart';
import '../../domain/usecases/request_otp.dart';
import '../../domain/usecases/verify_otp.dart';

class OtpController extends GetxController {
  final VerifyOtp verifyOtp;
  final RequestOtp requestOtp;
  OtpController({required this.verifyOtp, required this.requestOtp});

  late final String phone;
  final isLoading = false.obs;
  final error = RxnString();
  final secondsLeft = 0.obs;

  String _otp = '';
  Timer? _timer;

  bool get canResend => secondsLeft.value == 0;

  @override
  void onInit() {
    super.onInit();
    final args = (Get.arguments as Map?) ?? {};
    phone = args['phone'] as String? ?? '';
    _startCountdown(args['expiresIn'] as int? ?? AuthConstants.defaultOtpExpiry);
  }

  void _startCountdown(int seconds) {
    _timer?.cancel();
    secondsLeft.value = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsLeft.value <= 1) {
        secondsLeft.value = 0;
        t.cancel();
      } else {
        secondsLeft.value--;
      }
    });
  }

  void onOtpChanged(String value) {
    _otp = value;
    error.value = null;
    if (value.length == AuthConstants.otpLength && !isLoading.value) {
      verify();
    }
  }

  Future<void> verify() async {
    if (_otp.length < AuthConstants.otpLength) {
      error.value = 'otp_invalid';
      return;
    }
    error.value = null;
    isLoading.value = true;
    try {
      await verifyOtp(phone: phone, otp: _otp);
      Get.offAllNamed(Routes.home);
    } on ApiException catch (e) {
      error.value = e.firstError('otp') ?? e.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resend() async {
    if (!canResend || isLoading.value) return;
    error.value = null;
    try {
      final expiresIn = await requestOtp(phone);
      _startCountdown(expiresIn);
    } on ApiException catch (e) {
      error.value = e.message;
    }
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
```

```dart
// lib/core/bindings/initial_binding.dart
import 'package:get/get.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../routes/app_pages.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    final storage = TokenStorage();
    Get.put(storage, permanent: true);
    Get.put(
      ApiClient(
        tokenStorage: storage,
        onUnauthorized: () {
          storage.clear();
          Get.offAllNamed(Routes.login);
        },
      ),
      permanent: true,
    );
    Get.put<AuthRepository>(
      AuthRepositoryImpl(
        remote: AuthRemoteDataSource(Get.find<ApiClient>()),
        storage: storage,
      ),
      permanent: true,
    );
  }
}
```

```dart
// lib/features/auth/presentation/bindings/auth_binding.dart
import 'package:get/get.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/request_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import '../controllers/login_controller.dart';
import '../controllers/otp_controller.dart';
import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SplashController(Get.find<AuthRepository>()));
  }
}

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(RequestOtp(Get.find<AuthRepository>())));
  }
}

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    final repo = Get.find<AuthRepository>();
    Get.lazyPut(() => OtpController(
          verifyOtp: VerifyOtp(repo),
          requestOtp: RequestOtp(repo),
        ));
  }
}

class LogoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => Logout(Get.find<AuthRepository>()));
  }
}
```

(`LogoutBinding` is illustrative — Home's binding in Task 10 constructs `Logout` directly; remove `LogoutBinding` if unused when wiring Task 10.)

- [ ] **Step 2: Write controller tests** (usecase fakes; `Get.testMode = true`)

```dart
// test/features/auth/login_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:osooliapp/core/errors/api_exception.dart';
import 'package:osooliapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:osooliapp/features/auth/domain/entities/owner.dart';
import 'package:osooliapp/features/auth/domain/usecases/request_otp.dart';
import 'package:osooliapp/features/auth/presentation/controllers/login_controller.dart';

class StubRepo implements AuthRepository {
  Object? requestOtpError;
  String? lastPhone;

  @override
  Future<int> requestOtp(String phone) async {
    lastPhone = phone;
    if (requestOtpError != null) throw requestOtpError!;
    return 300;
  }

  @override
  Future<Owner> verifyOtp({required String phone, required String otp}) =>
      throw UnimplementedError();
  @override
  Future<void> logout() => throw UnimplementedError();
  @override
  Future<Owner?> savedOwner() async => null;
  @override
  Future<bool> hasSession() async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  test('rejects invalid phone without calling API', () async {
    final repo = StubRepo();
    final c = LoginController(RequestOtp(repo));
    c.phoneController.text = '123';

    await c.submit();

    expect(c.error.value, 'phone_invalid');
    expect(repo.lastPhone, isNull);
  });

  test('normalizes phone and surfaces API errors', () async {
    final repo = StubRepo()
      ..requestOtpError =
          const ApiException(statusCode: 404, message: 'رقم الجوال غير مسجل');
    final c = LoginController(RequestOtp(repo));
    c.phoneController.text = '05 1111 1111';

    await c.submit();

    expect(repo.lastPhone, '0511111111');
    expect(c.error.value, 'رقم الجوال غير مسجل');
    expect(c.isLoading.value, isFalse);
  });
}
```

```dart
// test/features/auth/otp_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:osooliapp/core/errors/api_exception.dart';
import 'package:osooliapp/features/auth/domain/entities/owner.dart';
import 'package:osooliapp/features/auth/domain/repositories/auth_repository.dart';
import 'package:osooliapp/features/auth/domain/usecases/request_otp.dart';
import 'package:osooliapp/features/auth/domain/usecases/verify_otp.dart';
import 'package:osooliapp/features/auth/presentation/controllers/otp_controller.dart';

class StubRepo implements AuthRepository {
  Object? verifyError;
  String? verifiedOtp;

  @override
  Future<int> requestOtp(String phone) async => 300;

  @override
  Future<Owner> verifyOtp({required String phone, required String otp}) async {
    verifiedOtp = otp;
    if (verifyError != null) throw verifyError!;
    return const Owner(
        id: 1, name: 'م', nationalId: '1', phone: '0511111111');
  }

  @override
  Future<void> logout() async {}
  @override
  Future<Owner?> savedOwner() async => null;
  @override
  Future<bool> hasSession() async => false;
}

OtpController _make(StubRepo repo) => OtpController(
      verifyOtp: VerifyOtp(repo),
      requestOtp: RequestOtp(repo),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  test('short otp sets otp_invalid without calling API', () async {
    final repo = StubRepo();
    final c = _make(repo)..onInit();

    c.onOtpChanged('66');
    await c.verify();

    expect(c.error.value, 'otp_invalid');
    expect(repo.verifiedOtp, isNull);
    c.onClose();
  });

  test('wrong code surfaces field error from 422', () async {
    final repo = StubRepo()
      ..verifyError = const ApiException(
        statusCode: 422,
        message: 'Invalid verification code',
        fieldErrors: {
          'otp': ['رمز التحقق غير صحيح']
        },
      );
    final c = _make(repo)..onInit();

    c.onOtpChanged('1234'); // auto-submits at otpLength

    await Future<void>.delayed(Duration.zero);
    expect(repo.verifiedOtp, '1234');
    expect(c.error.value, 'رمز التحقق غير صحيح');
    c.onClose();
  });
}
```

Note: `onOtpChanged` auto-verify triggers navigation on success (`Get.offAllNamed`) — with `Get.testMode = true` navigation calls are safe no-ops. Tests avoid asserting navigation.

- [ ] **Step 3: Run tests, verify pass; commit** — `git commit -am "feat(auth): controllers and bindings"`

---

### Task 9: Pages, widgets, routes

**Files:**
- Create: `lib/features/auth/presentation/pages/splash_page.dart`
- Create: `lib/features/auth/presentation/pages/login_page.dart`
- Create: `lib/features/auth/presentation/pages/otp_page.dart`
- Create: `lib/features/auth/presentation/widgets/auth_header.dart`
- Modify: `lib/routes/app_pages.dart`
- Modify: `lib/main.dart` (initialBinding)
- Modify: `lib/features/onboarding/presentation/controllers/onboarding_controller.dart:38` (use `Routes.login`)

**Interfaces:**
- Consumes: controllers/bindings (Task 8), `AppColors` (Task 7), `AuthConstants.otpLength`.
- Produces: `Routes.splash = '/splash'`, `Routes.login = '/login'`, `Routes.otp = '/otp'`, `Routes.home = '/home'` (page wired in Task 10).

- [ ] **Step 1: Implement widgets + pages**

```dart
// lib/features/auth/presentation/widgets/auth_header.dart
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image.asset('assets/images/logo.jpg', width: 140),
        ),
        const SizedBox(height: 32),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 16, color: AppColors.textSoft),
        ),
      ],
    );
  }
}
```

```dart
// lib/features/auth/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logo.jpg', width: 180),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
```

```dart
// lib/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../controllers/login_controller.dart';
import '../widgets/auth_header.dart';

class LoginPage extends GetView<LoginController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              AuthHeader(
                title: 'login_title'.tr,
                subtitle: 'login_subtitle'.tr,
              ),
              const SizedBox(height: 40),
              Text(
                'phone_label'.tr,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              Directionality(
                textDirection: TextDirection.ltr,
                child: TextField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  textAlign: TextAlign.left,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d+\s\-]')),
                  ],
                  decoration: InputDecoration(
                    hintText: 'phone_hint'.tr,
                    prefixIcon: const Icon(Icons.phone_android,
                        color: AppColors.textSoft),
                  ),
                  onSubmitted: (_) => controller.submit(),
                ),
              ),
              Obx(() {
                final error = controller.error.value;
                if (error == null) return const SizedBox(height: 28);
                return Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    error.tr,
                    style: const TextStyle(
                        color: AppColors.error, fontSize: 14),
                  ),
                );
              }),
              Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.submit,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text('send_code'.tr),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

```dart
// lib/features/auth/presentation/pages/otp_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/auth_constants.dart';
import '../controllers/otp_controller.dart';
import '../widgets/auth_header.dart';

class OtpPage extends GetView<OtpController> {
  const OtpPage({super.key});

  String _format(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final defaultPin = PinTheme(
      width: 60,
      height: 60,
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
      decoration: BoxDecoration(
        color: AppColors.fieldFill,
        borderRadius: BorderRadius.circular(16),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(
                title: 'otp_title'.tr,
                subtitle: '${'otp_subtitle'.tr} ${controller.phone}',
              ),
              const SizedBox(height: 40),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Center(
                  child: Pinput(
                    length: AuthConstants.otpLength,
                    autofocus: true,
                    defaultPinTheme: defaultPin,
                    focusedPinTheme: defaultPin.copyWith(
                      decoration: defaultPin.decoration!.copyWith(
                        border:
                            Border.all(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                    onChanged: controller.onOtpChanged,
                    onCompleted: controller.onOtpChanged,
                  ),
                ),
              ),
              Obx(() {
                final error = controller.error.value;
                if (error == null) return const SizedBox(height: 28);
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Center(
                    child: Text(
                      error.tr,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 14),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
              Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isLoading.value ? null : controller.verify,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Text('verify'.tr),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.secondsLeft.value > 0) {
                  return Center(
                    child: Text(
                      '${'resend_in'.tr} ${_format(controller.secondsLeft.value)}',
                      style: const TextStyle(color: AppColors.textSoft),
                    ),
                  );
                }
                return Center(
                  child: TextButton(
                    onPressed: controller.resend,
                    child: Text(
                      'resend_code'.tr,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Wire routes + initial binding**

```dart
// lib/routes/app_pages.dart  (full replacement)
import 'package:get/get.dart';

import '../features/auth/presentation/bindings/auth_binding.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/otp_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/home/presentation/bindings/home_binding.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/onboarding/presentation/bindings/onboarding_binding.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';

class Routes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const otp = '/otp';
  static const home = '/home';
}

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.otp,
      page: () => const OtpPage(),
      binding: OtpBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
  ];
}
```

In `lib/main.dart` add `initialBinding: InitialBinding(),` to `GetMaterialApp` (import `core/bindings/initial_binding.dart`).

In `onboarding_controller.dart` replace `Get.offAllNamed('/login')` with `Get.offAllNamed(Routes.login)` (import `../../../../routes/app_pages.dart`).

- [ ] **Step 3: `flutter analyze` clean (home files come next task — create Task 10's files before analyzing, or reorder: do Task 10 Step 1 first); commit together if needed**

---

### Task 10: Home placeholder feature

**Files:**
- Create: `lib/features/home/presentation/controllers/home_controller.dart`
- Create: `lib/features/home/presentation/bindings/home_binding.dart`
- Create: `lib/features/home/presentation/pages/home_page.dart`

**Interfaces:**
- Consumes: `AuthRepository.savedOwner/logout`, `Routes.login`, `Owner`.
- Produces: `HomeController { Rxn<Owner> owner; Future<void> signOut(); }`, `HomeBinding`, `HomePage`.

- [ ] **Step 1: Implement**

```dart
// lib/features/home/presentation/controllers/home_controller.dart
import 'package:get/get.dart';

import '../../../../features/auth/domain/entities/owner.dart';
import '../../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../../features/auth/domain/usecases/logout.dart';
import '../../../../routes/app_pages.dart';

class HomeController extends GetxController {
  final AuthRepository repository;
  final Logout logout;
  HomeController({required this.repository, required this.logout});

  final owner = Rxn<Owner>();
  final isSigningOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    repository.savedOwner().then((value) => owner.value = value);
  }

  Future<void> signOut() async {
    if (isSigningOut.value) return;
    isSigningOut.value = true;
    try {
      await logout();
      Get.offAllNamed(Routes.login);
    } finally {
      isSigningOut.value = false;
    }
  }
}
```

```dart
// lib/features/home/presentation/bindings/home_binding.dart
import 'package:get/get.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/domain/usecases/logout.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    final repo = Get.find<AuthRepository>();
    Get.lazyPut(() => HomeController(repository: repo, logout: Logout(repo)));
  }
}
```

```dart
// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Obx(
            () => IconButton(
              tooltip: 'logout'.tr,
              onPressed:
                  controller.isSigningOut.value ? null : controller.signOut,
              icon: const Icon(Icons.logout, color: AppColors.error),
            ),
          ),
        ],
      ),
      body: Center(
        child: Obx(() {
          final owner = controller.owner.value;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home_work_outlined,
                  size: 72, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                '${'home_welcome'.tr}${owner == null ? '' : '، ${owner.name}'}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
```

- [ ] **Step 2: Full verification**

Run: `flutter analyze` — expect no issues.
Run: `flutter test` — expect all tests pass (including pre-existing `widget_test.dart`; if it references the counter demo and fails, replace it with a smoke test that just pumps `MyApp` — but note `MyApp` now hits `TokenStorage` via splash; simplest is to delete the obsolete `test/widget_test.dart`).

- [ ] **Step 3: Commit** — `git commit -am "feat(auth): pages, routes, home placeholder"`

---

### Task 11: Final review pass

- [ ] Run `flutter analyze` and `flutter test` one final time — both clean.
- [ ] Manual smoke test steps (document for the user, requires running Laravel locally):
  1. `cd osooli-web && php artisan serve` (listens on 0.0.0.0:8000 if emulator can't reach: `php artisan serve --host 0.0.0.0`)
  2. `cd osooli-app && flutter run`
  3. Onboarding → login → phone `0511111111` → OTP `6666` → home shows owner name → logout returns to login.
- [ ] Commit any fixes; done.
