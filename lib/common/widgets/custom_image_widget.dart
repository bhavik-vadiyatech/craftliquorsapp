import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:craft_discount_liquors/common/widgets/custom_asset_image_widget.dart';
import 'package:craft_discount_liquors/utill/app_constants.dart';
import 'package:craft_discount_liquors/utill/images.dart';

class CustomImageWidget extends StatelessWidget {
  final String image;
  final double? height;
  final double? width;
  final BoxFit fit;
  final bool isNotification;
  final String placeholder;

  const CustomImageWidget({
    super.key,
    required this.image,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.isNotification = false,
    this.placeholder = '',
  });

  @override
  Widget build(BuildContext context) {
    final placeholderImage = placeholder.isNotEmpty
        ? placeholder
        : Images.placeHolder;
    return CachedNetworkImage(
      imageUrl: kIsWeb
          ? '${AppConstants.baseUrl}/image-proxy?url=$image'
          : image,
      height: height,
      width: width,
      fit: fit,
      // Smoother interpolation than the default (FilterQuality.low). This does
      // not add detail — it only makes the unavoidable upscaling of low-res
      // source images look slightly cleaner. The real fix is higher-resolution
      // images on the backend (see notes).
      filterQuality: FilterQuality.medium,
      placeholder: (context, url) => CustomAssetImageWidget(
        placeholderImage,
        height: height,
        width: width,
        fit: fit,
      ),
      errorWidget: (context, url, error) => CustomAssetImageWidget(
        placeholderImage,
        height: height,
        width: width,
        fit: fit,
      ),
    );
  }
}
