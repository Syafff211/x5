-- ===== ADD IS_READ COLUMN TO MESSAGES TABLE =====
-- Jalankan ini di Supabase SQL Editor

-- Step 1: Add is_read column
ALTER TABLE messages 
ADD COLUMN IF NOT EXISTS is_read BOOLEAN DEFAULT FALSE;

-- Step 2: Set all existing messages as read (optional, atau bisa FALSE semua)
UPDATE messages 
SET is_read = FALSE 
WHERE is_read IS NULL;

-- Step 3: Add index for better performance
CREATE INDEX IF NOT EXISTS idx_messages_is_read 
ON messages(receiver_id, is_read) 
WHERE is_read = FALSE;

-- Step 4: Verify column added
SELECT column_name, data_type, column_default
FROM information_schema.columns
WHERE table_name = 'messages' AND column_name = 'is_read';

-- Step 5: Show sample messages with is_read
SELECT id, sender_id, receiver_id, content, is_read, created_at
FROM messages
ORDER BY created_at DESC
LIMIT 5;
