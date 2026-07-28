-- ===== FORCE CONFIRM ALL EMAILS =====
-- Jalankan ini di Supabase SQL Editor

-- 1. Cek dulu berapa yang belum confirmed
SELECT 'Before fix' as info;
SELECT 
  COUNT(*) as total_users,
  COUNT(email_confirmed_at) as confirmed,
  COUNT(*) - COUNT(email_confirmed_at) as not_confirmed
FROM auth.users;

-- 2. Force confirm semua emails
UPDATE auth.users 
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;

-- 3. Verify semua sudah confirmed
SELECT 'After fix' as info;
SELECT 
  COUNT(*) as total_users,
  COUNT(email_confirmed_at) as confirmed,
  COUNT(*) - COUNT(email_confirmed_at) as not_confirmed
FROM auth.users;

-- 4. Show sample users
SELECT 'Sample confirmed users' as info;
SELECT 
  email,
  email_confirmed_at IS NOT NULL as confirmed,
  created_at
FROM auth.users
ORDER BY created_at DESC
LIMIT 10;

-- 5. Test query untuk verify login akan work
SELECT 'Login test query' as info;
SELECT 
  au.email,
  au.email_confirmed_at IS NOT NULL as can_login,
  p.full_name,
  p.role
FROM auth.users au
JOIN profiles p ON p.user_id = au.id
WHERE p.role = 'student'
ORDER BY au.email
LIMIT 10;
