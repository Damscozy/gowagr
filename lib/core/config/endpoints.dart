class Endpoints {
  Endpoints._();

  /// Base URL for the API.
  static const String baseUrl = 'https://api.gowagr.app';

  /// EVENTS URL
  static String get eventsUrl => '$baseUrl/pm/events/public-events';
}
