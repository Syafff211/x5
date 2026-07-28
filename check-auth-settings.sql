-- ===== CHECK & FIX AUTH SETTINGS VIA SQL =====
-- Jalankan ini di Supabase SQL Editor

-- 1. Cek Auth settings
SELECT * FROM auth.config;

-- 2. Disable email confirmation (kalau ada table config)
UPDATE auth.config 
SET enable_confirmations = false 
WHERE true;

-- 3. Alternative: Check if we can create users
SELECT * FROM auth.users LIMIT 5;

-- 4. Test create user via SQL (ini akan bypass email confirmation)
-- Ganti email dengan test email
DO $$
DECLARE
  new_user_id uuid;
BEGIN
  -- Insert directly to auth.users (bypass confirmation)
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
    'test-bypass@example.com',
    crypt('test123', gen_salt('bf')),
    NOW(), -- Auto-confirm
    NOW(),
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"full_name": "Test User", "role": "student"}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
  ) RETURNING id INTO new_user_id;
  
  RAISE NOTICE 'Test user created with ID: %', new_user_id;
  
  -- Create profile for test user
  INSERT INTO profiles (user_id, email, full_name, role)
  VALUES (new_user_id, 'test-bypass@example.com', 'Test User', 'student')
  ON CONFLICT (user_id) DO NOTHING;
  
  RAISE NOTICE 'Profile created for test user';
END $$;

-- 5. Verify test user created
SELECT 
  au.id,
  au.email,
  au.email_confirmed_at,
  p.full_name,
  p.role
FROM auth.users au
LEFT JOIN profiles p ON p.user_id = au.id
WHERE au.email = 'test-bypass@example.com';

-- 6. Kalau test user berhasil dibuat, kita bisa pakai method ini untuk bulk create
-- Hapus test user dulu
DELETE FROM profiles WHERE email = 'test-bypass@example.com';
DELETE FROM auth.users WHERE email = 'test-bypass@example.com';
