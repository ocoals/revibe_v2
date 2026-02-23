import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../data/models/gap_item.dart';
import '../providers/recreation_provider.dart';
import 'widgets/matched_item_card.dart';
import 'widgets/gap_item_card.dart';
import 'gap_analysis_sheet.dart';

/// S11: Look recreation result
class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.recreationId});

  final String recreationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recreationAsync = ref.watch(recreationByIdProvider(recreationId));

    return recreationAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('룩 재현 결과')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('룩 재현 결과')),
        body: Center(child: Text('오류가 발생했어요: $e')),
      ),
      data: (recreation) {
        final score = recreation.overallScore;
        final scoreColor = score >= 70
            ? AppColors.success
            : score >= 50
                ? AppColors.warning
                : AppColors.error;

        return Scaffold(
          appBar: AppBar(
            title: const Text('룩 재현 결과'),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '매칭 $score%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Side-by-side comparison
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reference image
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '레퍼런스',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBody,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: recreation.referenceImageUrl,
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: (_, _) => Container(
                                height: 220,
                                color: AppColors.chipInactive,
                              ),
                              errorWidget: (_, _, _) => Container(
                                height: 220,
                                color: AppColors.chipInactive,
                                child: const Icon(Icons.image, size: 48),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // My recreation
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '내 재현 ✨',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textBody,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (recreation.matchedItems.isEmpty)
                            Container(
                              height: 220,
                              decoration: BoxDecoration(
                                color: AppColors.chipInactive,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: Text(
                                  '매칭 아이템 없음',
                                  style: TextStyle(color: AppColors.textCaption),
                                ),
                              ),
                            )
                          else
                            SizedBox(
                              height: 220,
                              child: GridView.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 4,
                                crossAxisSpacing: 4,
                                physics: const NeverScrollableScrollPhysics(),
                                children: recreation.matchedItems
                                    .take(4)
                                    .map((m) => ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                m.wardrobeItem.imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (_, _) =>
                                                Container(
                                                    color: AppColors
                                                        .chipInactive),
                                            errorWidget: (_, _, _) =>
                                                Container(
                                                    color: AppColors
                                                        .chipInactive,
                                                    child: const Icon(
                                                        Icons.image)),
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // All gap -> CTA
                if (recreation.matchedItems.isEmpty &&
                    recreation.gapItems.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.gapCardBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '아직 매칭되는 아이템이 없어요',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textTitle,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '옷장에 아이템을 추가하면 더 정확한 매칭이 가능해요',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textCaption,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.go('/wardrobe/add'),
                          child: const Text('옷장에 추가하기'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Matched items
                if (recreation.matchedItems.isNotEmpty) ...[
                  const Text(
                    '아이템 매칭 상세',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...recreation.matchedItems.map((matched) {
                    final refItem = recreation.referenceAnalysis.items
                        .where((r) => r.index == matched.refIndex)
                        .firstOrNull;
                    final refDesc = refItem != null
                        ? '${refItem.color.name} ${refItem.subcategory ?? refItem.category}'
                        : '';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: MatchedItemCard(
                        matchedItem: matched,
                        refDescription: refDesc,
                        onTap: () => context.push(
                          '/wardrobe/${matched.wardrobeItem.id}',
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                ],

                // Gap items
                if (recreation.gapItems.isNotEmpty) ...[
                  const Text(
                    '갭 아이템',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textTitle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...recreation.gapItems.map((gap) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GapItemCard(
                          gapItem: gap,
                          onFindTap: () => _showGapSheet(context, gap),
                        ),
                      )),
                ],
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Save image (Phase 2)
                      },
                      icon: const Icon(Icons.save_alt),
                      label: const Text('이미지 저장'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Share (Phase 2)
                      },
                      icon: const Icon(Icons.share),
                      label: const Text('공유하기'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showGapSheet(BuildContext context, GapItem gapItem) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => GapAnalysisSheet(gapItem: gapItem),
    );
  }
}
