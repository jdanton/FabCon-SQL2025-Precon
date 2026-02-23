-- ============================================================================
-- 04_traditional_search.sql
-- Demonstrates the limitations of keyword-based search.
--
-- Run each query one at a time and observe the results. These are the SAME
-- questions we'll use with vector search in script 07 — the contrast is
-- the entire point of the demo.
-- ============================================================================

USE VectorF1;
GO

-- ═══════════════════════════════════════════════════════════════════════════
-- QUERY 1: "Find races where rain completely changed the outcome"
-- ═══════════════════════════════════════════════════════════════════════════

-- Attempt with LIKE — requires exact word matches
SELECT Year, RaceName, Winner, LEFT(Recap, 120) AS RecapPreview
FROM dbo.RaceRecaps
WHERE Recap LIKE '%rain%changed%'
ORDER BY Year;
-- Result: Very few matches. Misses races described as "wet-weather",
-- "downpour", "soaked", "treacherous conditions", etc.

GO

-- ═══════════════════════════════════════════════════════════════════════════
-- QUERY 2: "Find races with an incredible comeback from last place"
-- ═══════════════════════════════════════════════════════════════════════════

SELECT Year, RaceName, Winner, LEFT(Recap, 120) AS RecapPreview
FROM dbo.RaceRecaps
WHERE Recap LIKE '%comeback%' OR Recap LIKE '%last place%'
ORDER BY Year;
-- Result: Partial matches at best. Misses recaps that say "dropped to last",
-- "recovery drive", "fought through the field", or "dead last to victory".

GO

-- ═══════════════════════════════════════════════════════════════════════════
-- QUERY 3: "Find races with a heartbreaking championship defeat"
-- ═══════════════════════════════════════════════════════════════════════════

SELECT Year, RaceName, Winner, LEFT(Recap, 120) AS RecapPreview
FROM dbo.RaceRecaps
WHERE Recap LIKE '%heartbreak%championship%'
   OR Recap LIKE '%championship%heartbreak%'
ORDER BY Year;
-- Result: Almost nothing. The word "heartbreaking" may not appear even in
-- the most devastating championship losses.

GO

-- ═══════════════════════════════════════════════════════════════════════════
-- QUERY 4: "Find races where a driver survived a terrifying crash"
-- ═══════════════════════════════════════════════════════════════════════════

SELECT Year, RaceName, Winner, LEFT(Recap, 120) AS RecapPreview
FROM dbo.RaceRecaps
WHERE Recap LIKE '%terrifying%crash%'
   OR Recap LIKE '%survived%crash%'
ORDER BY Year;
-- Result: Misses Grosjean 2020 ("fireball", "inferno"), Zhou 2022
-- ("launched upside down"), Lauda 1976 ("fiery crash").

GO

-- ═══════════════════════════════════════════════════════════════════════════
-- QUERY 5: "Find controversial decisions that decided a championship"
-- ═══════════════════════════════════════════════════════════════════════════

SELECT Year, RaceName, Winner, LEFT(Recap, 120) AS RecapPreview
FROM dbo.RaceRecaps
WHERE Recap LIKE '%controversial%decision%championship%'
ORDER BY Year;
-- Result: May find Abu Dhabi 2021 if the words happen to match, but
-- misses the broader concept of "disputed outcomes" and "unfair results".

GO

PRINT '=== Traditional search complete. Notice the gaps. ===';
PRINT 'The prompt may contain words NOT FOUND in your data!';
PRINT 'This is exactly the problem vector search solves.';
PRINT '';
PRINT 'Proceed to 05_configure_model.sql to set up embeddings.';
GO
