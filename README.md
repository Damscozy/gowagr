# Gowagr Mobile Engineer Assessment

# Gowagr Events Feature

This module implements the **Events / History** screen for the Gowagr mobile application, built using **Flutter**, **Riverpod**, and a clean, type-safe API integration.

---

## 📌 Features

- **Event Listing**
  - Fetches live event data from the backend API
  - Supports pagination with infinite scroll
  - Pull-to-refresh functionality

- **Search**
  - Search events by keyword in real time

- **Category Filtering**
  - Categories implemented via an `enum EventCategory` for type safety
  - API mapping for each category
  - Dynamic UI with icons and active/inactive state styles

- **Event Cards**
  - Displays market info, prices, and trade counts
  - Currency-aware (`₦` or `$`) based on `SupportedCurrency`
  - “Buy Yes” and “Buy No” buttons with color-coded styling

---

## 🏗 Architecture

The feature follows a **Clean Architecture inspired with MVVM flavor** using Riverpod Notifiers for state management:

```dart
lib/
│
├── core/                     → App-wide configs, utilities, logging, Hive storage
│
├── data/                     → Data & domain layer
│   ├── impl/                 → Repository/API implementations
│   ├── model/                → Entity & DTO models (Event, Market, etc.)
│   ├── repo/                 → Repository contracts (interfaces)
│   ├── notifier/             → Riverpod Notifiers (state + business logic)
│   └── state/                → Immutable state classes
│
├── presentation/             → UI layer
│   ├── components/           → Reusable UI widgets (EventCard, ActionButton, etc.)
│   ├── widgets/              → Feature-specific widgets (CategorySelector, SearchBar, etc.)
│   └── event_screen.dart     → Feature screen composition
```
## 🏗 Folder Structure

```dart
assets/
 └── svgs/
      ├── favourite.svg
      ├── logo.svg
      ├── trades.svg
      ├── trending.svg
      └── watchlist.svg

lib/
 ├── core/
 │    ├── config/         # App-wide configuration (theme, constants, local storage)
 │    ├── services/       # External & internal services (API, logging)
 │    └── utils/          # Utility extensions & helper functions
 │
 ├── data/
 │    ├── impl/           # Implementation of repositories (e.g., Event API calls)
 │    │     └── event_impl.dart
 │    ├── model/          # Data models
 │    │     └── event_model.dart
 │    ├── notifier/       # Riverpod notifiers for state management
 │    │     └── event_notifier.dart
 │    ├── repo/           # Repository contracts/interfaces
 │    │     └── event_repo.dart
 │    └── state/          # State classes
 │          └── event_state.dart
 │
 ├── presentation/
 │    ├── components/     # UI components/widgets
 │    │     ├── action_tab.dart
 │    │     ├── event_card.dart
 │    │     └── tab_item.dart
 │    ├── widgets/        # Composite widgets (UI building blocks)
 │    │     └── events_widgets.dart
 │    ├── event_screen.dart  # Event listing screen
 │    └── gowagr.dart        # App root widget
 │
 ├── main.dart            # App entry point
 ```
---

## 🔌 API Integration

### Repository
The repository is responsible for calling the API:

```dart
@override
Future<ApiResponse> fetchPublicEvents({
  required Map<String, dynamic> queryParameters,
}) {
  return apiService.getData(
    Endpoints.eventsUrl,
    queryParameters: queryParameters,
  );
}
```


### ViewModel
The ViewModel builds query parameters from the current state:

```dart
final queryParams = {
  'page': page.toString(),
  'size': '10',
  if (state.searchQuery.isNotEmpty) 'keyword': state.searchQuery,
  if (!selectedCategory.isTrending && selectedCategory.apiParam != null)
    'category': selectedCategory.apiParam,
  if (selectedCategory.isTrending) 'trending': 'true',
};

final res = await _repo.fetchPublicEvents(queryParameters: queryParams);

Pagination merges data when loadMore: true.
```
⸻

🎯 Category Enum

```dart
enum EventCategory {
  trending("Trending", "assets/svgs/trending.svg"),
  watchlist("Watchlist", "assets/svgs/watchlist.svg"),
  entertainment("Entertainment 🎶", null),
  sports("Sports ⚽️", null);

  final String label;
  final String? iconPath;

  const EventCategory(this.label, this.iconPath);

  String? get apiParam {
    switch (this) {
      case EventCategory.trending:
        return null;
      case EventCategory.watchlist:
        return "watchlist";
      case EventCategory.entertainment:
        return "entertainment";
      case EventCategory.sports:
        return "sports";
    }
  }

  bool get isTrending => this == EventCategory.trending;
}
```
⸻

💾 Local Storage (HiveStorage)

This project uses Hive as a lightweight local database to cache events, store watchlists, and securely save authentication data.
HiveStorage is a central utility class that handles all local persistence needs.

⸻

Features
	•	Encrypted Data Storage
	•	Uses AES encryption with a fixed 16-character key/IV to store sensitive data securely.
	•	Ensures cached event data cannot be read directly from disk.
	•	Watchlist Management
	•	Allows adding/removing events from a user’s watchlist.
	•	Persists the watchlist between sessions.
	•	Provides helper functions to check if an event is in the watchlist.
	•	Event Caching
	•	Stores the latest fetched events locally in encrypted form.
	•	Ensures offline access to the most recent event data.
	•	Prevents unnecessary API calls by checking if the cache is already up-to-date (cacheEventsIfFresh).
	•	Access Token Storage
	•	Securely stores and retrieves the user’s authentication token.

⸻

Stored Keys

Key	Purpose
_accessTokenKey	Stores the user’s authentication token
_watchlistKey	Stores a list of event IDs that are in the watchlist
_cachedEventsKey	Stores encrypted JSON of the latest fetched events


⸻

Key Methods

🔹 Authentication

HiveStorage.accessToken;        // Get token
HiveStorage.accessToken = "token"; // Set token

🔹 Watchlist

await HiveStorage.toggleWatchlist(eventId); // Add/remove from watchlist
bool isInWatchlist = await HiveStorage.isInWatchlist(eventId); // Check
Set<String> watchlist = await HiveStorage.getWatchlist(); // Get all watchlist IDs

🔹 Event Caching

// Save events
await HiveStorage.saveEventsModel(eventsModel);

// Retrieve cached events
EventsModel? cachedEvents = HiveStorage.getCachedEventsModel();

// Save only if new data is different from cache
await HiveStorage.cacheEventsIfFresh(newEventsModel);

🔹 Clear All Data

await HiveStorage.clearAllData();

⸻

Usage in App
	•	When fetching events:
	•	API data is saved locally via cacheEventsIfFresh.
	•	If offline, the UI loads getCachedEventsModel().
	•	When toggling watchlist:
	•	Updates both the in-memory state and local Hive storage.
	•	When switching to the “Watchlist” tab:
	•	Loads only events whose IDs match the locally stored watchlist.

⸻

🖼 UI Components

Category Selector

Dynamic category chips with icon + label and active styling.

Event Card

Reusable widget displaying:
	•	Event image & title
	•	Buy Yes / Buy No buttons
	•	Trade counts and closing date

⸻

🔄 Pagination & Refresh
	•	Infinite Scroll: Loads more events when the user scrolls near the bottom.
	•	Pull-to-Refresh: Resets pagination and fetches the latest events.

⸻

🚀 How to Run
	1.	Install dependencies:

flutter pub get

	flutter pub get

flutter run

	flutter run

⸻

📌 Notes
	•	The feature uses Riverpod’s NotifierProvider for managing state.
	•	All API calls go through a shared ApiService with logging & error handling.
	•	Currency display is automatically determined by the event’s supported currencies list.

⸻

📄 License

This feature is part of the Adedamola Gowagr Mobile Application (Engineer Assessment) and is proprietary code.
Do not copy or distribute without permission.

---
