-- ===== SIMPLE BULK CREATE (TANPA FUNCTION) =====
-- Jalankan ini di Supabase SQL Editor

-- 1. Cek dulu profiles mana yang belum punya user_id
SELECT id, email, full_name, user_id 
FROM profiles 
WHERE role = 'student' 
ORDER BY email;

-- 2. Cek profiles yang user_id masih NULL
SELECT COUNT(*) as total_without_user_id
FROM profiles 
WHERE user_id IS NULL AND role = 'student';

-- 3. Kalau ada yang NULL, jalankan ini untuk create users satu per satu
-- Copy SQL di bawah dan ganti email dengan email student

-- Example untuk 1 student:
DO $$
DECLARE
  new_user_id uuid;
  student_email text := 'alisha@gmail.com';  -- GANTI DENGAN EMAIL STUDENT
  student_name text := 'Alisha Azaria Harviyani';  -- GANTI DENGAN NAMA STUDENT
BEGIN
  -- Check if user already exists
  IF EXISTS (SELECT 1 FROM auth.users WHERE email = student_email) THEN
    RAISE NOTICE 'User % already exists', student_email;
    
    -- Get existing user_id
    SELECT id INTO new_user_id FROM auth.users WHERE email = student_email;
    
    -- Update profile
    UPDATE profiles SET user_id = new_user_id WHERE email = student_email;
    RAISE NOTICE 'Profile updated with existing user_id: %', new_user_id;
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
      student_email,
      crypt('ganesha123', gen_salt('bf')),
      NOW(), NOW(), NOW(),
      '{"provider": "email", "providers": ["email"]}',
      jsonb_build_object('full_name', student_name, 'role', 'student'),
      NOW(), NOW(),
      '', '', '', ''
    ) RETURNING id INTO new_user_id;
    
    -- Update profile
    UPDATE profiles SET user_id = new_user_id WHERE email = student_email;
    RAISE NOTICE 'Created user and updated profile for %', student_email;
  END IF;
END $$;

-- 4. Verify user created
SELECT 
  au.email,
  au.email_confirmed_at IS NOT NULL as confirmed,
  p.full_name,
  p.user_id
FROM auth.users au
JOIN profiles p ON p.user_id = au.id
WHERE au.email = 'alisha@gmail.com';  -- GANTI DENGAN EMAIL YANG BARU DIBUAT
