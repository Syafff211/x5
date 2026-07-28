-- ===== DISABLE RLS COMPLETELY FOR TESTING =====
-- Jalankan ini di Supabase SQL Editor

-- Step 1: Drop ALL policies
DO $$ 
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname 
    FROM pg_policies 
    WHERE tablename = 'messages'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON messages', pol.policyname);
    RAISE NOTICE 'Dropped policy: %', pol.policyname;
  END LOOP;
END $$;

-- Step 2: DISABLE RLS completely
ALTER TABLE messages DISABLE ROW LEVEL SECURITY;

-- Step 3: Verify RLS is disabled
SELECT 
  relname as table_name,
  relrowsecurity as rls_enabled
FROM pg_class
WHERE relname = 'messages';

-- Step 4: Verify no policies
SELECT COUNT(*) as policy_count
FROM pg_policies 
WHERE tablename = 'messages';

-- Step 5: Test insert (should work now)
INSERT INTO messages (sender_id, receiver_id, content, is_read)
SELECT 
  (SELECT id FROM profiles WHERE role = 'student' LIMIT 1),
  (SELECT id FROM profiles WHERE role = 'student' LIMIT 1 OFFSET 1),
  'Test message with RLS disabled',
  false;

-- Step 6: Verify insert worked
SELECT 
  m.id,
  p1.full_name as sender_name,
  p2.full_name as receiver_name,
  m.content,
  m.created_at
FROM messages m
JOIN profiles p1 ON p1.id = m.sender_id
JOIN profiles p2 ON p2.id = m.receiver_id
ORDER BY m.created_at DESC
LIMIT 5;
