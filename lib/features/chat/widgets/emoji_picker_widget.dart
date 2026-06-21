import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/features/chat/providers/chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji;
import 'package:flutter/foundation.dart' as foundation;

class EmojiPickerWidget extends StatelessWidget {
  final TextEditingController textEditingController;

  const EmojiPickerWidget({super.key, required this.textEditingController});

  @override
  Widget build(BuildContext context) {
    final bool isWeb = ResponsiveHelper.isDesktop(context);

    return emoji.EmojiPicker(
      textEditingController: textEditingController,
      onEmojiSelected: (emoji.Category? category, emoji.Emoji emojiItem) {
        final chatProvider = Provider.of<ChatProvider>(context, listen: false);
        if (!chatProvider.isSendButtonActive) {
          chatProvider.onChangeSendButtonActivity();
        }
      },
      config: emoji.Config(
        height: isWeb ? 400 : 256,
        checkPlatformCompatibility: true,
        emojiViewConfig: emoji.EmojiViewConfig(
          emojiSizeMax: isWeb
              ? 32
              : 28 *
                    (foundation.defaultTargetPlatform == TargetPlatform.iOS
                        ? 1.20
                        : 1.0),
          backgroundColor: Theme.of(context).cardColor,
          columns: isWeb ? 8 : 7,
        ),
        skinToneConfig: const emoji.SkinToneConfig(),
        categoryViewConfig: emoji.CategoryViewConfig(
          iconColor: Theme.of(context).hintColor,
          iconColorSelected: Theme.of(context).primaryColor,
          indicatorColor: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).cardColor,
        ),
        bottomActionBarConfig: emoji.BottomActionBarConfig(
          backgroundColor: Theme.of(context).cardColor,
          buttonColor: Theme.of(context).cardColor,
          buttonIconColor: Theme.of(context).hintColor,
        ),
        searchViewConfig: emoji.SearchViewConfig(
          backgroundColor: Theme.of(context).cardColor,
          buttonIconColor: Theme.of(context).hintColor,
        ),
      ),
    );
  }
}
