/// Environment configuration for API endpoints and settings
class Env {
  /// Base URL for the sync API server
  /// TODO: Replace with actual Fly.io URL when backend is deployed
  static const String apiBaseUrl = "https://snapjp.fly.dev/api";

  /// API timeout duration in seconds
  static const int apiTimeoutSeconds = 3;

  /// Enable debug logging for API calls
  static const bool debugApiCalls = true;

  /// API endpoints
  static const String pingEndpoint = "/ping";
  static const String postsEndpoint = "/posts";
  static const String srsCardsEndpoint = "/srs-cards";
  static const String reviewLogsEndpoint = "/review-logs";

  /// HTTP headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Get full URL for an endpoint
  static String getEndpointUrl(String endpoint) {
    return '$apiBaseUrl$endpoint';
  }

  /// Get ping URL
  static String get pingUrl => getEndpointUrl(pingEndpoint);

  /// Get posts URL
  static String get postsUrl => getEndpointUrl(postsEndpoint);

  /// Get SRS cards URL
  static String get srsCardsUrl => getEndpointUrl(srsCardsEndpoint);

  /// Get review logs URL
  static String get reviewLogsUrl => getEndpointUrl(reviewLogsEndpoint);
}
