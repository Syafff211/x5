-- ===== CEK DAN LINK USERS YANG SUDAH ADA =====
-- Jalankan ini di Supabase SQL Editor

-- Step 1: Cek apakah ada users di auth.users yang email-nya match dengan profiles
SELECT 
  p.email,
  p.full_name,
  p.id as profile_id,
  p.user_id as current_user_id,
  au.id as auth_user_id,
  au.email_confirmed_at
FROM profiles p
LEFT JOIN auth.users au ON au.email = p.email
WHERE p.role = 'student'
ORDER BY p.email;

-- Step 2: Update profiles dengan user_id dari auth.users yang sudah ada
UPDATE profiles p
SET user_id = au.id
FROM auth.users au
WHERE au.email = p.email
  AND p.role = 'student'
  AND p.user_id IS NULL;

-- Step 3: Verify hasil
SELECT 
  COUNT(*) as total_students,
  COUNT(user_id) as with_user_id,
  COUNT(*) - COUNT(user_id) as without_user_id
FROM profiles 
WHERE role = 'student';

-- Step 4: Show students yang masih belum punya user_id (kalau ada)
SELECT email, full_name, user_id
FROM profiles
WHERE role = 'student' AND user_id IS NULL
ORDER BY email;

-- Step 5: Show students yang sudah bisa login
SELECT 
  au.email,
  au.email_confirmed_at IS NOT NULL as can_login,
  p.full_name
FROM profiles p
JOIN auth.users au ON au.id = p.user_id
WHERE p.role = 'student'
ORDER BY au.email
LIMIT 10;
