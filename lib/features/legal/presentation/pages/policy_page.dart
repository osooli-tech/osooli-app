import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../legal_content.dart';
import '../controllers/legal_controller.dart';

/// Renders the CMS-managed privacy policy or terms of use (fetched from the
/// dashboard's API), falling back to the bundled static text when offline.
/// Route argument: {'type': 'privacy' | 'terms'}.
class PolicyPage extends GetView<LegalController> {
  const PolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isPrivacy = controller.documentKey == 'privacy';
    final fallbackTitle = isPrivacy ? 'privacy_policy'.tr : 'terms_of_use'.tr;

    return Scaffold(
      body: Obx(() {
        final document = controller.document.value;
        final title = document?.title ?? fallbackTitle;

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 130,
              backgroundColor: AppColors.primary,
              iconTheme: const IconThemeData(color: Colors.white),
              centerTitle: true,
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(color: AppColors.primary),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        isPrivacy
                            ? Icons.privacy_tip_outlined
                            : Icons.gavel_outlined,
                        color: Colors.white.withValues(alpha: .85),
                        size: 30,
                      ),
                      if (document != null &&
                          document.updatedDate.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          '${'last_updated'.tr}: ${document.updatedDate}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: .75),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (controller.isLoading.value)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .05),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: document != null
                      ? _HtmlContent(html: document.contentHtml)
                      : _StaticFallback(isPrivacy: isPrivacy),
                ),
              ),
          ],
        );
      }),
    );
  }
}

/// Styled HTML renderer — headings in brand navy with a teal accent bar,
/// comfortable Arabic line-height, brand bullets.
class _HtmlContent extends StatelessWidget {
  final String html;
  const _HtmlContent({required this.html});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      html,
      textStyle: const TextStyle(
        fontFamily: 'Tajawal',
        fontSize: 14.5,
        height: 1.9,
        color: AppColors.textSoft,
      ),
      customStylesBuilder: (element) {
        switch (element.localName) {
          case 'h2':
          case 'h3':
            return {
              'color': '#062A5B',
              'font-size': element.localName == 'h2' ? '17px' : '15px',
              'font-weight': '700',
              'margin': '18px 0 6px 0',
              'padding-inline-start': '10px',
              'border-inline-start': '3px solid #14605C',
            };
          case 'strong':
          case 'b':
            return {'color': '#062A5B'};
          case 'ul':
          case 'ol':
            return {'margin': '4px 0', 'padding-inline-start': '18px'};
          case 'li':
            return {'margin': '4px 0'};
          case 'a':
            return {'color': '#00775A'};
        }
        return null;
      },
    );
  }
}

/// The bundled static text, used when the API is unreachable.
class _StaticFallback extends StatelessWidget {
  final bool isPrivacy;
  const _StaticFallback({required this.isPrivacy});

  @override
  Widget build(BuildContext context) {
    final sections = isPrivacy ? LegalContent.privacy : LegalContent.terms;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final section in sections) ...[
          Container(
            padding: const EdgeInsetsDirectional.only(start: 10),
            decoration: const BoxDecoration(
              border: BorderDirectional(
                start: BorderSide(color: AppColors.teal, width: 3),
              ),
            ),
            child: Text(
              section.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            section.body,
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.9,
              color: AppColors.textSoft,
            ),
          ),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}
