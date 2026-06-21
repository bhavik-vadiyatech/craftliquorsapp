import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/models/api_response_model.dart';
import 'package:craft_discount_liquors/common/models/error_response_model.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/main.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/helper/custom_snackbar_helper.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ApiCheckerHelper {
  static void checkApi(ApiResponseModel apiResponse) {
    ErrorResponseModel error = getError(apiResponse);

    if ((error.errors?[0].code == '401' ||
        error.errors![0].code == 'auth-001' &&
            ModalRoute.of(Get.context!)?.settings.name != RouteHelper.login)) {
      Provider.of<SplashProvider>(
        Get.context!,
        listen: false,
      ).removeSharedData();
      Provider.of<SplashProvider>(Get.context!, listen: false).setPageIndex(0);
      RouteHelper.getLoginRoute(action: RouteAction.push);
    } else {
      showCustomSnackBarHelper(
        getTranslated(error.errors?.first.message, Get.context!),
      );
    }
  }

  static ErrorResponseModel getError(ApiResponseModel apiResponse) {
    ErrorResponseModel error;

    try {
      error = ErrorResponseModel.fromJson(apiResponse);
    } catch (e) {
      if (apiResponse.error != null) {
        error = ErrorResponseModel.fromJson(apiResponse.error);
      } else {
        error = ErrorResponseModel(
          errors: [Errors(code: '', message: apiResponse.error.toString())],
        );
      }
    }
    return error;
  }

  static Future<String> getStreamedResponseError(
    http.StreamedResponse response,
  ) async {
    String errorMessage = '${response.statusCode} ${response.reasonPhrase}';

    try {
      String responseBody = await response.stream.bytesToString();
      Map<String, dynamic> responseMap = jsonDecode(responseBody);

      ErrorResponseModel errorResponse = ErrorResponseModel.fromJson(
        responseMap,
      );

      if (errorResponse.errors != null && errorResponse.errors!.isNotEmpty) {
        errorMessage = errorResponse.errors!.first.message ?? errorMessage;
      }
    } catch (e) {
      debugPrint('Error parsing response: $e');
    }

    return errorMessage;
  }
}
