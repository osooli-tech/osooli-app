/// Path constants for every mobile API endpoint (relative to ApiClient.baseUrl).
class ApiEndpoints {
  static const requestOtp = '/auth/request-otp';
  static const verifyOtp = '/auth/verify-otp';
  static const logout = '/auth/logout';

  static const me = '/me';
  static const dashboard = '/dashboard';
  static const search = '/search';

  static const parcels = '/parcels';
  static const parcelsMap = '/parcels/map';
  static String parcel(int id) => '/parcels/$id';
  static String parcelDocuments(int id) => '/parcels/$id/documents';

  static const deeds = '/deeds';
  static String documentDownload(int id) => '/documents/$id/download';

  static const modificationRequests = '/modification-requests';
}
