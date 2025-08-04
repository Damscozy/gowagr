class EventsModel {
  final List<Event> events;
  final Pagination? pagination;

  EventsModel({
    this.events = const [],
    this.pagination,
  });

  EventsModel copyWith({
    List<Event>? events,
    Pagination? pagination,
  }) =>
      EventsModel(
        events: events ?? this.events,
        pagination: pagination ?? this.pagination,
      );

  factory EventsModel.fromJson(Map<String, dynamic> json) => EventsModel(
        events: (json["events"] as List? ?? [])
            .map((e) => Event.fromJson(e))
            .toList(),
        pagination: json["pagination"] != null
            ? Pagination.fromJson(json["pagination"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "events": events.map((e) => e.toJson()).toList(),
        "pagination": pagination?.toJson(),
      };
}

class Event {
  final DateTime? createdAt;
  final List<Market> markets;
  final dynamic resolvedAt;
  final String? imageUrl;
  final String? image128Url;
  final String? id;
  final String? title;
  final EventType? type;
  final String? description;
  final Category? category;
  final List<String> hashtags;
  final List<dynamic> countryCodes;
  final List<dynamic> regions;
  final Status? status;
  final DateTime? resolutionDate;
  final String? resolutionSource;
  final List<SupportedCurrency> supportedCurrencies;
  final double? totalVolume;
  final int? totalOrders;

  Event({
    this.createdAt,
    this.markets = const [],
    this.resolvedAt,
    this.imageUrl,
    this.image128Url,
    this.id,
    this.title,
    this.type,
    this.description,
    this.category,
    this.hashtags = const [],
    this.countryCodes = const [],
    this.regions = const [],
    this.status,
    this.resolutionDate,
    this.resolutionSource,
    this.supportedCurrencies = const [],
    this.totalVolume,
    this.totalOrders,
  });

  Event copyWith({
    DateTime? createdAt,
    List<Market>? markets,
    dynamic resolvedAt,
    String? imageUrl,
    String? image128Url,
    String? id,
    String? title,
    EventType? type,
    String? description,
    Category? category,
    List<String>? hashtags,
    List<dynamic>? countryCodes,
    List<dynamic>? regions,
    Status? status,
    DateTime? resolutionDate,
    String? resolutionSource,
    List<SupportedCurrency>? supportedCurrencies,
    double? totalVolume,
    int? totalOrders,
  }) =>
      Event(
        createdAt: createdAt ?? this.createdAt,
        markets: markets ?? this.markets,
        resolvedAt: resolvedAt ?? this.resolvedAt,
        imageUrl: imageUrl ?? this.imageUrl,
        image128Url: image128Url ?? this.image128Url,
        id: id ?? this.id,
        title: title ?? this.title,
        type: type ?? this.type,
        description: description ?? this.description,
        category: category ?? this.category,
        hashtags: hashtags ?? this.hashtags,
        countryCodes: countryCodes ?? this.countryCodes,
        regions: regions ?? this.regions,
        status: status ?? this.status,
        resolutionDate: resolutionDate ?? this.resolutionDate,
        resolutionSource: resolutionSource ?? this.resolutionSource,
        supportedCurrencies: supportedCurrencies ?? this.supportedCurrencies,
        totalVolume: totalVolume ?? this.totalVolume,
        totalOrders: totalOrders ?? this.totalOrders,
      );

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        createdAt: json["createdAt"] != null
            ? DateTime.parse(json["createdAt"])
            : null,
        markets: (json["markets"] as List? ?? [])
            .map((e) => Market.fromJson(e))
            .toList(),
        resolvedAt: json["resolvedAt"],
        imageUrl: json["imageUrl"],
        image128Url: json["image128Url"],
        id: json["id"],
        title: json["title"],
        type: typeValues.map[json["type"]],
        description: json["description"],
        category: categoryValues.map[json["category"]],
        hashtags: List<String>.from(json["hashtags"] ?? []),
        countryCodes: List<dynamic>.from(json["countryCodes"] ?? []),
        regions: List<dynamic>.from(json["regions"] ?? []),
        status: statusValues.map[json["status"]],
        resolutionDate: json["resolutionDate"] != null
            ? DateTime.parse(json["resolutionDate"])
            : null,
        resolutionSource: json["resolutionSource"],
        supportedCurrencies: (json["supportedCurrencies"] as List? ?? [])
            .map((e) => supportedCurrencyValues.map[e]!)
            .toList(),
        totalVolume: (json["totalVolume"] as num?)?.toDouble(),
        totalOrders: json["totalOrders"],
      );

  Map<String, dynamic> toJson() => {
        "createdAt": createdAt?.toIso8601String(),
        "markets": markets.map((e) => e.toJson()).toList(),
        "resolvedAt": resolvedAt,
        "imageUrl": imageUrl,
        "image128Url": image128Url,
        "id": id,
        "title": title,
        "type": typeValues.reverse[type],
        "description": description,
        "category": categoryValues.reverse[category],
        "hashtags": hashtags,
        "countryCodes": countryCodes,
        "regions": regions,
        "status": statusValues.reverse[status],
        "resolutionDate": resolutionDate?.toIso8601String(),
        "resolutionSource": resolutionSource,
        "supportedCurrencies": supportedCurrencies
            .map((e) => supportedCurrencyValues.reverse[e])
            .toList(),
        "totalVolume": totalVolume,
        "totalOrders": totalOrders,
      };
}

class Market {
  final String? id;
  final String? title;
  final String? rules;
  final String? imageUrl;
  final String? image128Url;
  final double? yesBuyPrice;
  final double? noBuyPrice;
  final int? yesPriceForEstimate;
  final int? noPriceForEstimate;
  final Status? status;
  final dynamic resolvedOutcome;
  final double? volumeValueYes;
  final double? volumeValueNo;
  final int? yesProfitForEstimate;
  final int? noProfitForEstimate;

  Market({
    this.id,
    this.title,
    this.rules,
    this.imageUrl,
    this.image128Url,
    this.yesBuyPrice,
    this.noBuyPrice,
    this.yesPriceForEstimate,
    this.noPriceForEstimate,
    this.status,
    this.resolvedOutcome,
    this.volumeValueYes,
    this.volumeValueNo,
    this.yesProfitForEstimate,
    this.noProfitForEstimate,
  });

  factory Market.fromJson(Map<String, dynamic> json) => Market(
        id: json["id"],
        title: json["title"],
        rules: json["rules"],
        imageUrl: json["imageUrl"],
        image128Url: json["image128Url"],
        yesBuyPrice: (json["yesBuyPrice"] as num?)?.toDouble(),
        noBuyPrice: (json["noBuyPrice"] as num?)?.toDouble(),
        yesPriceForEstimate: json["yesPriceForEstimate"],
        noPriceForEstimate: json["noPriceForEstimate"],
        status: statusValues.map[json["status"]],
        resolvedOutcome: json["resolvedOutcome"],
        volumeValueYes: (json["volumeValueYes"] as num?)?.toDouble(),
        volumeValueNo: (json["volumeValueNo"] as num?)?.toDouble(),
        yesProfitForEstimate: json["yesProfitForEstimate"],
        noProfitForEstimate: json["noProfitForEstimate"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "rules": rules,
        "imageUrl": imageUrl,
        "image128Url": image128Url,
        "yesBuyPrice": yesBuyPrice,
        "noBuyPrice": noBuyPrice,
        "yesPriceForEstimate": yesPriceForEstimate,
        "noPriceForEstimate": noPriceForEstimate,
        "status": statusValues.reverse[status],
        "resolvedOutcome": resolvedOutcome,
        "volumeValueYes": volumeValueYes,
        "volumeValueNo": volumeValueNo,
        "yesProfitForEstimate": yesProfitForEstimate,
        "noProfitForEstimate": noProfitForEstimate,
      };
}

class Pagination {
  final int? page;
  final int? size;
  final int? totalCount;
  final int? lastPage;

  Pagination({
    this.page,
    this.size,
    this.totalCount,
    this.lastPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
        page: json["page"],
        size: json["size"],
        totalCount: json["totalCount"],
        lastPage: json["lastPage"],
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "size": size,
        "totalCount": totalCount,
        "lastPage": lastPage,
      };
}

enum Category {
  crypto,
  entertainment,
  politics,
  sports,
  technlogy,
  xPosts,
}

final categoryValues = EnumValues({
  "crypto": Category.crypto,
  "ENTERTAINMENT": Category.entertainment,
  "POLITICS": Category.politics,
  "SPORTS": Category.sports,
  "TECHNOLOGY": Category.technlogy,
  "X POSTS": Category.xPosts
});

enum Status { open }

final statusValues = EnumValues({"open": Status.open});

enum SupportedCurrency { ngn, usd }

final supportedCurrencyValues = EnumValues({
  "NGN": SupportedCurrency.ngn,
  "USD": SupportedCurrency.usd,
});

enum EventType { combinedMarkets, singleMarkets }

final typeValues = EnumValues({
  "COMBINED_MARKETS": EventType.combinedMarkets,
  "SINGLE_MARKET": EventType.singleMarkets
});

class EnumValues<T> {
  final Map<String, T> map;
  late final Map<T, String> reverseMap;
  EnumValues(this.map) {
    reverseMap = map.map((k, v) => MapEntry(v, k));
  }
  Map<T, String> get reverse => reverseMap;
}
