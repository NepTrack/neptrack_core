/// Base exception for all NepTrack API errors.
class NeptrackException implements Exception {
  final String message;
  final int? statusCode;
  NeptrackException(this.message, {this.statusCode});
  @override
  String toString() =>
      'NeptrackException(${statusCode ?? '-'}): $message';
}

/// 401 — missing/invalid/expired/revoked token.
class NeptrackAuthException extends NeptrackException {
  NeptrackAuthException(super.message) : super(statusCode: 401);
}

/// 403 — token lacks the required scope.
class NeptrackScopeException extends NeptrackException {
  NeptrackScopeException(super.message) : super(statusCode: 403);
}

/// 429 — rate-limited.
class NeptrackRateLimitException extends NeptrackException {
  NeptrackRateLimitException(super.message) : super(statusCode: 429);
}

/// Application-level error (HTTP 200 but `err: true` in the body).
class NeptrackApiException extends NeptrackException {
  NeptrackApiException(super.message) : super(statusCode: 200);
}
