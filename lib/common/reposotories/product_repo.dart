import 'package:dio/dio.dart';
import 'package:craft_discount_liquors/common/enums/data_source_enum.dart';
import 'package:craft_discount_liquors/common/enums/product_filter_type_enum.dart';
import 'package:craft_discount_liquors/common/reposotories/data_sync_repo.dart';
import 'package:craft_discount_liquors/data/datasource/remote/exception/api_error_handler.dart';
import 'package:craft_discount_liquors/common/models/api_response_model.dart';
import 'package:craft_discount_liquors/utill/product_type.dart';
import 'package:craft_discount_liquors/utill/app_constants.dart';

class ProductRepo extends DataSyncRepo {
  ProductRepo({required super.dioClient, required super.sharedPreferences});

  Future<ApiResponseModel<T>> getAllProductList<T>(
    int? offset,
    ProductFilterType type, {
    required DataSourceEnum source,
  }) async {
    return await fetchData<T>(
      '${AppConstants.allProductList}?limit=10&offset=$offset&sort_by=${type.name}',
      source,
    );
  }

  Future<ApiResponseModel<T>> getItemList<T>(
    int offset,
    String? productType, {
    required DataSourceEnum source,
    ProductFilterType? filterType,
    String? sortBy,
  }) async {
    String? apiUrl;

    if (productType == ProductType.featuredItem) {
      apiUrl = AppConstants.featuredProduct;
    } else if (productType == ProductType.dailyItem) {
      apiUrl = AppConstants.dailyItemUri;
    } else if (productType == ProductType.mostReviewed) {
      apiUrl = AppConstants.mostReviewedProduct;
    }

    String url = '$apiUrl?limit=10&&offset=$offset';
    if (sortBy != null) {
      url = '$url&sort_by=$sortBy';
    } else if (filterType != null) {
      url = '$url&sort_by=${filterType.name}';
    }

    return await fetchData<T>(url, source);
  }

  Future<ApiResponseModel> getProductDetails(
    String productID,
    bool searchQuery,
  ) async {
    try {
      String params = productID;
      if (searchQuery) {
        params = '$productID?attribute=product';
      }
      final response = await dioClient.get(
        '${AppConstants.productDetailsUri}$params',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> searchProduct(
    String productId,
    String languageCode,
  ) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.searchProductUri}$productId',
        options: Options(headers: {'X-localization': languageCode}),
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getBrandOrCategoryProductList(
    String id,
    int offset, {
    double? priceLow,
    double? priceHigh,
    String? sortBy,
    int? rating,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'limit': 10,
        'offset': offset,
        if (priceLow != null && priceHigh != null) ...{
          'min_price': priceLow,
          'max_price': priceHigh,
        },
        'sort_by': ?sortBy,
        'rating': ?rating,
      };

      final response = await dioClient.get(
        '${AppConstants.categoryProductUri}$id',
        queryParameters: params,
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel<T>> getFlashDeal<T>({
    required int offset,
    required DataSourceEnum source,
  }) async {
    return await fetchData<T>(
      '${AppConstants.flashDealUri}?limit=10&&offset=$offset',
      source,
    );
  }

  Future<ApiResponseModel> getProductReviews({
    String? productId,
    int? offset,
  }) async {
    try {
      final response = await dioClient.get(
        "${AppConstants.getReview}$productId?limit=10&offset=$offset",
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
