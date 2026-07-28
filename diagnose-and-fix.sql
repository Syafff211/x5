-- ===== DIAGNOSTIC & FIX =====
-- Jalankan ini di Supabase SQL Editor untuk cek dan fix

-- 1. Cek total profiles
SELECT 'Total profiles' as check_type, COUNT(*) as count FROM profiles;

-- 2. Cek profiles student
SELECT 'Student profiles' as check_type, COUNT(*) as count FROM profiles WHERE role = 'student';

-- 3. Cek profiles dengan user_id
SELECT 'With user_id' as check_type, COUNT(*) as count FROM profiles WHERE user_id IS NOT NULL;

-- 4. Cek profiles tanpa user_id
SELECT 'Without user_id' as check_type, COUNT(*) as count FROM profiles WHERE user_id IS NULL;

-- 5. Cek total users di auth.users
SELECT 'Auth users' as check_type, COUNT(*) as count FROM auth.users;

-- 6. Lihat sample profiles
SELECT 'Sample profiles' as info;
SELECT id, email, full_name, role, user_id FROM profiles LIMIT 5;

-- 7. Lihat sample auth.users
SELECT 'Sample auth users' as info;
SELECT id, email, created_at FROM auth.users LIMIT 5;

-- 8. Kalau semua profiles sudah punya user_id, test login dengan salah satu
-- Kalau ada yang belum punya user_id, jalankan SQL di bawah ini:

-- ===== BULK CREATE UNTUK YANG BELUM PUNYA USER_ID =====
-- Ini akan create user untuk semua profiles yang user_id masih NULL

DO $$
DECLARE
  rec RECORD;
  new_user_id uuid;
  counter int := 0;
BEGIN
  FOR rec IN 
    SELECT id, email, full_name 
    FROM profiles 
    WHERE user_id IS NULL AND role = 'student'
  LOOP
    BEGIN
      -- Check if user already exists in auth.users
      SELECT id INTO new_user_id FROM auth.users WHERE email = rec.email;
      
      IF new_user_id IS NOT NULL THEN
        -- User exists, just update profile
        UPDATE profiles SET user_id = new_user_id WHERE id = rec.id;
        RAISE NOTICE 'Updated profile % with existing user', rec.email;
      ELSE
        -- Create new user
        INSERT INTO auth.users (
          instance_id, id, aud, role, email, encrypted_password,
          email_confirmed_at, recovery_sent_at, last_sign_in_at,
          raw_app_meta_data, raw_user_meta_data,
          created_at, updated_at,
          confirmation_token, email_change, email_change_token_new, recovery_token
        ) VALUES (
          '00000000-0000-0000-0000-000000000000',
          gen_random_uuid(),
          'authenticated',
          'authenticated',
          rec.email,
          crypt('ganesha123', gen_salt('bf')),
          NOW(), NOW(), NOW(),
          '{"provider": "email", "providers": ["email"]}',
          jsonb_build_object('full_name', rec.full_name, 'role', 'student'),
          NOW(), NOW(),
          '', '', '', ''
        ) RETURNING id INTO new_user_id;
        
        -- Update profile
        UPDATE profiles SET user_id = new_user_id WHERE id = rec.id;
        RAISE NOTICE 'Created user and updated profile for %', rec.email;
      END IF;
      
      counter := counter + 1;
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE 'Error processing %: %', rec.email, SQLERRM;
    END;
  END LOOP;
  
  RAISE NOTICE 'Processed % profiles', counter;
END $$;

-- 9. Verify final result
SELECT 'Final check' as info;
SELECT 
  COUNT(*) as total_profiles,
  COUNT(user_id) as with_user_id,
  COUNT(*) - COUNT(user_id) as without_user_id
FROM profiles 
WHERE role = 'student';

-- 10. Show all students with their user_id
SELECT 'All students' as info;
SELECT 
  p.email,
  p.full_name,
  p.user_id IS NOT NULL as has_account,
  au.email_confirmed_at IS NOT NULL as email_confirmed
FROM profiles p
LEFT JOIN auth.users au ON au.id = p.user_id
WHERE p.role = 'student'
ORDER BY p.email;
