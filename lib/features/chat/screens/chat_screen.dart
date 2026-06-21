import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:craft_discount_liquors/common/widgets/custom_image_widget.dart';
import 'package:craft_discount_liquors/common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/features/auth/providers/auth_provider.dart';
import 'package:craft_discount_liquors/features/chat/providers/chat_provider.dart';
import 'package:craft_discount_liquors/features/profile/providers/profile_provider.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/localization/app_localization.dart';
import 'package:craft_discount_liquors/localization/language_constraints.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/images.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:craft_discount_liquors/helper/custom_snackbar_helper.dart';
import 'package:craft_discount_liquors/common/widgets/not_login_widget.dart';
import 'package:craft_discount_liquors/common/widgets/web_app_bar_widget.dart';
import 'package:craft_discount_liquors/features/chat/widgets/message_bubble_widget.dart';
import 'package:craft_discount_liquors/features/chat/widgets/message_bubble_shimmer_widget.dart';
import 'package:craft_discount_liquors/features/chat/widgets/emoji_picker_widget.dart';
import 'package:provider/provider.dart';
import 'package:craft_discount_liquors/common/enums/footer_type_enum.dart';
import 'package:craft_discount_liquors/common/widgets/footer_web_widget.dart';

class ChatScreen extends StatefulWidget {
  final String orderId;
  final String userName;
  final String senderType;
  final String profileImage;
  final bool isAppBar;
  const ChatScreen({
    super.key,
    required this.orderId,
    this.isAppBar = false,
    required this.userName,
    required this.senderType,
    required this.profileImage,
  });
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputMessageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late bool _isLoggedIn;
  bool _isFirst = true;

  @override
  void initState() {
    super.initState();

    final ChatProvider chatProvider = Provider.of<ChatProvider>(
      context,
      listen: false,
    );

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        chatProvider.hideEmojiPicker();
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (!kIsWeb) {
        chatProvider.getMessages(1, widget.orderId, false, widget.senderType);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      chatProvider.getMessages(1, widget.orderId, false, widget.senderType);
    });

    _isLoggedIn = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).isLoggedIn();

    if (_isLoggedIn) {
      if (_isFirst) {
        chatProvider.getMessages(1, widget.orderId, true, widget.senderType);
      } else {
        chatProvider.getMessages(1, widget.orderId, false, widget.senderType);
        _isFirst = false;
      }

      Provider.of<ProfileProvider>(context, listen: false).getUserInfo(true);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _inputMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final SplashProvider splashProvider = Provider.of<SplashProvider>(
      context,
      listen: false,
    );
    final bool isAdmin = widget.senderType == "admin";

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: ResponsiveHelper.isDesktop(context)
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : ResponsiveHelper.isMobilePhone() && isAdmin && !widget.isAppBar
            ? null
            : AppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).cardColor,
                  ),
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                  onPressed: () {
                    if (!Navigator.canPop(context)) {
                      RouteHelper.getMainRoute(
                        action: RouteAction.pushNamedAndRemoveUntil,
                      );
                      splashProvider.setPageIndex(0);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                title: Text(
                  isAdmin
                      ? '${Provider.of<SplashProvider>(context, listen: false).configModel!.ecommerceName}'
                      : widget.userName,
                  style: poppinsMedium.copyWith(
                    color: Theme.of(context).cardColor,
                  ),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                actions: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          width: 2,
                          color: Theme.of(context).cardColor,
                        ),
                        color: Theme.of(context).cardColor,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CustomImageWidget(
                          fit: BoxFit.cover,
                          placeholder: isAdmin
                              ? Images.appLogo
                              : Images.profilePlaceholder,
                          image: isAdmin
                              ? ''
                              : '${splashProvider.baseUrls?.deliveryManImageUrl}/${widget.profileImage}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        body: _isLoggedIn
            ? ResponsiveHelper.isDesktop(context)
                  ? CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height - 120,
                            child: Column(
                              children: [
                                Expanded(
                                  child: Center(
                                    child: SizedBox(
                                      width: Dimensions.webScreenWidth,
                                      child: Stack(
                                        children: [
                                          Positioned.fill(
                                            top: 80,
                                            child: Consumer<ChatProvider>(
                                              builder: (context, chatProvider, child) {
                                                return chatProvider
                                                            .messageList ==
                                                        null
                                                    ? ClipRect(
                                                        child: ListView.builder(
                                                          reverse: true,
                                                          physics:
                                                              const AlwaysScrollableScrollPhysics(),
                                                          itemCount: 15,
                                                          itemBuilder:
                                                              (
                                                                context,
                                                                index,
                                                              ) =>
                                                                  MessageBubbleShimmerWidget(
                                                                    isMe: index
                                                                        .isOdd,
                                                                  ),
                                                        ),
                                                      )
                                                    : chatProvider
                                                          .messageList!
                                                          .isEmpty
                                                    ? _buildEmptyState(context)
                                                    : ClipRect(
                                                        child: ListView.builder(
                                                          reverse: true,
                                                          physics:
                                                              const AlwaysScrollableScrollPhysics(),
                                                          itemCount:
                                                              chatProvider
                                                                  .messageList!
                                                                  .length,
                                                          itemBuilder: (context, index) {
                                                            return MessageBubbleWidget(
                                                              messages: chatProvider
                                                                  .messageList![index],
                                                              isAdmin: isAdmin,
                                                            );
                                                          },
                                                        ),
                                                      );
                                              },
                                            ),
                                          ),
                                          Positioned(
                                            top: 0,
                                            left: 0,
                                            right: 0,
                                            child: Container(
                                              color: Theme.of(
                                                context,
                                              ).scaffoldBackgroundColor,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: Dimensions
                                                        .paddingSizeExtraLarge,
                                                  ),
                                              child: Center(
                                                child: Text(
                                                  isAdmin
                                                      ? "conversation".tr
                                                      : widget.userName,
                                                  style: poppinsSemiBold
                                                      .copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeLarge,
                                                      ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                _buildInputArea(context),
                                const SizedBox(
                                  height: Dimensions.paddingSizeLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (ResponsiveHelper.isWeb()) ...[
                          const FooterWebWidget(footerType: FooterType.sliver),
                        ],
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Consumer<ChatProvider>(
                            builder: (context, chatProvider, child) {
                              if (chatProvider.messageList == null) {
                                return ClipRect(
                                  child: ListView.builder(
                                    reverse: true,
                                    physics:
                                        const AlwaysScrollableScrollPhysics(),
                                    itemCount: 15,
                                    itemBuilder: (context, index) =>
                                        MessageBubbleShimmerWidget(
                                          isMe: index.isOdd,
                                        ),
                                  ),
                                );
                              }

                              if (chatProvider.messageList!.isEmpty) {
                                // FIX: Empty state message
                                return _buildEmptyState(context);
                              }

                              return ClipRect(
                                child: ListView.builder(
                                  reverse: true,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: chatProvider.messageList!.length,
                                  itemBuilder: (context, index) {
                                    return MessageBubbleWidget(
                                      messages:
                                          chatProvider.messageList![index],
                                      isAdmin: isAdmin,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                        _buildInputArea(context),

                        Consumer<ChatProvider>(
                          builder: (context, chatProvider, _) {
                            return Offstage(
                              offstage: !chatProvider.isEmojiPickerVisible,
                              child: SizedBox(
                                height: 250,
                                child: EmojiPickerWidget(
                                  textEditingController:
                                      _inputMessageController,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    )
            : const NotLoggedInWidget(),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Text(
            getTranslated('no_message_yet', context),
            style: poppinsMedium.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: Theme.of(context).disabledColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          Text(
            getTranslated('start_conversation', context),
            style: poppinsRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: Theme.of(context).disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(
        ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeSmall,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(Dimensions.radiusSizeSmall),
        ),
        child: Column(
          children: [
            Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                return (chatProvider.chatImage?.isNotEmpty ?? false)
                    ? SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemCount: chatProvider.chatImage!.length,
                          itemBuilder: (BuildContext context, index) {
                            return chatProvider.chatImage!.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 100,
                                          height: 100,
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                  Radius.circular(
                                                    Dimensions
                                                        .paddingSizeDefault,
                                                  ),
                                                ),
                                            child: ResponsiveHelper.isWeb()
                                                ? Image.network(
                                                    chatProvider
                                                        .chatImage![index]
                                                        .path,
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.file(
                                                    File(
                                                      chatProvider
                                                          .chatImage![index]
                                                          .path,
                                                    ),
                                                    width: 100,
                                                    height: 100,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: InkWell(
                                            onTap: () =>
                                                chatProvider.removeImage(index),
                                            child: Container(
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                    Dimensions
                                                        .paddingSizeDefault,
                                                  ),
                                                ),
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Icon(
                                                  Icons.clear,
                                                  color: Colors.red,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox();
                          },
                        ),
                      )
                    : const SizedBox();
              },
            ),

            SizedBox(
              width: Dimensions.webScreenWidth,
              child: Row(
                children: [
                  InkWell(
                    onTap: () async {
                      Provider.of<ChatProvider>(
                        context,
                        listen: false,
                      ).onPickImage(context, false);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeDefault,
                      ),
                      child: Image.asset(
                        Images.image,
                        width: 25,
                        height: 25,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),

                  SizedBox(
                    height: 25,
                    child: VerticalDivider(
                      width: 0,
                      thickness: 1,
                      color: Theme.of(context).hintColor,
                    ),
                  ),

                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, _) {
                      return IconButton(
                        onPressed: () {
                          if (ResponsiveHelper.isDesktop(context)) {
                            _showEmojiPickerDialog(context);
                          } else {
                            if (_focusNode.hasFocus) {
                              _focusNode.unfocus();
                            }
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                chatProvider.onClickEmoji();
                              },
                            );
                          }
                        },
                        icon: Icon(
                          chatProvider.isEmojiPickerVisible
                              ? Icons.keyboard
                              : Icons.emoji_emotions_outlined,
                        ),
                      );
                    },
                  ),

                  SizedBox(
                    height: 25,
                    child: VerticalDivider(
                      width: 0,
                      thickness: 1,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  Expanded(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.2,
                      ),
                      child: TextField(
                        focusNode: _focusNode,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(
                            Dimensions.messageInputLength,
                          ),
                        ],
                        controller: _inputMessageController,
                        textCapitalization: TextCapitalization.sentences,
                        style: poppinsRegular,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: getTranslated('type_here', context),
                          hintStyle: poppinsRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeLarge,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        onSubmitted: (String newText) {
                          if (newText.trim().isNotEmpty &&
                              !Provider.of<ChatProvider>(
                                context,
                                listen: false,
                              ).isSendButtonActive) {
                            Provider.of<ChatProvider>(
                              context,
                              listen: false,
                            ).onChangeSendButtonActivity();
                          } else if (newText.isEmpty &&
                              Provider.of<ChatProvider>(
                                context,
                                listen: false,
                              ).isSendButtonActive) {
                            Provider.of<ChatProvider>(
                              context,
                              listen: false,
                            ).onChangeSendButtonActivity();
                          }
                        },
                        onChanged: (String newText) {
                          if (newText.trim().isNotEmpty &&
                              !Provider.of<ChatProvider>(
                                context,
                                listen: false,
                              ).isSendButtonActive) {
                            Provider.of<ChatProvider>(
                              context,
                              listen: false,
                            ).onChangeSendButtonActivity();
                          } else if (newText.isEmpty &&
                              Provider.of<ChatProvider>(
                                context,
                                listen: false,
                              ).isSendButtonActive) {
                            Provider.of<ChatProvider>(
                              context,
                              listen: false,
                            ).onChangeSendButtonActivity();
                          }
                        },
                      ),
                    ),
                  ),

                  Consumer<ChatProvider>(
                    builder: (context, chatProvider, _) {
                      return InkWell(
                        onTap: chatProvider.isLoading
                            ? null
                            : () async {
                                if (chatProvider.isSendButtonActive) {
                                  chatProvider.sendMessage(
                                    _inputMessageController.text,
                                    context,
                                    Provider.of<AuthProvider>(
                                      context,
                                      listen: false,
                                    ).getUserToken(),
                                    widget.orderId,
                                    widget.senderType,
                                  );
                                  _inputMessageController.clear();
                                  chatProvider.onChangeSendButtonActivity();
                                } else {
                                  showCustomSnackBarHelper(
                                    'write_somethings'.tr,
                                  );
                                }
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                          ),
                          child: chatProvider.isLoading
                              ? SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor,
                                    ),
                                  ),
                                )
                              : Image.asset(
                                  Images.send,
                                  width: 25,
                                  height: 25,
                                  color: chatProvider.isSendButtonActive
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).hintColor,
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.radiusSizeTen),
          ),
          child: Container(
            width: 500,
            height: 450,
            padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'select_emoji'.tr,
                      style: poppinsMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Expanded(
                  child: EmojiPickerWidget(
                    textEditingController: _inputMessageController,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
