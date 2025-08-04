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

The feature follows a **MVVM-like structure** using Riverpod Notifiers for state management:


data/              → API repository layer
models/            → Event & Market models
notifier/          → EventViewModel with fetch logic
presentation/      → EventScreen UI
components & widgets/           → EventCard, category selector, etc.


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

	2.	Run the app:

flutter run

	3.	Select the Events tab to see the history feature in action.

```bash
flutter pub get
flutter run
```

⸻

📌 Notes
	•	The feature uses Riverpod’s NotifierProvider for managing state.
	•	All API calls go through a shared ApiService with logging & error handling.
	•	Currency display is automatically determined by the event’s supported currencies list.

⸻

📄 License

This feature is part of the Gowagr mobile application and is proprietary code.
Do not copy or distribute without permission.

---
