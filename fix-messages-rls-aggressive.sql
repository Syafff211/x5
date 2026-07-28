-- ===== AGGRESSIVE FIX: DROP ALL & RECREATE MESSAGES POLICIES =====
-- Jalankan ini di Supabase SQL Editor

-- Step 1: Drop ALL existing policies on messages table
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

-- Step 2: Verify all policies dropped
SELECT COUNT(*) as remaining_policies
FROM pg_policies 
WHERE tablename = 'messages';

-- Step 3: Enable RLS
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Step 4: Create simple, working policies

-- Policy 1: Anyone authenticated can view their messages
CREATE POLICY "messages_select_policy"
ON messages FOR SELECT
TO authenticated
USING (
  auth.uid() = sender_id OR auth.uid() = receiver_id
);

-- Policy 2: Anyone authenticated can insert messages (as long as they are the sender)
CREATE POLICY "messages_insert_policy"
ON messages FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = sender_id
);

-- Policy 3: Receiver can update messages (for is_read)
CREATE POLICY "messages_update_policy"
ON messages FOR UPDATE
TO authenticated
USING (
  auth.uid() = receiver_id
)
WITH CHECK (
  auth.uid() = receiver_id
);

-- Policy 4: Sender can delete their own messages
CREATE POLICY "messages_delete_policy"
ON messages FOR DELETE
TO authenticated
USING (
  auth.uid() = sender_id
);

-- Step 5: Verify policies created
SELECT 
  policyname,
  cmd,
  roles,
  qual IS NOT NULL as has_using,
  with_check IS NOT NULL as has_with_check
FROM pg_policies
WHERE tablename = 'messages'
ORDER BY cmd, policyname;

-- Step 6: Test current user (untuk debug)
SELECT 
  'Current user info' as test,
  auth.uid() as user_id,
  auth.role() as role,
  (SELECT email FROM auth.users WHERE id = auth.uid()) as email;

-- Step 7: Test SELECT (should work)
SELECT 'Test SELECT' as test, COUNT(*) as message_count
FROM messages;

-- Step 8: Show table structure
SELECT 'Table structure' as info;
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'messages'
ORDER BY ordinal_position;
