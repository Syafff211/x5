-- ===== VERIFY & TEST LOGIN =====
-- Jalankan ini di Supabase SQL Editor

-- 1. Force confirm semua emails (kalau belum)
UPDATE auth.users 
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;

-- 2. Verify semua students bisa login
SELECT 
  au.email,
  au.email_confirmed_at IS NOT NULL as can_login,
  p.full_name,
  p.role
FROM auth.users au
JOIN profiles p ON p.user_id = au.id
WHERE p.role = 'student'
ORDER BY au.email;
