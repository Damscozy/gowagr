// ignore_for_file: depend_on_referenced_packages, implementation_imports

import 'dart:async';

import 'package:gowagr/core/utils/map_extension.dart';
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
  final int? page;
  final int? size;
  final int? totalPages;
  final int? totalElements;
  final int? numberOfElements;

  PaginatedRequest({
    this.page,
    this.size,
    this.totalPages,
    this.totalElements,
    this.numberOfElements,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'page': page,
      'size': size,
      'totalPages': totalPages,
      'totalElements': totalElements,
      'numberOfElements': numberOfElements
    }.removeNullValues;
  }
}

class PaginatedResponse<T> {
  List<T> dataList;
  String fieldName;
  int? size;
  int? page;
  int? totalPages;
  int? totalElements;
  int? numberOfElements;

  PaginatedResponse({
    required this.dataList,
    this.size,
    this.page,
    this.totalPages,
    this.totalElements,
    this.numberOfElements,
    required this.fieldName,
  });

  PaginatedResponse<T> copyWith({
    int? size,
    int? page,
    int? totalPages,
    String? fieldName,
    List<T>? dataList,
    int? totalElements,
    int? numberOfElements,
  }) {
    return PaginatedResponse<T>(
      size: size ?? this.size,
      page: page ?? this.page,
      dataList: dataList ?? this.dataList,
      fieldName: fieldName ?? this.fieldName,
      totalElements: totalElements ?? this.totalElements,
      numberOfElements: numberOfElements ?? this.numberOfElements,
    );
  }

  bool get isCompleted => page! >= (totalPages ?? 1);
  PaginatedRequest nextPage() => PaginatedRequest(
        page: (page ?? 0) + 1,
        size: (size ?? 10) + 10,
        totalPages: totalPages,
        totalElements: totalElements,
        numberOfElements: numberOfElements,
      );
  factory PaginatedResponse.fromJson({
    int? totalElements,
    int? numberOfElements,
    bool Function(T)? filter,
    required String fieldName,
    required Map<String, dynamic> json,
    required T Function(Object?) dataFromJson,
  }) =>
      PaginatedResponse(
        fieldName: fieldName,
        dataList: filter == null
            ? (json[fieldName] as List<dynamic>).map(dataFromJson).toList()
            : (json[fieldName] as List<dynamic>)
                .map(dataFromJson)
                .toList()
                .where(filter)
                .toList(),
        page: json['page']?['page'],
        size: json['page']?['size'],
        totalPages: json['page']?['totalPages'],
        totalElements: json['page']?['totalElements'],
        numberOfElements: json['page']?['numberOfElements'],
      );

  factory PaginatedResponse.empty() => PaginatedResponse(
        page: 0,
        size: 1,
        dataList: [],
        totalPages: 1,
        totalElements: 1,
        fieldName: 'data',
      );
}
