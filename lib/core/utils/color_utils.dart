import 'dart:math';
import 'dart:ui';

/// HSL representation
class HslColorData {
  final double h; // 0-360
  final double s; // 0-100
  final double l; // 0-100

  const HslColorData(this.h, this.s, this.l);

  Map<String, int> toJson() => {
        'h': h.round(),
        's': s.round(),
        'l': l.round(),
      };
}

/// Korean color name mapping based on TDD Section 7.4
class ColorUtils {
  ColorUtils._();

  /// Convert hex string (#RRGGBB) to RGB
  static (int r, int g, int b) hexToRgb(String hex) {
    final h = hex.replaceAll('#', '');
    return (
      int.parse(h.substring(0, 2), radix: 16),
      int.parse(h.substring(2, 4), radix: 16),
      int.parse(h.substring(4, 6), radix: 16),
    );
  }

  /// Convert RGB to HSL
  static HslColorData rgbToHsl(int r, int g, int b) {
    final rf = r / 255.0;
    final gf = g / 255.0;
    final bf = b / 255.0;

    final maxVal = [rf, gf, bf].reduce(max);
    final minVal = [rf, gf, bf].reduce(min);
    final delta = maxVal - minVal;

    double h = 0;
    double s = 0;
    final l = (maxVal + minVal) / 2;

    if (delta != 0) {
      s = l > 0.5 ? delta / (2 - maxVal - minVal) : delta / (maxVal + minVal);

      if (maxVal == rf) {
        h = ((gf - bf) / delta + (gf < bf ? 6 : 0)) * 60;
      } else if (maxVal == gf) {
        h = ((bf - rf) / delta + 2) * 60;
      } else {
        h = ((rf - gf) / delta + 4) * 60;
      }
    }

    return HslColorData(h, s * 100, l * 100);
  }

  /// Convert hex to HSL
  static HslColorData hexToHsl(String hex) {
    final (r, g, b) = hexToRgb(hex);
    return rgbToHsl(r, g, b);
  }

  /// Get Korean color name from HSL values
  /// Based on TDD Section 7.4.1 ~ 7.4.4
  static String getKoreanColorName(double h, double s, double l) {
    // 7.4.1: Achromatic check (saturation < 10%)
    if (s < 10) {
      return _getAchromaticName(h, s, l);
    }

    // 7.4.2: Special cases for beige/ivory (low saturation, high lightness)
    if (s >= 10 && s <= 30 && l > 70) {
      if (h >= 30 && h <= 50) {
        if (l >= 85 && l <= 95) return '아이보리';
        if (l >= 70 && l <= 90) return '베이지';
      }
    }

    // 7.4.3: Chromatic color mapping
    String baseName = _getChromaticName(h, s, l);

    // 7.4.4: Lightness prefix
    if (baseName.isNotEmpty) {
      // Specific colors with standard ranges
      final standardRange = _getStandardLightnessRange(baseName);
      if (standardRange != null) {
        if (l > standardRange.$2) return '라이트$baseName';
        if (l < standardRange.$1) return '다크$baseName';
      }
    }

    return baseName.isEmpty ? '그레이' : baseName;
  }

  static String _getAchromaticName(double h, double s, double l) {
    // Check ivory (has slight hue)
    if (s >= 10 && s <= 30 && h >= 30 && h <= 50 && l >= 85 && l <= 95) {
      return '아이보리';
    }

    if (l >= 90) return '화이트';
    if (l >= 70) return '라이트그레이';
    if (l >= 40) return '그레이';
    if (l >= 15) return '차콜';
    return '블랙';
  }

  static String _getChromaticName(double h, double s, double l) {
    // Wine: dark reds
    if ((h >= 340 || h <= 10) && l >= 15 && l < 35 && s >= 30) return '와인';

    // Coral: light reds
    if (h >= 0 && h <= 20 && l >= 60 && l <= 80 && s >= 40) return '코랄';

    // Red
    if ((h >= 350 || h <= 10) && l >= 30 && l <= 60 && s >= 50) return '레드';

    // Brown
    if (h >= 15 && h <= 40 && l >= 15 && l <= 40 && s >= 30) return '브라운';

    // Orange
    if (h >= 20 && h <= 40 && l >= 40 && l <= 70 && s >= 50) return '오렌지';

    // Cream
    if (h >= 30 && h <= 50 && l >= 88 && l <= 98 && s >= 20 && s <= 60) {
      return '크림';
    }

    // Beige
    if (h >= 30 && h <= 50 && l >= 70 && l <= 90 && s >= 15 && s <= 40) {
      return '베이지';
    }

    // Mustard
    if (h >= 40 && h <= 55 && l >= 35 && l <= 55 && s >= 40) return '머스타드';

    // Yellow
    if (h >= 50 && h <= 65 && l >= 45 && l <= 75 && s >= 50) return '옐로우';

    // Khaki
    if (h >= 60 && h <= 100 && l >= 25 && l <= 45 && s >= 15 && s <= 40) {
      return '카키';
    }

    // Lime
    if (h >= 65 && h <= 90 && l >= 40 && l <= 70 && s >= 40) return '라임';

    // Green
    if (h >= 90 && h <= 160 && l >= 25 && l <= 60 && s >= 30) return '그린';

    // Mint
    if (h >= 150 && h <= 180 && l >= 65 && l <= 85 && s >= 30) return '민트';

    // Sky blue
    if (h >= 190 && h <= 210 && l >= 60 && l <= 80 && s >= 40) return '스카이블루';

    // Blue
    if (h >= 210 && h <= 240 && l >= 35 && l <= 60 && s >= 40) return '블루';

    // Navy
    if (h >= 210 && h <= 250 && l >= 10 && l < 35 && s >= 25) return '네이비';

    // Lavender
    if (h >= 260 && h <= 290 && l >= 60 && l <= 80 && s >= 30) return '라벤더';

    // Purple
    if (h >= 260 && h <= 300 && l >= 20 && l <= 55 && s >= 30) return '퍼플';

    // Pink
    if (h >= 310 && h <= 350 && l >= 60 && l <= 85 && s >= 30) return '핑크';

    // Fallback: find closest hue match
    return _closestHueName(h);
  }

  static String _closestHueName(double h) {
    if (h < 15) return '레드';
    if (h < 40) return '오렌지';
    if (h < 65) return '옐로우';
    if (h < 90) return '라임';
    if (h < 160) return '그린';
    if (h < 190) return '민트';
    if (h < 240) return '블루';
    if (h < 300) return '퍼플';
    if (h < 340) return '핑크';
    return '레드';
  }

  /// Get standard lightness range for a color name
  /// Returns (lowThreshold, highThreshold) or null
  static (double, double)? _getStandardLightnessRange(String name) {
    return switch (name) {
      '블루' => (35.0, 60.0),
      '그린' => (25.0, 60.0),
      '핑크' => (60.0, 85.0),
      '브라운' => (15.0, 40.0),
      '퍼플' => (20.0, 55.0),
      _ => null,
    };
  }

  /// Get Korean color name from hex string
  static String hexToKoreanName(String hex) {
    final hsl = hexToHsl(hex);
    return getKoreanColorName(hsl.h, hsl.s, hsl.l);
  }

  /// Convert hex string (#RRGGBB) to Flutter Color
  static Color hexToColor(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}
