import 'dart:convert';
import 'package:craft_discount_liquors/data/datasource/remote/dio/dio_client.dart';
import 'package:craft_discount_liquors/data/datasource/remote/exception/api_error_handler.dart';
import 'package:craft_discount_liquors/common/models/api_response_model.dart';
import 'package:craft_discount_liquors/utill/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchRepo {
  final DioClient? dioClient;
  final SharedPreferences? sharedPreferences;
  SearchRepo({required this.dioClient, required this.sharedPreferences});

  Future<ApiResponseModel> getSearchProductList({
    required String name,
    required int offset,
    double? priceLow,
    double? priceHigh,
    String? sortBy,
    int? rating,
    List<int>? categories,
  }) async {
    final Map<String, dynamic> params = {
      'limit': 10,
      'offset': offset,
      if (name.isNotEmpty) 'name': name,
      'min_price': ?priceLow,
      'max_price': ?priceHigh,
      'sort_by': ?sortBy,
      'rating': ?rating,
      if (categories != null && categories.isNotEmpty)
        'category_ids': jsonEncode(categories),
    };

    try {
      final response = await dioClient!.get(
        AppConstants.searchUri,
        queryParameters: params,
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  List<String?> getAllSortByList() {
    List<String?> sortByList = [
      'high_to_low',
      'low_to_high',
      'ascending',
      'descending',
    ];
    return sortByList;
  }

  List<String?> getAllFilterByList() {
    List<String?> filterByList = [
      'default',
      'popular',
      'most_ordered',
      'top_rated',
    ];
    return filterByList;
  }

  // for save home address
  Future<void> saveSearchAddress(String? searchAddress) async {
    try {
      List<String> searchKeywordList =
          sharedPreferences!.getStringList(AppConstants.searchAddress) ?? [];
      if (!searchKeywordList.contains(searchAddress)) {
        searchKeywordList.add(searchAddress!);
      }
      await sharedPreferences!.setStringList(
        AppConstants.searchAddress,
        searchKeywordList,
      );
    } catch (e) {
      rethrow;
    }
  }

  List<String> getSearchAddress() {
    return sharedPreferences!.getStringList(AppConstants.searchAddress) ?? [];
  }

  Future<bool> clearSearchAddress() async {
    return sharedPreferences!.setStringList(AppConstants.searchAddress, []);
  }
}
