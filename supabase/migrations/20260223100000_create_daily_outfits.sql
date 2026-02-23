-- F5: Daily Outfit Record
-- daily_outfits: 날짜별 코디 기록
CREATE TABLE public.daily_outfits (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  outfit_date DATE NOT NULL,
  image_url   TEXT,
  notes       TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (user_id, outfit_date)
);

-- outfit_items: 코디에 포함된 아이템들 (N:M)
CREATE TABLE public.outfit_items (
  outfit_id UUID NOT NULL REFERENCES daily_outfits(id) ON DELETE CASCADE,
  item_id   UUID NOT NULL REFERENCES wardrobe_items(id) ON DELETE CASCADE,
  position  INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (outfit_id, item_id)
);

-- RLS
ALTER TABLE public.daily_outfits ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own daily outfits"
  ON public.daily_outfits FOR ALL
  USING (auth.uid() = user_id);

ALTER TABLE public.outfit_items ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users manage own outfit items"
  ON public.outfit_items FOR ALL
  USING (outfit_id IN (SELECT id FROM daily_outfits WHERE user_id = auth.uid()));

-- Index for calendar queries
CREATE INDEX idx_daily_outfits_user_date
  ON public.daily_outfits (user_id, outfit_date);

-- RPC: increment wear_count and update last_worn_at atomically
CREATE OR REPLACE FUNCTION public.increment_wear_count(
  p_item_id UUID,
  p_worn_date DATE
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.wardrobe_items
  SET
    wear_count = wear_count + 1,
    last_worn_at = GREATEST(COALESCE(last_worn_at, '1970-01-01'::TIMESTAMPTZ), p_worn_date::TIMESTAMPTZ),
    updated_at = now()
  WHERE id = p_item_id
    AND user_id = auth.uid();
END;
$$;
