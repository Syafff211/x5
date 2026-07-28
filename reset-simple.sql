-- ===== RESET SIMPLE (BIARKAN TRIGGER HANDLE PROFILES) =====
-- Password semua: ganesha123

-- Step 1: Hapus semua students dari profiles
DELETE FROM profiles WHERE role = 'student';

-- Step 2: Hapus semua students dari auth.users (kecuali admin)
DELETE FROM auth.users 
WHERE email != 'admin@x5sman1.com' 
  AND email NOT LIKE '%@supabase%'
  AND email NOT LIKE '%@supabase.co';

-- Step 3: Verify sudah kosong
SELECT 'Profiles kosong:' as check_type, COUNT(*) as count FROM profiles WHERE role = 'student';
SELECT 'Auth users kosong:' as check_type, COUNT(*) as count FROM auth.users WHERE email != 'admin@x5sman1.com' AND email NOT LIKE '%@supabase%';

-- Step 4: Insert semua students ke auth.users
-- Trigger akan otomatis create profiles!
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
)
SELECT
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  email,
  crypt('ganesha123', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '{"provider": "email", "providers": ["email"]}',
  jsonb_build_object('full_name', full_name, 'role', 'student'),
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
FROM (VALUES
  ('alisha@gmail.com', 'Alisha Azaria Harviyani'),
  ('anindya@gmail.com', 'Anindya Putri Palupi'),
  ('ardian@gmail.com', 'Ardian Yusuf Firdaus'),
  ('auryn@gmail.com', 'Auryn Nila Oktaviani'),
  ('ayesha@gmail.com', 'Ayesha Safarrina Triono'),
  ('caca@gmail.com', 'Cahyaningtyas Ridho P'),
  ('callista@gmail.com', 'Callista Keisya Nathania'),
  ('defan@gmail.com', 'Defan Dwi Valdian'),
  ('erlangga@gmail.com', 'Erlangga Dwi Revanda'),
  ('aini@gmail.com', 'Faidah Qurrota Aini'),
  ('farah@gmail.com', 'Farah Noviana'),
  ('hafidz@gmail.com', 'Hafidz Fadillah'),
  ('halwa@gmail.com', 'Halwa Qasdina Zalmya'),
  ('hanyfa@gmail.com', 'Hanyfa Trias Maharani'),
  ('harjuna@gmail.com', 'Harjuna Ilham Kesatria Utomo'),
  ('humam@gmail.com', 'Humam Asyrafi Zada'),
  ('khalisha@gmail.com', 'Khalisha Rizqina Salsabila'),
  ('maheswari@gmail.com', 'Maheswari Wangi Azyyati Ramadhani'),
  ('marhaeni@gmail.com', 'Marhaeni'),
  ('medina@gmail.com', 'Medina Rahma'),
  ('bani@gmail.com', 'Muh Bani Safi'),
  ('alva@gmail.com', 'Muhammad Alva Pratama'),
  ('syafiq@gmail.com', 'Muhammad Syafiq'),
  ('nabil@gmail.com', 'Nabil Pratama'),
  ('natalia@gmail.com', 'Natalia Aprilia Rahmawati'),
  ('nizrina@gmail.com', 'Nizrina Wafaa Darma'),
  ('panji@gmail.com', 'Panji Pamungkas'),
  ('ringgo@gmail.com', 'Ringgo Prasetyo'),
  ('safitri@gmail.com', 'Safitri Kurnia Sari'),
  ('syafa@gmail.com', 'Syafa Putri Nabila'),
  ('damar@gmail.com', 'Timur Damar Langga'),
  ('hana@gmail.com', 'Ufairah Hana Sakhi'),
  ('yogi@gmail.com', 'Yogi Febrian'),
  ('yulita@gmail.com', 'Yulita Nur Andini'),
  ('zahra@gmail.com', 'Zahra Anggraeny'),
  ('zahra2@gmail.com', 'Zahra Dewi Adha')
) AS students(email, full_name);

-- Step 5: Verify trigger sudah create profiles
SELECT '=== VERIFIKASI ===' as info;
SELECT 
  COUNT(*) as total_profiles,
  COUNT(user_id) as with_user_id
FROM profiles 
WHERE role = 'student';

-- Step 6: Show sample students
SELECT 
  p.email,
  p.full_name,
  p.user_id IS NOT NULL as can_login,
  au.email_confirmed_at IS NOT NULL as email_confirmed,
  'ganesha123' as password
FROM profiles p
JOIN auth.users au ON au.id = p.user_id
WHERE p.role = 'student'
ORDER BY p.email
LIMIT 10;

-- Step 7: Show semua students
SELECT 
  p.email,
  p.full_name,
  p.user_id IS NOT NULL as can_login,
  'ganesha123' as password
FROM profiles p
WHERE p.role = 'student'
ORDER BY p.email;
