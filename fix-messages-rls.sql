-- ===== FIX MESSAGES RLS POLICIES =====
-- Jalankan ini di Supabase SQL Editor

-- Step 1: Drop existing policies (kalau ada)
DROP POLICY IF EXISTS "Users can view own messages" ON messages;
DROP POLICY IF EXISTS "Users can send messages" ON messages;
DROP POLICY IF EXISTS "Users can update own messages" ON messages;
DROP POLICY IF EXISTS "Users can delete own messages" ON messages;

-- Step 2: Enable RLS (kalau belum)
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Step 3: Create correct policies

-- SELECT: Users can view messages they sent or received
CREATE POLICY "Users can view own messages"
ON messages FOR SELECT
USING (
  auth.uid() = sender_id OR auth.uid() = receiver_id
);

-- INSERT: Users can send messages (as sender)
CREATE POLICY "Users can send messages"
ON messages FOR INSERT
WITH CHECK (
  auth.uid() = sender_id
);

-- UPDATE: Users can update messages they received (for is_read)
CREATE POLICY "Users can update received messages"
ON messages FOR UPDATE
USING (
  auth.uid() = receiver_id
);

-- DELETE: Users can delete their own messages
CREATE POLICY "Users can delete own messages"
ON messages FOR DELETE
USING (
  auth.uid() = sender_id
);

-- Step 4: Verify policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'messages'
ORDER BY policyname;

-- Step 5: Test INSERT (optional - hapus kalau tidak mau test)
-- INSERT INTO messages (sender_id, receiver_id, content, is_read)
-- VALUES (
--   (SELECT id FROM auth.users LIMIT 1),
--   (SELECT id FROM auth.users LIMIT 1 OFFSET 1),
--   'Test message',
--   false
-- );
