import 'package:flutter/material.dart';
import 'package:craft_discount_liquors/common/enums/footer_type_enum.dart';
import 'package:craft_discount_liquors/common/widgets/custom_image_widget.dart';
import 'package:craft_discount_liquors/common/widgets/footer_web_widget.dart';
import 'package:craft_discount_liquors/helper/responsive_helper.dart';
import 'package:craft_discount_liquors/helper/route_helper.dart';
import 'package:craft_discount_liquors/utill/app_colors.dart';
import 'package:craft_discount_liquors/utill/dimensions.dart';
import 'package:craft_discount_liquors/utill/images.dart';
import 'package:craft_discount_liquors/utill/styles.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher_string.dart';

/// Single parsed or default FAQ item representation.
class FaqItem {
  final String question;
  final String answerHtml;
  final String category;

  const FaqItem({
    required this.question,
    required this.answerHtml,
    required this.category,
  });
}

/// Helper utility to parse CMS HTML content into structured [FaqItem]s.
class FaqParser {
  static List<FaqItem> parseFaqContent(String rawHtml) {
    if (rawHtml.trim().isEmpty) {
      return _defaultCraftFaqs;
    }

    final dom.Document document = html_parser.parse(rawHtml);
    final List<FaqItem> items = [];

    // 1. Check for <details> / <summary> structure
    final detailsElements = document.querySelectorAll('details');
    if (detailsElements.isNotEmpty) {
      for (final details in detailsElements) {
        final summary = details.querySelector('summary');
        final question = summary?.text.trim() ?? '';
        summary?.remove();
        final answer = details.innerHtml.trim();
        if (question.isNotEmpty) {
          items.add(FaqItem(
            question: question,
            answerHtml: answer.isNotEmpty ? answer : '<p>$question</p>',
            category: _categorize(question, answer),
          ));
        }
      }
      if (items.isNotEmpty) return items;
    }

    // 2. Check for heading tags (h1, h2, h3, h4, h5, h6, dt)
    final nodes = document.body?.children ?? [];
    String currentQuestion = '';
    final List<String> currentAnswerNodes = [];

    void flushItem() {
      if (currentQuestion.isNotEmpty) {
        final answerHtml = currentAnswerNodes.join().trim();
        items.add(FaqItem(
          question: currentQuestion,
          answerHtml: answerHtml.isNotEmpty
              ? answerHtml
              : '<p>Please contact our support team for details regarding this question.</p>',
          category: _categorize(currentQuestion, answerHtml),
        ));
        currentQuestion = '';
        currentAnswerNodes.clear();
      }
    }

    for (final node in nodes) {
      final tag = node.localName?.toLowerCase() ?? '';
      final text = node.text.trim();

      final bool isHeaderTag = ['h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'dt'].contains(tag);
      final bool isStrongP = tag == 'p' &&
          (node.querySelector('strong') != null || node.querySelector('b') != null) &&
          text.length <= 140;
      final bool startsWithQ = text.startsWith(RegExp(r'^(Q[:.]|\d+[\.\)])', caseSensitive: false)) ||
          (text.endsWith('?') && text.length <= 140);

      if (isHeaderTag || isStrongP || startsWithQ) {
        flushItem();
        currentQuestion = text.replaceAll(RegExp(r'^(Q[:.]\s*|\d+[\.\)]\s*)', caseSensitive: false), '').trim();
      } else if (currentQuestion.isNotEmpty) {
        currentAnswerNodes.add(node.outerHtml);
      }
    }
    flushItem();

    if (items.isNotEmpty) return items;

    // 3. Fallback: If rawHtml contains text but could not be split into structured Q&As,
    // split by paragraphs or return default list merged with parsed text.
    final paragraphs = document.querySelectorAll('p');
    if (paragraphs.length >= 2) {
      for (int i = 0; i < paragraphs.length; i += 2) {
        final q = paragraphs[i].text.trim();
        final a = (i + 1 < paragraphs.length) ? paragraphs[i + 1].outerHtml : '<p></p>';
        if (q.isNotEmpty) {
          items.add(FaqItem(
            question: q,
            answerHtml: a,
            category: _categorize(q, a),
          ));
        }
      }
    }

    return items.isNotEmpty ? items : _defaultCraftFaqs;
  }

  static String _categorize(String question, String answer) {
    final combined = '$question $answer'.toLowerCase();
    if (combined.contains('order') || combined.contains('cart') || combined.contains('buy') || combined.contains('track')) {
      return 'Orders';
    }
    if (combined.contains('deliver') || combined.contains('ship') || combined.contains('courier') || combined.contains('hour') || combined.contains('time') || combined.contains('address')) {
      return 'Delivery';
    }
    if (combined.contains('pay') || combined.contains('card') || combined.contains('credit') || combined.contains('cash') || combined.contains('price') || combined.contains('billing')) {
      return 'Payments';
    }
    if (combined.contains('return') || combined.contains('refund') || combined.contains('damaged') || combined.contains('exchange') || combined.contains('policy')) {
      return 'Returns';
    }
    if (combined.contains('account') || combined.contains('age') || combined.contains('id') || combined.contains('verification') || combined.contains('login') || combined.contains('profile')) {
      return 'Account';
    }
    return 'General';
  }

  static const List<FaqItem> _defaultCraftFaqs = [
    FaqItem(
      category: 'General',
      question: 'What is Craft Liquors?',
      answerHtml:
          '<p>Craft Liquors is your premier online destination for fine wines, craft beers, artisanal spirits, and luxury beverages. We offer a curated selection delivered directly to your doorstep with exceptional customer care.</p>',
    ),
    FaqItem(
      category: 'Account',
      question: 'Is age verification required to place an order?',
      answerHtml:
          '<p>Yes, in accordance with applicable laws, all purchases containing alcoholic beverages require age verification. Buyers and recipients must be of legal drinking age (21+) and present a valid government-issued ID upon delivery.</p>',
    ),
    FaqItem(
      category: 'Orders',
      question: 'How do I place and track my order?',
      answerHtml:
          '<p>Simply browse our online catalog, select your items, and proceed to checkout. Once your order is placed, you can track its real-time status under the <b>My Orders</b> section in your account profile.</p>',
    ),
    FaqItem(
      category: 'Delivery',
      question: 'What are your delivery hours and coverage areas?',
      answerHtml:
          '<p>We offer fast, reliable local delivery and standard shipping depending on your location. Delivery hours are typically between 10:00 AM and 10:00 PM. Enter your postal code at checkout to confirm available delivery slots.</p>',
    ),
    FaqItem(
      category: 'Payments',
      question: 'What payment methods do you accept?',
      answerHtml:
          '<p>We accept major credit cards (Visa, MasterCard, American Express), digital wallets, and cash on delivery for supported local delivery routes. All online transactions are processed through end-to-end encrypted gateways.</p>',
    ),
    FaqItem(
      category: 'Returns',
      question: 'What is your return and refund policy?',
      answerHtml:
          '<p>If your package arrives damaged, defective, or incorrect, please notify our customer support within 48 hours of receipt. We will arrange a replacement or issue a full refund to your original payment method.</p>',
    ),
    FaqItem(
      category: 'Orders',
      question: 'Can I modify or cancel my order after placing it?',
      answerHtml:
          '<p>Orders can be modified or canceled before they enter the processing and dispatch stage. Please contact our support team immediately or use the cancel order feature in your order details page.</p>',
    ),
    FaqItem(
      category: 'Delivery',
      question: 'What happens if I am not home at the time of delivery?',
      answerHtml:
          '<p>Because alcohol deliveries require an adult signature (21+ with ID), our courier cannot leave packages unattended. If no eligible adult is available, our delivery driver will attempt a re-delivery or contact you to arrange a suitable time.</p>',
    ),
  ];
}

/// Premium presentation widget for the Craft Liquors Help Center FAQ Page.
class FaqPageViewWidget extends StatefulWidget {
  final String htmlDescription;
  final String imageUrl;

  const FaqPageViewWidget({
    super.key,
    required this.htmlDescription,
    this.imageUrl = '',
  });

  @override
  State<FaqPageViewWidget> createState() => _FaqPageViewWidgetState();
}

class _FaqPageViewWidgetState extends State<FaqPageViewWidget> {
  String _selectedCategory = 'All';
  final Set<int> _expandedIndices = {};

  late List<FaqItem> _allFaqs;

  @override
  void initState() {
    super.initState();
    _allFaqs = FaqParser.parseFaqContent(widget.htmlDescription);
  }

  @override
  void didUpdateWidget(covariant FaqPageViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.htmlDescription != widget.htmlDescription) {
      setState(() {
        _allFaqs = FaqParser.parseFaqContent(widget.htmlDescription);
        _expandedIndices.clear();
      });
    }
  }

  List<String> get _categories {
    final set = {'All'};
    for (final item in _allFaqs) {
      set.add(item.category);
    }
    return set.toList();
  }

  List<FaqItem> get _filteredFaqs {
    return _allFaqs.where((faq) {
      return _selectedCategory == 'All' || faq.category == _selectedCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredFaqs;
    final categoriesList = _categories;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // 1. Page Hero Header
          const _FaqHeroHeader(),

          // 2. Hero Banner Image Frame
          _constrained(
            _FaqHeroBanner(imageUrl: widget.imageUrl),
            maxWidth: 1100,
          ),

          // Balanced vertical spacing between hero banner and FAQ list/categories
          const SizedBox(height: 36),

          // 3. Category Filter Chips (shown when multiple categories exist)
          if (categoriesList.length > 2)
            _constrained(
              _CategoryChips(
                categories: categoriesList,
                selectedCategory: _selectedCategory,
                onCategorySelected: (cat) {
                  setState(() {
                    _selectedCategory = cat;
                    _expandedIndices.clear();
                  });
                },
              ),
              maxWidth: 960,
            ),

          if (categoriesList.length > 2)
            const SizedBox(height: Dimensions.paddingSizeLarge),

          // 4. FAQ Accordion List
          _constrained(
            _FadeInUp(
              child: filtered.isNotEmpty
                  ? _buildFaqContent(filtered)
                  : _EmptyState(
                      onReset: () {
                        setState(() {
                          _selectedCategory = 'All';
                        });
                      },
                    ),
            ),
            maxWidth: 960,
          ),

          const SizedBox(height: Dimensions.paddingSizeExtraLarge + 10),

          // 5. Bottom Support CTA Card
          _constrained(
            const _SupportCtaCard(),
            maxWidth: 960,
          ),

          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          // 6. Web Footer
          const FooterWebWidget(footerType: FooterType.nonSliver),
        ],
      ),
    );
  }

  Widget _buildFaqContent(List<FaqItem> faqs) {
    // If selected category is 'All', group by category headers
    if (_selectedCategory == 'All') {
      final Map<String, List<FaqItem>> grouped = {};
      for (final item in faqs) {
        grouped.putIfAbsent(item.category, () => []).add(item);
      }

      int globalIndex = 0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: grouped.entries.map((entry) {
          final categoryName = entry.key;
          final categoryItems = entry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategorySectionTitle(title: categoryName),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              ...categoryItems.map((faq) {
                final idx = globalIndex++;
                final isExpanded = _expandedIndices.contains(idx);
                return Padding(
                  padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
                  child: _FaqAccordionCard(
                    faq: faq,
                    isExpanded: isExpanded,
                    onToggle: () {
                      setState(() {
                        if (isExpanded) {
                          _expandedIndices.remove(idx);
                        } else {
                          _expandedIndices.add(idx);
                        }
                      });
                    },
                  ),
                );
              }),
              const SizedBox(height: Dimensions.paddingSizeLarge),
            ],
          );
        }).toList(),
      );
    }

    // Single list view when category filter is active
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        final faq = faqs[index];
        final isExpanded = _expandedIndices.contains(index);
        return Padding(
          padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeDefault),
          child: _FaqAccordionCard(
            faq: faq,
            isExpanded: isExpanded,
            onToggle: () {
              setState(() {
                if (isExpanded) {
                  _expandedIndices.remove(index);
                } else {
                  _expandedIndices.add(index);
                }
              });
            },
          ),
        );
      },
    );
  }
}

// -----------------------------------------------------------------------------
// Helper Container
// -----------------------------------------------------------------------------
Widget _constrained(Widget child, {double maxWidth = 1100}) => Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeLarge,
          ),
          child: child,
        ),
      ),
    );

/// Hex string helper for html widget inline styling.
String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

/// Smooth upward entrance motion.
class _FadeInUp extends StatelessWidget {
  final Widget child;
  const _FadeInUp({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOut,
      builder: (context, t, c) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 14), child: c),
      ),
      child: child,
    );
  }
}

// -----------------------------------------------------------------------------
// 1. Page Hero Header
// -----------------------------------------------------------------------------
class _FaqHeroHeader extends StatelessWidget {
  const _FaqHeroHeader();

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: double.infinity,
      color: c.surface,
      padding: EdgeInsets.symmetric(
        vertical: isDesktop ? 54 : 36,
        horizontal: Dimensions.paddingSizeLarge,
      ),
      child: Column(
        children: [
          // Tag badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: c.softSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.brand.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.help_center_outlined, size: 16, color: c.brand),
                const SizedBox(width: 6),
                Text(
                  'HELP CENTER',
                  style: poppinsSemiBold.copyWith(
                    color: c.brand,
                    fontSize: 12,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Main Heading
          Text(
            'Frequently Asked Questions',
            textAlign: TextAlign.center,
            style: poppinsBold.copyWith(
              color: c.heading,
              fontSize: isDesktop ? 34 : 24,
              letterSpacing: 0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Accent bar
          Container(
            width: 64,
            height: 3.5,
            decoration: BoxDecoration(
              color: c.brand,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          // Subtitle
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Text(
              'Find answers to the most common questions about orders, delivery, payments, returns, and your Craft Liquors account.',
              textAlign: TextAlign.center,
              style: poppinsRegular.copyWith(
                color: c.body,
                fontSize: isDesktop ? Dimensions.fontSizeLarge : Dimensions.fontSizeDefault,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. Hero Banner Image
// -----------------------------------------------------------------------------
class _FaqHeroBanner extends StatelessWidget {
  final String imageUrl;
  const _FaqHeroBanner({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bool isDesktop = ResponsiveHelper.isDesktop(context);
    final double height = isDesktop ? 220 : 150;

    return Padding(
      padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: c.shadow,
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image source: backend network URL or high-res local banner asset
              if (imageUrl.trim().isNotEmpty)
                CustomImageWidget(image: imageUrl, fit: BoxFit.cover)
              else
                Image.asset(
                  Images.helpCenterBanner,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [c.darkPanel, c.brandDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),

              // Gradient Scrim Overlay
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.75),
                      Colors.black.withValues(alpha: 0.40),
                    ],
                  ),
                ),
              ),

              // Content Overlay Caption
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeExtraLarge,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: c.brand.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeLarge),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Craft Liquors Support Hub',
                            style: poppinsBold.copyWith(
                              color: c.onDarkPanel,
                              fontSize: isDesktop ? 22 : 17,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "We're here to help make your shopping & delivery experience seamless.",
                            style: poppinsRegular.copyWith(
                              color: c.onDarkPanel.withValues(alpha: 0.90),
                              fontSize: isDesktop
                                  ? Dimensions.fontSizeDefault
                                  : Dimensions.fontSizeSmall,
                                  height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Category Chips
// -----------------------------------------------------------------------------
class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const _CategoryChips({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  IconData _iconForCategory(String cat) {
    switch (cat) {
      case 'Orders':
        return Icons.shopping_bag_outlined;
      case 'Delivery':
        return Icons.local_shipping_outlined;
      case 'Payments':
        return Icons.credit_card_outlined;
      case 'Returns':
        return Icons.assignment_return_outlined;
      case 'Account':
        return Icons.person_outline_rounded;
      default:
        return Icons.apps_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: categories.map((cat) {
        final isSelected = cat == selectedCategory;
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => onCategorySelected(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? c.brand : c.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? c.brand : c.border,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: c.brand.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: c.shadow,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _iconForCategory(cat),
                    size: 16,
                    color: isSelected ? c.onBrand : c.body,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    cat,
                    style: isSelected
                        ? poppinsSemiBold.copyWith(
                            color: c.onBrand,
                            fontSize: Dimensions.fontSizeDefault,
                          )
                        : poppinsMedium.copyWith(
                            color: c.heading,
                            fontSize: Dimensions.fontSizeDefault,
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// -----------------------------------------------------------------------------
// Category Section Header
// -----------------------------------------------------------------------------
class _CategorySectionTitle extends StatelessWidget {
  final String title;
  const _CategorySectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(
        top: Dimensions.paddingSizeDefault,
        bottom: Dimensions.paddingSizeSmall,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: c.brand,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: poppinsBold.copyWith(
              color: c.heading,
              fontSize: Dimensions.fontSizeExtraLarge,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. Accordion FAQ Card
// -----------------------------------------------------------------------------
class _FaqAccordionCard extends StatefulWidget {
  final FaqItem faq;
  final bool isExpanded;
  final VoidCallback onToggle;

  const _FaqAccordionCard({
    required this.faq,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  State<_FaqAccordionCard> createState() => _FaqAccordionCardState();
}

class _FaqAccordionCardState extends State<_FaqAccordionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isExpanded = widget.isExpanded;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isExpanded
                  ? c.brand.withValues(alpha: 0.45)
                  : (_hovered ? c.brand.withValues(alpha: 0.25) : c.border),
              width: isExpanded ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isExpanded
                    ? c.brand.withValues(alpha: 0.08)
                    : (_hovered ? c.shadow : c.shadow),
                blurRadius: _hovered || isExpanded ? 24 : 14,
                offset: Offset(0, _hovered || isExpanded ? 10 : 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Question + Category Badge + Expand Icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: c.softSurface,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              widget.faq.category.toUpperCase(),
                              style: poppinsSemiBold.copyWith(
                                color: c.brand,
                                fontSize: 11,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Question Text
                          Text(
                            widget.faq.question,
                            style: poppinsSemiBold.copyWith(
                              color: isExpanded ? c.brand : c.heading,
                              fontSize: Dimensions.fontSizeLarge,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeDefault),

                    // Expand/Collapse Icon Button
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? c.brand
                            : c.softSurface,
                        shape: BoxShape.circle,
                      ),
                      child: AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isExpanded ? c.onBrand : c.brand,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),

                // Expandable Answer Section
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: Dimensions.paddingSizeLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(color: c.divider, height: 1),
                        const SizedBox(height: Dimensions.paddingSizeLarge),
                        HtmlWidget(
                          widget.faq.answerHtml,
                          textStyle: poppinsRegular.copyWith(
                            color: c.body,
                            fontSize: Dimensions.fontSizeDefault,
                            height: 1.7,
                          ),
                          customStylesBuilder: (element) {
                            switch (element.localName) {
                              case 'a':
                                return {'color': _hex(c.brand), 'font-weight': '600'};
                              case 'p':
                                return {
                                  'color': _hex(c.body),
                                  'line-height': '1.7',
                                  'margin-bottom': '8px',
                                };
                              case 'li':
                                return {
                                  'color': _hex(c.body),
                                  'line-height': '1.7',
                                  'margin-bottom': '6px',
                                };
                              default:
                                return {'color': _hex(c.body)};
                            }
                          },
                          onTapUrl: (url) => launchUrlString(url),
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 280),
                  sizeCurve: Curves.easeOutCubic,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Empty Category State
// -----------------------------------------------------------------------------
class _EmptyState extends StatelessWidget {
  final VoidCallback onReset;

  const _EmptyState({
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: c.softSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.quiz_outlined,
              size: 48,
              color: c.brand,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Text(
            'No FAQs Available',
            style: poppinsBold.copyWith(
              color: c.heading,
              fontSize: Dimensions.fontSizeExtraLarge,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No questions are currently listed under this category.',
            textAlign: TextAlign.center,
            style: poppinsRegular.copyWith(
              color: c.body,
              fontSize: Dimensions.fontSizeDefault,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          ElevatedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Show All FAQs'),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.brand,
              foregroundColor: c.onBrand,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 5. Bottom Support CTA Card
// -----------------------------------------------------------------------------
class _SupportCtaCard extends StatelessWidget {
  const _SupportCtaCard();

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final bool isDesktop = ResponsiveHelper.isDesktop(context);

    final texts = Column(
      crossAxisAlignment:
          isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Still have questions?',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: poppinsBold.copyWith(
            color: c.heading,
            fontSize: Dimensions.fontSizeExtraLarge + 2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Our support team is happy to help with orders, deliveries, and account assistance.',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: poppinsRegular.copyWith(
            color: c.body,
            fontSize: Dimensions.fontSizeDefault,
            height: 1.4,
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraLarge + 4),
      decoration: BoxDecoration(
        color: c.softSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.border),
        boxShadow: [
          BoxShadow(
            color: c.shadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(child: texts),
                const SizedBox(width: Dimensions.paddingSizeLarge),
                const _ContactButton(),
              ],
            )
          : Column(
              children: [
                texts,
                const SizedBox(height: Dimensions.paddingSizeLarge),
                const _ContactButton(),
              ],
            ),
    );
  }
}

class _ContactButton extends StatefulWidget {
  const _ContactButton();

  @override
  State<_ContactButton> createState() => _ContactButtonState();
}

class _ContactButtonState extends State<_ContactButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => RouteHelper.getContactRoute(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 26),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: c.brand,
            borderRadius: BorderRadius.circular(14),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: c.brand.withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.headset_mic_outlined, size: 18, color: c.onBrand),
              const SizedBox(width: Dimensions.paddingSizeSmall),
              Text(
                'CONTACT SUPPORT',
                style: poppinsSemiBold.copyWith(
                  color: c.onBrand,
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
