// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/src/async_notifier.dart';

// ignore: invalid_use_of_internal_member
mixin PaginationController<T> on AsyncNotifierBase<PaginatedResponse<T>> {
  FutureOr<PaginatedResponse<T>> loadData(PaginatedRequest request);
  bool hasMore = true;

  Future<void> loadMore() async {
    final oldState = state;
    if (!oldState.hasValue || oldState.requireValue.isCompleted) return;

    state = AsyncLoading<PaginatedResponse<T>>().copyWithPrevious(oldState);
    state = await AsyncValue.guard<PaginatedResponse<T>>(() async {
      final res = await loadData(oldState.requireValue.nextPage());
      res.dataList.insertAll(0, state.requireValue.dataList);
      return res;
    });
  }

  bool canLoadMore() {
    if (state.isLoading) return false;
    if (!state.hasValue) return false;
    if (state.requireValue.isCompleted) return false;
    return true;
  }
}

class PaginatedRequest {
  final int page;
  final int size;

  const PaginatedRequest({
    required this.page,
    required this.size,
  });

  Map<String, dynamic> toJson() => {
        'page': page,
        'size': size,
      };
}

class PaginatedResponse<T> {
  final List<T> dataList;
  final String fieldName;
  final int page;
  final int size;
  final int totalCount;
  final int lastPage;

  PaginatedResponse({
    required this.dataList,
    required this.fieldName,
    required this.page,
    required this.size,
    required this.totalCount,
    required this.lastPage,
  });

  bool get isCompleted => page >= lastPage;

  PaginatedRequest nextPage() => PaginatedRequest(
        page: page + 1,
        size: size,
      );

  PaginatedResponse<T> copyWith({
    List<T>? dataList,
    int? page,
    int? size,
    int? totalCount,
    int? lastPage,
    String? fieldName,
  }) {
    return PaginatedResponse<T>(
      dataList: dataList ?? this.dataList,
      fieldName: fieldName ?? this.fieldName,
      page: page ?? this.page,
      size: size ?? this.size,
      totalCount: totalCount ?? this.totalCount,
      lastPage: lastPage ?? this.lastPage,
    );
  }

  factory PaginatedResponse.fromJson({
    required Map<String, dynamic> json,
    required String fieldName,
    required T Function(Object?) dataFromJson,
    bool Function(T)? filter,
  }) {
    final pagination = Map<String, dynamic>.from(json['pagination'] ?? {});
    final rawList =
        (json[fieldName] as List<dynamic>? ?? []).map(dataFromJson).toList();

    final filteredList =
        filter != null ? rawList.where(filter).toList() : rawList;

    return PaginatedResponse(
      fieldName: fieldName,
      dataList: filteredList,
      page: pagination['page'] ?? 1,
      size: pagination['size'] ?? 10,
      totalCount: pagination['totalCount'] ?? 0,
      lastPage: pagination['lastPage'] ?? 1,
    );
  }

  factory PaginatedResponse.empty({String fieldName = 'events'}) {
    return PaginatedResponse(
      page: 1,
      size: 10,
      totalCount: 0,
      lastPage: 1,
      dataList: [],
      fieldName: fieldName,
    );
  }
}
