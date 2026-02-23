interface Deeplinks {
  musinsa: string;
  ably: string;
  zigzag: string;
}

export function generateDeeplinks(keywords: string): Deeplinks {
  const encoded = encodeURIComponent(keywords);
  return {
    musinsa: `https://www.musinsa.com/search/musinsa/goods?q=${encoded}`,
    ably: `https://m.a-bly.com/search?keyword=${encoded}`,
    zigzag: `https://zigzag.kr/search?keyword=${encoded}`,
  };
}
