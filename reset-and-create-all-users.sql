-- ===== RESET SEMUA DAN INPUT ULANG =====
-- Jalankan ini di Supabase SQL Editor
-- Password semua: ganesha123

-- Step 1: Backup admin user (JANGAN HAPUS ADMIN!)
SELECT '=== BACKUP ADMIN ===' as info;
SELECT id, email, role FROM auth.users WHERE email = 'admin@x5sman1.com';

-- Step 2: Hapus semua students dari profiles (kecuali admin)
DELETE FROM profiles WHERE role = 'student';

-- Step 3: Hapus semua students dari auth.users (kecuali admin)
DELETE FROM auth.users WHERE email != 'admin@x5sman1.com' AND email NOT LIKE '%@supabase%';

-- Step 4: Verify sudah kosong
SELECT '=== VERIFY KOSONG ===' as info;
SELECT COUNT(*) as students_in_profiles FROM profiles WHERE role = 'student';
SELECT COUNT(*) as users_in_auth FROM auth.users WHERE email != 'admin@x5sman1.com';

-- Step 5: Insert ulang semua students dengan password dan email confirmed
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
  NOW(), -- Email sudah confirmed
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

-- Step 6: Create profiles untuk semua students
INSERT INTO profiles (user_id, email, full_name, role)
SELECT 
  au.id,
  au.email,
  au.raw_user_meta_data->>'full_name',
  'student'
FROM auth.users au
WHERE au.email IN (
  'alisha@gmail.com', 'anindya@gmail.com', 'ardian@gmail.com', 'auryn@gmail.com',
  'ayesha@gmail.com', 'caca@gmail.com', 'callista@gmail.com', 'defan@gmail.com',
  'erlangga@gmail.com', 'aini@gmail.com', 'farah@gmail.com', 'hafidz@gmail.com',
  'halwa@gmail.com', 'hanyfa@gmail.com', 'harjuna@gmail.com', 'humam@gmail.com',
  'khalisha@gmail.com', 'maheswari@gmail.com', 'marhaeni@gmail.com', 'medina@gmail.com',
  'bani@gmail.com', 'alva@gmail.com', 'syafiq@gmail.com', 'nabil@gmail.com',
  'natalia@gmail.com', 'nizrina@gmail.com', 'panji@gmail.com', 'ringgo@gmail.com',
  'safitri@gmail.com', 'syafa@gmail.com', 'damar@gmail.com', 'hana@gmail.com',
  'yogi@gmail.com', 'yulita@gmail.com', 'zahra@gmail.com', 'zahra2@gmail.com'
)
AND au.email != 'admin@x5sman1.com';

-- Step 7: Verify semua students sudah ada dan bisa login
SELECT '=== FINAL VERIFICATION ===' as info;
SELECT 
  COUNT(*) as total_students,
  COUNT(user_id) as with_user_id,
  COUNT(*) - COUNT(user_id) as without_user_id
FROM profiles 
WHERE role = 'student';

-- Step 8: Show sample students yang bisa login
SELECT '=== SAMPLE STUDENTS (BISA LOGIN) ===' as info;
SELECT 
  au.email,
  au.email_confirmed_at IS NOT NULL as email_confirmed,
  p.full_name,
  p.user_id IS NOT NULL as has_profile
FROM auth.users au
JOIN profiles p ON p.user_id = au.id
WHERE p.role = 'student'
ORDER BY au.email
LIMIT 10;

-- Step 9: Show semua students
SELECT '=== SEMUA STUDENTS ===' as info;
SELECT 
  p.email,
  p.full_name,
  p.user_id IS NOT NULL as can_login,
  'ganesha123' as password
FROM profiles p
WHERE p.role = 'student'
ORDER BY p.email;
