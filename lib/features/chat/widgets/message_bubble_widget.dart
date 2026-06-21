import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/widgets/custom_image_widget.dart';
import 'package:craft_discount_liquors/features/chat/domain/models/chat_model.dart';
import 'package:craft_discount_liquors/helper/date_converter_helper.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/features/profile/providers/profile_provider.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/utill/color_resources.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/images.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:craft_discount_liquors/features/chat/widgets/image_dialog_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubbleWidget extends StatelessWidget {
  final Messages? messages;
  final bool? isAdmin;
  const MessageBubbleWidget({super.key, this.messages, this.isAdmin});
  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(
      context,
      listen: false,
    );
    return !isAdmin!
        ? messages!.deliverymanId != null
              ? Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      Dimensions.paddingSizeSmall,
                    ),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(
                      Dimensions.paddingSizeDefault,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          messages!.deliverymanId!.name ?? '',
                          style: poppinsRegular.copyWith(
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                        ),
                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                right: Dimensions.paddingSizeSmall,
                              ),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    width: .5,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50.0),
                                  child: CustomImageWidget(
                                    placeholder: Images.profilePlaceholder,
                                    fit: BoxFit.cover,
                                    width: 40,
                                    height: 40,
                                    image:
                                        '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.deliveryManImageUrl}/${messages!.deliverymanId!.image ?? ''}',
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (messages!.message != null)
                                    Flexible(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).secondaryHeaderColor,
                                          borderRadius: const BorderRadius.only(
                                            topRight: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                            messages!.message != null
                                                ? Dimensions.paddingSizeDefault
                                                : 0,
                                          ),
                                          child: _BuildMessageText(
                                            message: messages!.message ?? '',
                                            context: context,
                                          ),
                                        ),
                                      ),
                                    ),
                                  if (messages!.attachment != null)
                                    const SizedBox(
                                      height: Dimensions.paddingSizeSmall,
                                    ),
                                  messages!.attachment != null
                                      ? GridView.builder(
                                          gridDelegate:
                                              SliverGridDelegateWithFixedCrossAxisCount(
                                                childAspectRatio: 1,
                                                crossAxisCount:
                                                    ResponsiveHelper.isDesktop(
                                                      context,
                                                    )
                                                    ? 8
                                                    : 3,
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 10,
                                              ),
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount:
                                              messages!.attachment!.length,
                                          itemBuilder: (BuildContext context, index) {
                                            final bool isDesktop =
                                                ResponsiveHelper.isDesktop(
                                                  context,
                                                );
                                            final String imageUrl =
                                                messages!.attachment![index];
                                            return (messages!
                                                    .attachment!
                                                    .isNotEmpty)
                                                ? Padding(
                                                    padding: EdgeInsets.all(
                                                      isDesktop ? 4.0 : 0.0,
                                                    ),
                                                    child: InkWell(
                                                      onTap: () => showDialog(
                                                        context: context,
                                                        builder: (ctx) =>
                                                            ImageDialogWidget(
                                                              imageUrl:
                                                                  imageUrl,
                                                            ),
                                                      ),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              5,
                                                            ),
                                                        child: CustomImageWidget(
                                                          placeholder: Images
                                                              .placeHolder,
                                                          height: 100,
                                                          width: 100,
                                                          fit: BoxFit.cover,
                                                          image: imageUrl,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox();
                                          },
                                        )
                                      : const SizedBox(),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: Dimensions.paddingSizeSmall),
                        const SizedBox(),
                        Text(
                          DateConverterHelper.localDateToIsoStringAMPM(
                            DateTime.parse(messages!.createdAt!),
                            context,
                          ),
                          style: poppinsRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Dimensions.paddingSizeSmall,
                      ),
                      //color: Colors.red
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(
                        Dimensions.paddingSizeDefault,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${profileProvider.userInfoModel?.fName} ${profileProvider.userInfoModel?.lName}',
                            style: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (messages!.message != null)
                                      Flexible(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color:
                                                ColorResources.getChatAdminColor(
                                                  context,
                                                ),
                                            borderRadius:
                                                const BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  bottomRight: Radius.circular(
                                                    10,
                                                  ),
                                                  bottomLeft: Radius.circular(
                                                    10,
                                                  ),
                                                ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              messages!.message != null
                                                  ? Dimensions
                                                        .paddingSizeDefault
                                                  : 0,
                                            ),
                                            child: _BuildMessageText(
                                              message: messages!.message ?? '',
                                              context: context,
                                            ),
                                          ),
                                        ),
                                      ),
                                    messages!.attachment != null
                                        ? const SizedBox(
                                            height: Dimensions.paddingSizeSmall,
                                          )
                                        : const SizedBox(),
                                    messages!.attachment != null
                                        ? Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: GridView.builder(
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                    childAspectRatio: 1,
                                                    crossAxisCount:
                                                        ResponsiveHelper.isDesktop(
                                                          context,
                                                        )
                                                        ? 8
                                                        : 3,
                                                    crossAxisSpacing: 10,
                                                    mainAxisSpacing: 10,
                                                  ),
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  messages!.attachment!.length,
                                              itemBuilder: (BuildContext context, index) {
                                                final String imageUrl =
                                                    messages!
                                                        .attachment![index];
                                                return (messages!
                                                        .attachment!
                                                        .isNotEmpty)
                                                    ? Padding(
                                                        padding:
                                                            ResponsiveHelper.isDesktop(
                                                              context,
                                                            )
                                                            ? const EdgeInsets.all(
                                                                8.0,
                                                              )
                                                            : EdgeInsets.zero,
                                                        child: InkWell(
                                                          onTap: () => showDialog(
                                                            context: context,
                                                            builder: (ctx) =>
                                                                ImageDialogWidget(
                                                                  imageUrl:
                                                                      imageUrl,
                                                                ),
                                                          ),
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  5,
                                                                ),
                                                            child:
                                                                CustomImageWidget(
                                                                  height: 100,
                                                                  width: 100,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  image:
                                                                      imageUrl,
                                                                ),
                                                          ),
                                                        ),
                                                      )
                                                    : const SizedBox();
                                              },
                                            ),
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircleAvatar(
                                  radius: Dimensions.paddingSizeDefault,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50.0),
                                    child: CustomImageWidget(
                                      fit: BoxFit.cover,
                                      width: 40,
                                      height: 40,
                                      image:
                                          '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.customerImageUrl}/${profileProvider.userInfoModel!.image}',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Text(
                            DateConverterHelper.localDateToIsoStringAMPM(
                              DateTime.parse(messages!.createdAt!),
                              context,
                            ),
                            style: poppinsRegular.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
        //customer to admin
        : Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeExtraSmall,
            ),
            child: (messages!.isReply != null && messages!.isReply!)
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        Dimensions.paddingSizeSmall,
                      ),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.all(
                        Dimensions.paddingSizeDefault,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${Provider.of<SplashProvider>(context, listen: false).configModel!.ecommerceName}',
                            style: poppinsRegular.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                            ),
                          ),
                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: CustomImageWidget(
                                  placeholder: Images.appLogo,
                                  fit: BoxFit.cover,
                                  width: 40,
                                  height: 40,
                                  image:
                                      '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.ecommerceImageUrl}/${Provider.of<SplashProvider>(context, listen: false).configModel!.ecommerceLogo}',
                                ),
                              ),

                              Flexible(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (messages!.reply != null &&
                                        messages!.reply!.isNotEmpty)
                                      Flexible(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Theme.of(
                                              context,
                                            ).secondaryHeaderColor,
                                            borderRadius:
                                                const BorderRadius.only(
                                                  bottomRight: Radius.circular(
                                                    10,
                                                  ),
                                                  topRight: Radius.circular(10),
                                                  bottomLeft: Radius.circular(
                                                    10,
                                                  ),
                                                ),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              messages!.reply != null
                                                  ? Dimensions
                                                        .paddingSizeDefault
                                                  : 0,
                                            ),
                                            child: _BuildMessageText(
                                              message: messages!.reply ?? '',
                                              context: context,
                                            ),
                                          ),
                                        ),
                                      ),
                                    if (messages!.reply != null &&
                                        messages!.reply!.isNotEmpty)
                                      const SizedBox(height: 8.0),

                                    messages!.image != null
                                        ? GridView.builder(
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                  childAspectRatio: 1,
                                                  crossAxisCount:
                                                      ResponsiveHelper.isDesktop(
                                                        context,
                                                      )
                                                      ? 8
                                                      : 3,
                                                  crossAxisSpacing: 10,
                                                  mainAxisSpacing: 10,
                                                ),
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: messages!.image!.length,
                                            itemBuilder: (BuildContext context, index) {
                                              return messages!.image!.isNotEmpty
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                            right: 8,
                                                          ),
                                                      child: InkWell(
                                                        hoverColor:
                                                            Colors.transparent,
                                                        onTap: () => showDialog(
                                                          context: context,
                                                          builder: (ctx) =>
                                                              ImageDialogWidget(
                                                                imageUrl:
                                                                    '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.chatImageUrl}/${messages!.image![index]}',
                                                              ),
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                10,
                                                              ),
                                                          child: CustomImageWidget(
                                                            placeholder: Images
                                                                .placeHolder,
                                                            height: 100,
                                                            width: 100,
                                                            fit: BoxFit.cover,
                                                            image:
                                                                '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.chatImageUrl}/${messages!.image![index]}',
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : const SizedBox();
                                            },
                                          )
                                        : const SizedBox(),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: Dimensions.paddingSizeSmall),
                          Text(
                            DateConverterHelper.localDateToIsoStringAMPM(
                              DateTime.parse(messages!.createdAt!),
                              context,
                            ),
                            style: poppinsRegular.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeDefault,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          Dimensions.paddingSizeSmall,
                        ),
                      ),

                      child: Consumer<ProfileProvider>(
                        builder: (context, profileController, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${profileController.userInfoModel != null ? profileController.userInfoModel!.fName ?? '' : ''} ${profileController.userInfoModel != null ? profileController.userInfoModel!.lName ?? '' : ''}',
                                style: poppinsRegular.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        (messages!.message != null &&
                                                messages!.message!.isNotEmpty)
                                            ? Flexible(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        ColorResources.getChatAdminColor(
                                                          context,
                                                        ),
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                10,
                                                              ),
                                                          bottomRight:
                                                              Radius.circular(
                                                                10,
                                                              ),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                10,
                                                              ),
                                                        ),
                                                  ),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(
                                                      messages!.message != null
                                                          ? Dimensions
                                                                .paddingSizeDefault
                                                          : 0,
                                                    ),
                                                    child: _BuildMessageText(
                                                      message:
                                                          messages!.message ??
                                                          '',
                                                      context: context,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                        messages!.image != null
                                            ? Directionality(
                                                textDirection:
                                                    TextDirection.rtl,
                                                child: GridView.builder(
                                                  reverse: true,
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                        childAspectRatio: 1,
                                                        crossAxisCount:
                                                            ResponsiveHelper.isDesktop(
                                                              context,
                                                            )
                                                            ? 8
                                                            : 3,
                                                        crossAxisSpacing: 10,
                                                        mainAxisSpacing: 10,
                                                      ),
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      messages!.image!.length,
                                                  itemBuilder: (BuildContext context, index) {
                                                    return messages!
                                                            .image!
                                                            .isNotEmpty
                                                        ? InkWell(
                                                            onTap: () => showDialog(
                                                              context: context,
                                                              builder: (ctx) =>
                                                                  ImageDialogWidget(
                                                                    imageUrl:
                                                                        messages!
                                                                            .image![index],
                                                                  ),
                                                            ),
                                                            child: Padding(
                                                              padding: EdgeInsets.only(
                                                                left: Dimensions
                                                                    .paddingSizeSmall,
                                                                right: 0,
                                                                top:
                                                                    (messages!.message !=
                                                                            null &&
                                                                        messages!
                                                                            .message!
                                                                            .isNotEmpty)
                                                                    ? Dimensions
                                                                          .paddingSizeSmall
                                                                    : 0,
                                                              ),
                                                              child: ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      5,
                                                                    ),
                                                                child: CustomImageWidget(
                                                                  placeholder:
                                                                      Images
                                                                          .placeHolder,
                                                                  height: 100,
                                                                  width: 100,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  image: messages!
                                                                      .image![index],
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox();
                                                  },
                                                ),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: Dimensions.paddingSizeSmall,
                                    ),
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(
                                            Dimensions.paddingSizeDefault,
                                          ),
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                        child: CustomImageWidget(
                                          placeholder: Images.placeHolder,
                                          fit: BoxFit.cover,
                                          width: 40,
                                          height: 40,
                                          image:
                                              profileController.userInfoModel !=
                                                  null
                                              ? '${Provider.of<SplashProvider>(context, listen: false).baseUrls!.customerImageUrl}/${profileController.userInfoModel!.image}'
                                              : '',
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(
                                height: Dimensions.paddingSizeSmall,
                              ),
                              Text(
                                DateConverterHelper.localDateToIsoStringAMPM(
                                  DateTime.parse(messages!.createdAt!),
                                  context,
                                ),
                                style: poppinsRegular.copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontSize: Dimensions.fontSizeSmall,
                                ),
                              ),
                              const SizedBox(
                                height: Dimensions.paddingSizeDefault,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
          );
  }
}

class _BuildMessageText extends StatelessWidget {
  const _BuildMessageText({required this.message, required this.context});

  final String message;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final urlPattern = RegExp(r'(https?:\/\/[^\s]+)', caseSensitive: false);
    final matches = urlPattern.allMatches(message);

    if (matches.isEmpty) {
      return SelectableText(message);
    }

    final spans = <InlineSpan>[];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: message.substring(lastMatchEnd, match.start)));
      }

      final url = match.group(0)!;
      spans.add(
        TextSpan(
          text: url,
          style: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
            },
        ),
      );

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < message.length) {
      spans.add(TextSpan(text: message.substring(lastMatchEnd)));
    }

    return SelectableText.rich(TextSpan(children: spans));
  }
}
