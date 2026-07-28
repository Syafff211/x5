-- ===== CREATE USERS & LINK TO PROFILES (FINAL VERSION) =====
-- Jalankan ini di Supabase SQL Editor

-- Step 1: Create users untuk semua profiles yang belum punya user_id
DO $$
DECLARE
  rec RECORD;
  new_user_id uuid;
  counter int := 0;
  error_counter int := 0;
BEGIN
  -- Loop semua profiles tanpa user_id
  FOR rec IN 
    SELECT id, email, full_name 
    FROM profiles 
    WHERE user_id IS NULL AND role = 'student'
    ORDER BY email
  LOOP
    BEGIN
      -- Check apakah user sudah ada di auth.users
      SELECT id INTO new_user_id 
      FROM auth.users 
      WHERE email = rec.email;
      
      IF new_user_id IS NOT NULL THEN
        -- User sudah ada, update profile
        UPDATE profiles 
        SET user_id = new_user_id 
        WHERE id = rec.id;
        
        RAISE NOTICE '✓ Linked existing user for %', rec.email;
        counter := counter + 1;
      ELSE
        -- Create new user di auth.users
        INSERT INTO auth.users (
          instance_id,
          id,
          aud,
          role,
          email,
          encrypted_password,
          email_confirmed_at,
          recovery_sent_at,
          last_sign_in_at,
          raw_app_meta_data,
          raw_user_meta_data,
          created_at,
          updated_at,
          confirmation_token,
          email_change,
          email_change_token_new,
          recovery_token
        ) VALUES (
          '00000000-0000-0000-0000-000000000000',
          gen_random_uuid(),
          'authenticated',
          'authenticated',
          rec.email,
          crypt('ganesha123', gen_salt('bf')),
          NOW(),  -- Auto-confirm email
          NOW(),
          NOW(),
          '{"provider": "email", "providers": ["email"]}',
          jsonb_build_object('full_name', rec.full_name, 'role', 'student'),
          NOW(),
          NOW(),
          '',
          '',
          '',
          ''
        ) RETURNING id INTO new_user_id;
        
        -- Update profile dengan user_id baru
        UPDATE profiles 
        SET user_id = new_user_id 
        WHERE id = rec.id;
        
        RAISE NOTICE '✓ Created user and linked for %', rec.email;
        counter := counter + 1;
      END IF;
      
    EXCEPTION WHEN OTHERS THEN
      RAISE NOTICE '✗ Error for %: %', rec.email, SQLERRM;
      error_counter := error_counter + 1;
    END;
  END LOOP;
  
  RAISE NOTICE '';
  RAISE NOTICE '===================================';
  RAISE NOTICE 'SUMMARY:';
  RAISE NOTICE '  Processed: % profiles', counter + error_counter;
  RAISE NOTICE '  Success: %', counter;
  RAISE NOTICE '  Errors: %', error_counter;
  RAISE NOTICE '===================================';
END $$;

-- Step 2: Force confirm semua emails (backup)
UPDATE auth.users 
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;

-- Step 3: Verify semua students sekarang punya user_id
SELECT 
  COUNT(*) as total_students,
  COUNT(user_id) as with_user_id,
  COUNT(*) - COUNT(user_id) as without_user_id
FROM profiles 
WHERE role = 'student';

-- Step 4: Verify semua users bisa login
SELECT 
  au.email,
  au.email_confirmed_at IS NOT NULL as can_login,
  p.full_name,
  p.user_id
FROM auth.users au
JOIN profiles p ON p.user_id = au.id
WHERE p.role = 'student'
ORDER BY au.email
LIMIT 10;
