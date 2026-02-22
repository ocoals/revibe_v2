import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/categories.dart';
import '../../../core/router/app_router.dart';

/// S06: Wardrobe Grid
class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  ItemCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('옷장'),
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.wardrobeAdd),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('전체'),
                    selected: _selectedCategory == null,
                    onSelected: (_) => setState(() => _selectedCategory = null),
                  ),
                ),
                ...ItemCategory.values.map((category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(category.korean),
                        selected: _selectedCategory == category,
                        onSelected: (_) =>
                            setState(() => _selectedCategory = category),
                      ),
                    )),
              ],
            ),
          ),

          // Free tier progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '무료 한도',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textCaption,
                      ),
                    ),
                    Text(
                      '0 / 30벌',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textCaption,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: 0,
                  backgroundColor: AppColors.divider,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),

          // Item grid (empty state)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checkroom,
                    size: 64,
                    color: AppColors.textCaption.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '아직 등록된 옷이 없어요',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBody,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '오늘 입은 옷을 찍어서 시작해보세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textCaption,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.wardrobeAdd),
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: const Text('아이템 추가'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
