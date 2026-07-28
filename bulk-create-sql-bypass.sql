-- ===== BULK CREATE STUDENTS VIA SQL (BYPASS AUTH API) =====
-- Jalankan ini di Supabase SQL Editor
-- Password default: ganesha123

-- 1. Create function untuk bulk create users
CREATE OR REPLACE FUNCTION bulk_create_students()
RETURNS TABLE(email text, status text, user_id uuid) AS $$
DECLARE
  student_record RECORD;
  new_user_id uuid;
  result_status text;
BEGIN
  -- Loop through all profiles without user_id
  FOR student_record IN 
    SELECT id, email, full_name, role 
    FROM profiles 
    WHERE user_id IS NULL AND role = 'student'
  LOOP
    BEGIN
      -- Insert directly to auth.users (bypass email confirmation)
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
        student_record.email,
        crypt('ganesha123', gen_salt('bf')),
        NOW(), -- Auto-confirm email
        NOW(),
        NOW(),
        '{"provider": "email", "providers": ["email"]}',
        jsonb_build_object('full_name', student_record.full_name, 'role', student_record.role),
        NOW(),
        NOW(),
        '',
        '',
        '',
        ''
      ) RETURNING id INTO new_user_id;
      
      -- Update profile with user_id
      UPDATE profiles 
      SET user_id = new_user_id 
      WHERE id = student_record.id;
      
      result_status := 'success';
      
    EXCEPTION WHEN OTHERS THEN
      result_status := 'error: ' || SQLERRM;
      new_user_id := NULL;
    END;
    
    -- Return result for this student
    email := student_record.email;
    status := result_status;
    user_id := new_user_id;
    RETURN NEXT;
  END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Execute bulk create
SELECT * FROM bulk_create_students();

-- 3. Verify results
SELECT 
  COUNT(*) as total_profiles,
  COUNT(user_id) as with_user_id,
  COUNT(*) - COUNT(user_id) as without_user_id
FROM profiles 
WHERE role = 'student';

-- 4. Check created users
SELECT 
  au.email,
  au.email_confirmed_at IS NOT NULL as confirmed,
  p.full_name,
  p.role
FROM auth.users au
JOIN profiles p ON p.user_id = au.id
WHERE p.role = 'student'
ORDER BY au.created_at DESC
LIMIT 10;

-- 5. Optional: Drop function after use
-- DROP FUNCTION bulk_create_students();
