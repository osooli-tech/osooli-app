# Auth / Login System — Design Spec

**Date:** 2026-08-07
**App:** osooli-app (Flutter, GetX)
**Backend:** osooli-web (Laravel) — Sukuki Owner API v1 (`/api/v1`)

## Goal

Phone + OTP login wired to the real API, built with clean architecture and GetX,
Arabic-first design consistent with the existing onboarding screens.

## Scope

- Splash screen: auto-login when a token is stored, else go to onboarding/login.
- Login screen: phone entry with client-side validation.
- OTP screen: 4–6 digit code entry, 300s countdown, resend, auto-submit.
- Placeholder Home screen showing the logged-in owner's name + logout.
- Out of scope: dashboard UI, profile editing, notifications.

## API contract (from api-reference.html)

| Endpoint | Notes |
|---|---|
| `POST /auth/request-otp` `{phone}` | 200 `{data:{message, expires_in:300}}`; 404 unregistered; 429 rate limit (5/hr) |
| `POST /auth/verify-otp` `{phone, otp}` | 200 `{data:{token, owner{id,name,national_id,phone,email}}}`; 422 invalid code |
| `POST /auth/logout` (Bearer) | 200; token revoked for this device only |

- Envelope: success `{data: …}`, error `{message, errors?}`.
- Headers: `Accept: application/json`, `Accept-Language: ar`, `Authorization: Bearer <token>` when logged in.
- Phone formats accepted by server: `05…`, `+9665…`, `9665…`. Test OTP: `6666`.
- 401 on any authed call → wipe token → back to login.

## Architecture

Clean architecture per feature, following the existing `features/<name>/presentation` layout:

```
lib/
  core/
    network/api_client.dart        # http wrapper: base URL, JSON, headers, error mapping
    errors/api_exception.dart      # typed exception with Arabic user message + field errors
    storage/token_storage.dart     # flutter_secure_storage: token + cached owner JSON
    constants/app_colors.dart      # fill existing empty file
    theme/app_theme.dart           # fill existing empty file (Material 3, Tajawal)
  features/auth/
    domain/
      entities/owner.dart
      repositories/auth_repository.dart          # abstract
      usecases/request_otp.dart | verify_otp.dart | logout.dart
    data/
      models/owner_model.dart                    # extends Owner, fromJson/toJson
      datasources/auth_remote_datasource.dart
      repositories/auth_repository_impl.dart
    presentation/
      bindings/  splash_binding, login_binding, otp_binding
      controllers/ splash_controller, login_controller, otp_controller
      pages/     splash_page, login_page, otp_page
      widgets/   phone_field, primary_button
  features/home/presentation/      # placeholder page + binding + controller (logout)
  routes/app_pages.dart            # + /splash /login /otp /home; initial = /splash
```

- DI: GetX bindings per route; `ApiClient` and `TokenStorage` registered once (permanent) in an `InitialBinding`.
- OTP screen receives the phone via `Get.arguments`.

## Packages added

- `flutter_secure_storage` — secure token storage (API doc mandates secure storage).
- `pinput` — OTP input boxes.

## Config

- Base URL const in `api_client.dart`: `http://10.0.2.2:8000/api/v1` (Android emulator → local Laravel). Single place to change.

## Validation

- Phone: regex accepting `05\d{8}`, `9665\d{8}`, `\+9665\d{8}` after stripping spaces/dashes.
- OTP: 4–6 digits.

## Error handling

- `ApiClient` maps non-2xx to `ApiException{statusCode, message, fieldErrors}` using the server's `message`/`errors` (already localized Arabic via `Accept-Language: ar`).
- Network failures (SocketException/timeout) → generic "تحقق من اتصالك بالإنترنت".
- 429 → "محاولات كثيرة، حاول بعد قليل".
- Controllers expose `RxBool isLoading` + `RxnString error`; pages render inline errors (no raw snackbar dumps).

## Design direction

- RTL Arabic-first, Tajawal font (already bundled).
- Palette: primary navy `#062A5B` (existing brand color from onboarding), accent seal green `#00775A`, ground `#FEFEFE`, error rust `#A8321F`.
- Login: logo, welcome title, subtitle, phone field (LTR digits, Saudi hint `05XXXXXXXX`), full-width rounded primary button (radius 40 to match onboarding).
- OTP: masked phone shown, pinput boxes, countdown `mm:ss`, resend enabled at 0, auto-submit on 4 digits filled; server accepts 4–6 so UI uses 4 boxes (test code 6666) — length constant in one place.
- All strings via GetX translations (ar + en).

## Testing

- Unit: phone validator; `AuthRepositoryImpl` with mocked datasource; `LoginController`/`OtpController` with mocked usecases.
- No widget/golden tests in this scope.
