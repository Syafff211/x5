-- ===== DIAGNOSTIC: CEK SETIAP TABLE =====
-- Jalankan QUERY INI SATU PER SATU di Supabase SQL Editor

-- QUERY 1: Cek profiles table
SELECT '=== PROFILES TABLE ===' as table_name;
SELECT COUNT(*) as total_profiles FROM profiles;
SELECT id, email, full_name, role, user_id FROM profiles LIMIT 5;

-- QUERY 2: Cek auth.users table
SELECT '=== AUTH.USERS TABLE ===' as table_name;
SELECT COUNT(*) as total_users FROM auth.users;
SELECT id, email, email_confirmed_at, created_at FROM auth.users LIMIT 5;

-- QUERY 3: Cek apakah ada match antara profiles dan auth.users
SELECT '=== MATCH CHECK ===' as check_name;
SELECT 
  p.email as profile_email,
  p.user_id as profile_user_id,
  au.id as auth_user_id,
  au.email as auth_email
FROM profiles p
LEFT JOIN auth.users au ON au.email = p.email
WHERE p.role = 'student'
LIMIT 10;

-- QUERY 4: Cek profiles yang user_id masih NULL
SELECT '=== PROFILES WITHOUT USER_ID ===' as check_name;
SELECT email, full_name, role, user_id 
FROM profiles 
WHERE user_id IS NULL AND role = 'student'
LIMIT 10;

-- QUERY 5: Cek auth.users yang tidak punya profile
SELECT '=== AUTH USERS WITHOUT PROFILE ===' as check_name;
SELECT au.email, au.id
FROM auth.users au
LEFT JOIN profiles p ON p.user_id = au.id
WHERE p.id IS NULL
LIMIT 10;
