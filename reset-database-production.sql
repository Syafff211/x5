-- ===== RESET DATABASE UNTUK PRODUCTION (AGGRESSIVE VERSION) =====
-- PERINGATAN: Script ini akan menghapus SEMUA data operasional dengan CASCADE
-- JANGAN jalankan jika sudah ada data production!

-- Step 1: TRUNCATE semua tabel operasional dengan CASCADE
-- CASCADE akan otomatis hapus data di child tables juga

TRUNCATE TABLE assignment_submissions CASCADE;
SELECT '✓ Truncated assignment_submissions' as status;

TRUNCATE TABLE attendance_files CASCADE;
SELECT '✓ Truncated attendance_files' as status;

TRUNCATE TABLE grades CASCADE;
SELECT '✓ Truncated grades' as status;

TRUNCATE TABLE assignments CASCADE;
SELECT '✓ Truncated assignments' as status;

TRUNCATE TABLE attendance CASCADE;
SELECT '✓ Truncated attendance' as status;

TRUNCATE TABLE materials CASCADE;
SELECT '✓ Truncated materials' as status;

TRUNCATE TABLE announcements CASCADE;
SELECT '✓ Truncated announcements' as status;

TRUNCATE TABLE gallery CASCADE;
SELECT '✓ Truncated gallery' as status;

TRUNCATE TABLE calendar_events CASCADE;
SELECT '✓ Truncated calendar_events' as status;

TRUNCATE TABLE messages CASCADE;
SELECT '✓ Truncated messages' as status;

TRUNCATE TABLE notifications CASCADE;
SELECT '✓ Truncated notifications' as status;

-- Step 2: Verify semua tabel kosong
SELECT '=== VERIFICATION ===' as info;

SELECT 'assignment_submissions' as table_name, COUNT(*) as count FROM assignment_submissions
UNION ALL
SELECT 'attendance_files', COUNT(*) FROM attendance_files
UNION ALL
SELECT 'grades', COUNT(*) FROM grades
UNION ALL
SELECT 'assignments', COUNT(*) FROM assignments
UNION ALL
SELECT 'attendance', COUNT(*) FROM attendance
UNION ALL
SELECT 'materials', COUNT(*) FROM materials
UNION ALL
SELECT 'announcements', COUNT(*) FROM announcements
UNION ALL
SELECT 'gallery', COUNT(*) FROM gallery
UNION ALL
SELECT 'calendar_events', COUNT(*) FROM calendar_events
UNION ALL
SELECT 'messages', COUNT(*) FROM messages
UNION ALL
SELECT 'notifications', COUNT(*) FROM notifications
ORDER BY table_name;

-- Step 3: Verify profiles dan auth.users masih ada
SELECT '=== PROFILES & USERS (HARUS ADA) ===' as info;
SELECT 'profiles' as table_name, COUNT(*) as count FROM profiles
UNION ALL
SELECT 'auth.users', COUNT(*) FROM auth.users
ORDER BY table_name;

-- Step 4: Summary
SELECT '=== RESET COMPLETE ===' as status,
       'Semua data operasional telah dihapus dengan CASCADE' as message,
       'Profiles dan users tetap ada' as note;
