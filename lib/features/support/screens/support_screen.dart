import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/enums/footer_type_enum.dart';
import 'package:craft_discount_liquors/common/widgets/custom_pop_scope_handel_deep_link_widget.dart';
import 'package:craft_discount_liquors/helper/custom_snackbar_helper.dart';
import 'package:craft_discount_liquors/helper/email_checker_helper.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/features/splash/providers/splash_provider.dart';
import 'package:craft_discount_liquors/utill/app_colors.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:craft_discount_liquors/common/widgets/footer_web_widget.dart';
import 'package:craft_discount_liquors/common/widgets/web_app_bar_widget.dart';
import 'package:craft_discount_liquors/features/product/widgets/details_app_bar_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

/// Contact Us page (routed as SupportScreen). Presentation-only redesign — no
/// APIs/models/routing/state changes. Existing features preserved: call
/// (`tel:`), live chat (chat route). The contact form composes a client-side
/// `mailto:` to the store email (no backend endpoint exists / was added).
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return CustomPopScopeHandelDeepLinkWidget(
      child: Scaffold(
        backgroundColor: colors.sectionBackground,
        appBar: isDesktop
            ? const PreferredSize(
                preferredSize: Size.fromHeight(120),
                child: WebAppBarWidget(),
              )
            : const DetailsAppBarWidget(),
        body: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _ContactHero()),
            SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: Dimensions.webScreenWidth,
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop
                          ? Dimensions.paddingSizeLarge
                          : Dimensions.paddingSizeDefault,
                      vertical: Dimensions.paddingSizeLarge,
                    ),
                    child: const _ContactBody(),
                  ),
                ),
              ),
            ),
            const FooterWebWidget(footerType: FooterType.sliver),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Hero header
// =============================================================================
class _ContactHero extends StatelessWidget {
  const _ContactHero();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      width: double.infinity,
      color: colors.surface,
      padding: const EdgeInsets.symmetric(
        vertical: 52,
        horizontal: Dimensions.paddingSizeLarge,
      ),
      child: Column(
        children: [
          Text(
            'CONTACT US',
            textAlign: TextAlign.center,
            style: poppinsBold.copyWith(
              color: colors.heading,
              fontSize: 34,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Container(
            width: 60,
            height: 3,
            decoration: BoxDecoration(
              color: colors.brand,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Text(
              "We'd love to hear from you. Have questions? "
              'Our team is here to help.',
              textAlign: TextAlign.center,
              style: poppinsRegular.copyWith(
                color: colors.body,
                fontSize: Dimensions.fontSizeLarge,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Body: info card + form (responsive), then full-width location card
// =============================================================================
class _ContactBody extends StatelessWidget {
  const _ContactBody();

  @override
  Widget build(BuildContext context) {
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Column(
      children: [
        if (isDesktop)
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 5, child: _InfoCard()),
              SizedBox(width: Dimensions.paddingSizeLarge),
              Expanded(flex: 7, child: _ContactForm()),
            ],
          )
        else
          const Column(
            children: [
              _InfoCard(),
              SizedBox(height: Dimensions.paddingSizeLarge),
              _ContactForm(),
            ],
          ),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),
        const _LocationCard(),
        const SizedBox(height: Dimensions.paddingSizeLarge),
      ],
    );
  }
}

BoxDecoration _premiumCard(BuildContext context) {
  final colors = context.appColors;
  return BoxDecoration(
    color: colors.surface,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: colors.border),
    boxShadow: [
      BoxShadow(color: colors.shadow, blurRadius: 30, offset: const Offset(0, 14)),
    ],
  );
}

String _mapsUrl(String address) =>
    'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}';

Future<void> _launch(String url) async {
  if (url.isEmpty) return;
  if (await canLaunchUrlString(url)) {
    await launchUrlString(url);
  }
}

// =============================================================================
// Left — information card
// =============================================================================
class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final config =
        Provider.of<SplashProvider>(context, listen: false).configModel;
    final String address = config?.ecommerceAddress ?? '';
    final String phone = config?.ecommercePhone ?? '';
    final String email = config?.ecommerceEmail ?? '';

    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge + 3),
      decoration: _premiumCard(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get in Touch',
            style: poppinsBold.copyWith(
              color: colors.heading,
              fontSize: Dimensions.fontSizeExtraLarge + 2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Reach us through any of the channels below.',
            style: poppinsRegular.copyWith(
              color: colors.body,
              fontSize: Dimensions.fontSizeSmall,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          if (address.isNotEmpty)
            _InfoRow(
              icon: Icons.location_on_outlined,
              title: 'Store Address',
              value: address,
              onTap: () => _launch(_mapsUrl(address)),
            ),
          if (phone.isNotEmpty && phone != 'null')
            _InfoRow(
              icon: Icons.call_outlined,
              title: 'Phone',
              value: phone,
              onTap: () => _launch('tel:$phone'),
            ),
          if (email.isNotEmpty)
            _InfoRow(
              icon: Icons.mail_outline_rounded,
              title: 'Email',
              value: email,
              onTap: () => _launch('mailto:$email'),
            ),
          const _InfoRow(
            icon: Icons.access_time_rounded,
            title: 'Business Hours',
            value: 'Mon – Sun: 9:00 AM – 10:00 PM',
            isLast: true,
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          _PillButton(
            label: 'GET DIRECTIONS',
            icon: Icons.directions_outlined,
            filled: true,
            onTap: () => _launch(_mapsUrl(address)),
          ),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          _PillButton(
            label: 'LIVE CHAT',
            icon: Icons.chat_bubble_outline_rounded,
            filled: false,
            onTap: () => RouteHelper.getChatRoute(
              orderId: '',
              senderType: 'admin',
              userName: '',
              profileImage: '',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;
  final bool isLast;
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
    this.isLast = false,
  });

  @override
  State<_InfoRow> createState() => _InfoRowState();
}

class _InfoRowState extends State<_InfoRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      color: _hovered && widget.onTap != null
                          ? colors.brand
                          : colors.softSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      widget.icon,
                      size: 20,
                      color: _hovered && widget.onTap != null
                          ? colors.onBrand
                          : colors.brand,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeDefault),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: poppinsRegular.copyWith(
                            color: colors.body,
                            fontSize: Dimensions.fontSizeSmall,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.value,
                          style: poppinsMedium.copyWith(
                            color: (_hovered && widget.onTap != null)
                                ? colors.brand
                                : colors.heading,
                            fontSize: Dimensions.fontSizeDefault,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (!widget.isLast) Divider(height: 1, color: colors.divider),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Right — contact form (mailto submission, client-side validation)
// =============================================================================
class _ContactForm extends StatefulWidget {
  const _ContactForm();

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _subject = TextEditingController();
  final _message = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _subject.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_formKey.currentState!.validate()) return;
    final storeEmail = Provider.of<SplashProvider>(context, listen: false)
            .configModel
            ?.ecommerceEmail ??
        '';
    if (storeEmail.isEmpty) {
      showCustomSnackBarHelper('No contact email is configured.');
      return;
    }
    final subject = _subject.text.trim().isEmpty
        ? 'Website enquiry'
        : _subject.text.trim();
    final body = 'Name: ${_name.text.trim()}\n'
        'Email: ${_email.text.trim()}\n'
        'Phone: ${_phone.text.trim()}\n\n'
        '${_message.text.trim()}';
    final url =
        'mailto:$storeEmail?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}';
    await _launch(url);
    showCustomSnackBarHelper('Opening your email app…', isError: false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge + 3),
      decoration: _premiumCard(context),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send us a Message',
              style: poppinsBold.copyWith(
                color: colors.heading,
                fontSize: Dimensions.fontSizeExtraLarge + 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Fill out the form and we'll get back to you shortly.",
              style: poppinsRegular.copyWith(
                color: colors.body,
                fontSize: Dimensions.fontSizeSmall,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            Row(
              children: [
                Expanded(
                  child: _field(
                    context,
                    controller: _name,
                    label: 'Name',
                    hint: 'Your full name',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter your name'
                        : null,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: _field(
                    context,
                    controller: _email,
                    label: 'Email Address',
                    hint: 'you@email.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (EmailCheckerHelper.isNotValid(v.trim())) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Row(
              children: [
                Expanded(
                  child: _field(
                    context,
                    controller: _phone,
                    label: 'Phone Number',
                    hint: 'Optional',
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeDefault),
                Expanded(
                  child: _field(
                    context,
                    controller: _subject,
                    label: 'Subject',
                    hint: 'How can we help?',
                  ),
                ),
              ],
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            _field(
              context,
              controller: _message,
              label: 'Message',
              hint: 'Write your message…',
              maxLines: 5,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Please enter a message'
                  : null,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            _PillButton(
              label: 'SEND MESSAGE',
              icon: Icons.send_rounded,
              filled: true,
              fullWidth: true,
              onTap: _send,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final colors = context.appColors;
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: poppinsMedium.copyWith(
            color: colors.heading,
            fontSize: Dimensions.fontSizeSmall,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          cursorColor: colors.brand,
          style: poppinsRegular.copyWith(color: colors.heading),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: colors.softSurface,
            hintText: hint,
            hintStyle:
                poppinsRegular.copyWith(color: colors.body.withValues(alpha: 0.7)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
              vertical: Dimensions.paddingSizeDefault,
            ),
            border: border(colors.border),
            enabledBorder: border(colors.border),
            focusedBorder: border(colors.brand, 1.5),
            errorBorder: border(Colors.redAccent),
            focusedErrorBorder: border(Colors.redAccent, 1.5),
            errorStyle: poppinsRegular.copyWith(
              color: Colors.redAccent,
              fontSize: Dimensions.fontSizeExtraSmall + 1,
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Full-width location / directions card (stands in for a live map)
// =============================================================================
class _LocationCard extends StatelessWidget {
  const _LocationCard();

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final config =
        Provider.of<SplashProvider>(context, listen: false).configModel;
    final String address = config?.ecommerceAddress ?? '';

    return Container(
      width: double.infinity,
      decoration: _premiumCard(context),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            color: colors.softSurface,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 64,
                  width: 64,
                  decoration: BoxDecoration(
                    color: colors.brand,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colors.brand.withValues(alpha: 0.3),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(Icons.location_on, color: colors.onBrand, size: 32),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                Text(
                  'Craft Discount Liquors',
                  style: poppinsSemiBold.copyWith(
                    color: colors.heading,
                    fontSize: Dimensions.fontSizeLarge,
                  ),
                ),
                if (address.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      address,
                      textAlign: TextAlign.center,
                      style: poppinsRegular.copyWith(
                        color: colors.body,
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PillButton(
                  label: 'OPEN IN GOOGLE MAPS',
                  icon: Icons.map_outlined,
                  filled: true,
                  onTap: () => _launch(_mapsUrl(address)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Premium button (filled / outlined, hover-animated)
// =============================================================================
class _PillButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final bool fullWidth;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final bool solid = widget.filled || _hovered;
    final Color fg = solid ? colors.onBrand : colors.brand;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 52,
          width: widget.fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: solid ? colors.brand : colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.brand, width: 1.5),
            boxShadow: solid
                ? [
                    BoxShadow(
                      color: colors.brand.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, size: 18, color: fg),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                widget.label,
                style: poppinsSemiBold.copyWith(
                  color: fg,
                  fontSize: Dimensions.fontSizeDefault,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
