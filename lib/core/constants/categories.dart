/// Category enum mapping based on TDD Section 3.4
enum ItemCategory {
  tops('tops', '상의'),
  bottoms('bottoms', '하의'),
  outerwear('outerwear', '아우터'),
  dresses('dresses', '원피스'),
  shoes('shoes', '신발'),
  bags('bags', '가방'),
  accessories('accessories', '액세서리');

  const ItemCategory(this.dbValue, this.korean);

  final String dbValue;
  final String korean;

  static ItemCategory fromDb(String value) {
    return ItemCategory.values.firstWhere((e) => e.dbValue == value);
  }
}

/// Subcategory mapping
const Map<ItemCategory, List<SubcategoryInfo>> subcategories = {
  ItemCategory.tops: [
    SubcategoryInfo('tshirt', '티셔츠'),
    SubcategoryInfo('shirt', '셔츠'),
    SubcategoryInfo('blouse', '블라우스'),
    SubcategoryInfo('knit', '니트'),
    SubcategoryInfo('sweatshirt', '맨투맨'),
    SubcategoryInfo('hoodie', '후디'),
    SubcategoryInfo('vest', '조끼'),
  ],
  ItemCategory.bottoms: [
    SubcategoryInfo('jeans', '청바지'),
    SubcategoryInfo('slacks', '슬랙스'),
    SubcategoryInfo('shorts', '반바지'),
    SubcategoryInfo('skirt', '치마'),
    SubcategoryInfo('leggings', '레깅스'),
  ],
  ItemCategory.outerwear: [
    SubcategoryInfo('jacket', '자켓'),
    SubcategoryInfo('coat', '코트'),
    SubcategoryInfo('padding', '패딩'),
    SubcategoryInfo('cardigan', '가디건'),
    SubcategoryInfo('windbreaker', '바람막이'),
  ],
  ItemCategory.dresses: [
    SubcategoryInfo('mini', '미니'),
    SubcategoryInfo('midi', '미디'),
    SubcategoryInfo('maxi', '맥시'),
    SubcategoryInfo('jumpsuit', '점프수트'),
  ],
  ItemCategory.shoes: [
    SubcategoryInfo('sneakers', '스니커즈'),
    SubcategoryInfo('boots', '부츠'),
    SubcategoryInfo('sandals', '샌들'),
    SubcategoryInfo('loafers', '로퍼'),
    SubcategoryInfo('heels', '힐'),
  ],
  ItemCategory.bags: [
    SubcategoryInfo('backpack', '백팩'),
    SubcategoryInfo('shoulder', '숄더백'),
    SubcategoryInfo('crossbody', '크로스백'),
    SubcategoryInfo('tote', '토트백'),
    SubcategoryInfo('clutch', '클러치'),
  ],
  ItemCategory.accessories: [
    SubcategoryInfo('hat', '모자'),
    SubcategoryInfo('scarf', '스카프'),
    SubcategoryInfo('belt', '벨트'),
    SubcategoryInfo('jewelry', '주얼리'),
    SubcategoryInfo('sunglasses', '선글라스'),
  ],
};

class SubcategoryInfo {
  const SubcategoryInfo(this.dbValue, this.korean);

  final String dbValue;
  final String korean;
}
