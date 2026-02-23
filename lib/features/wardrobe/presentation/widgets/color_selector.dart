import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/color_utils.dart';

/// Fashion color palette data
class FashionColor {
  final String hex;
  final String name;

  const FashionColor(this.hex, this.name);
}

const _fashionColors = [
  FashionColor('#000000', '블랙'),
  FashionColor('#FFFFFF', '화이트'),
  FashionColor('#D1D5DB', '라이트그레이'),
  FashionColor('#6B7280', '그레이'),
  FashionColor('#374151', '차콜'),
  FashionColor('#FFFFF0', '아이보리'),
  FashionColor('#F5F5DC', '베이지'),
  FashionColor('#FFFDD0', '크림'),
  FashionColor('#8B4513', '브라운'),
  FashionColor('#722F37', '와인'),
  FashionColor('#DC2626', '레드'),
  FashionColor('#FF7F50', '코랄'),
  FashionColor('#F97316', '오렌지'),
  FashionColor('#D4A017', '머스타드'),
  FashionColor('#EAB308', '옐로우'),
  FashionColor('#84CC16', '라임'),
  FashionColor('#556B2F', '카키'),
  FashionColor('#16A34A', '그린'),
  FashionColor('#2DD4BF', '민트'),
  FashionColor('#38BDF8', '스카이블루'),
  FashionColor('#2563EB', '블루'),
  FashionColor('#1E3A5F', '네이비'),
  FashionColor('#C084FC', '라벤더'),
  FashionColor('#7C3AED', '퍼플'),
  FashionColor('#EC4899', '핑크'),
];

/// Color grid selector for 25 fashion colors
class ColorSelector extends StatelessWidget {
  const ColorSelector({
    super.key,
    required this.selectedHex,
    required this.onSelected,
  });

  final String? selectedHex;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _fashionColors.map((fc) {
        final isSelected = selectedHex == fc.hex;
        final color = ColorUtils.hexToColor(fc.hex);
        final isLight = color.computeLuminance() > 0.7;

        return GestureDetector(
          onTap: () => onSelected(fc.hex),
          child: SizedBox(
            width: 56,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : (isLight ? AppColors.divider : Colors.transparent),
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: isLight ? AppColors.textTitle : Colors.white,
                          size: 18,
                        )
                      : null,
                ),
                const SizedBox(height: 4),
                Text(
                  fc.name,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? AppColors.textTitle : AppColors.textCaption,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

}
