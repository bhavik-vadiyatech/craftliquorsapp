import 'package:craft_discount_liquors/common/enums/data_source_enum.dart';
import 'package:craft_discount_liquors/common/reposotories/data_sync_repo.dart';
import 'package:craft_discount_liquors/data/datasource/remote/exception/api_error_handler.dart';
import 'package:craft_discount_liquors/common/models/api_response_model.dart';
import 'package:craft_discount_liquors/utill/app_constants.dart';

class CategoryRepo extends DataSyncRepo {
  CategoryRepo({required super.dioClient, required super.sharedPreferences});

  Future<ApiResponseModel<T>> getCategoryList<T>({
    required DataSourceEnum source,
  }) async {
    return await fetchData<T>(AppConstants.categoryUri, source);
  }

  Future<ApiResponseModel> getSubCategoryList(String parentID) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.subCategoryUri}$parentID',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }

  Future<ApiResponseModel> getCategoryProductList(
    String categoryID,
    int offset,
  ) async {
    try {
      final response = await dioClient.get(
        '${AppConstants.categoryProductUri}$categoryID?limit=10&&offset=$offset',
      );
      return ApiResponseModel.withSuccess(response);
    } catch (e) {
      return ApiResponseModel.withError(ApiErrorHandler.getMessage(e));
    }
  }
}
