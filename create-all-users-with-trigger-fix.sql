-- ===== CREATE ALL USERS (WITH TRIGGER FIX) =====
-- Jalankan ini di Supabase SQL Editor

-- Step 1: Disable trigger sementara
ALTER TABLE auth.users DISABLE TRIGGER on_auth_user_created;

-- Step 2: Create users untuk semua profiles yang belum punya user_id
DO $$
DECLARE
  rec RECORD;
  new_user_id uuid;
  counter int := 0;
  error_counter int := 0;
BEGIN
  FOR rec IN 
    SELECT id, email, full_name 
    FROM profiles 
    WHERE user_id IS NULL AND role = 'student'
    ORDER BY email
  LOOP
    BEGIN
      -- Check apakah user sudah ada
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
        -- Create new user
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
          NOW(),
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
        
        -- Update profile
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

-- Step 3: Enable trigger kembali
ALTER TABLE auth.users ENABLE TRIGGER on_auth_user_created;

-- Step 4: Force confirm semua emails
UPDATE auth.users 
SET email_confirmed_at = NOW()
WHERE email_confirmed_at IS NULL;

-- Step 5: Verify hasil
SELECT 
  COUNT(*) as total_students,
  COUNT(user_id) as with_user_id,
  COUNT(*) - COUNT(user_id) as without_user_id
FROM profiles 
WHERE role = 'student';

-- Step 6: Show sample students yang bisa login
SELECT 
  au.email,
  au.email_confirmed_at IS NOT NULL as can_login,
  p.full_name,
  p.user_id IS NOT NULL as has_user_id
FROM profiles p
JOIN auth.users au ON au.id = p.user_id
WHERE p.role = 'student'
ORDER BY au.email
LIMIT 10;
