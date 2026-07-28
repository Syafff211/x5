# PWA & Real-time Collaboration Setup Guide

## 🚀 Overview

Dokumentasi ini menjelaskan cara setup dan menggunakan fitur **PWA (Progressive Web App)** dan **Real-time Collaboration** di aplikasi X-5 SMAN 1 Purbalingga.

---

## 📱 PWA (Progressive Web App)

### Fitur PWA:
- ✅ **Installable** - Bisa diinstall ke home screen
- ✅ **Offline Support** - Bisa diakses tanpa internet (basic)
- ✅ **Push Notifications** - Notifikasi push
- ✅ **Fast Loading** - Service worker caching
- ✅ **App-like Experience** - Standalone mode

### Setup PWA:

#### 1. Generate Icons

PWA membutuhkan icons dalam berbagai ukuran. Gunakan tools berikut:

**Option A: Real Favicon Generator**
1. Buka https://realfavicongenerator.net/
2. Upload logo X-5 (minimal 512x512px)
3. Generate icons
4. Download dan extract ke `public/icons/`

**Option B: PWA Asset Generator (CLI)**
```bash
npm install -g pwa-asset-generator

# Generate icons
pwa-asset-generator public/logo.png public/icons/ \
  --manifest public/manifest.json \
  --icon-only \
  --padding "20px" \
  --background "#0a0a0f"
```

**Option C: Manual (Placeholder)**
Untuk testing, buat placeholder icons:
```bash
# Install ImageMagick
sudo apt-get install imagemagick

# Generate icons dari logo
cd public/icons
for size in 72 96 128 144 152 192 384 512; do
  convert ../logo.png -resize ${size}x${size} icon-${size}x${size}.png
done
```

#### 2. Verify manifest.json

File sudah ada di `public/manifest.json`. Pastikan:
- ✅ `name` dan `short_name` benar
- ✅ `start_url` adalah `/`
- ✅ `display` adalah `standalone`
- ✅ `theme_color` dan `background_color` sesuai
- ✅ Semua icon paths benar

#### 3. Update Layout

Tambahkan PWA components ke root layout:

```tsx
// src/app/layout.tsx
import { PWAInstallPrompt } from '@/components/PWAInstallPrompt';

export default function RootLayout({ children }) {
  return (
    <html lang="id">
      <head>
        <link rel="manifest" href="/manifest.json" />
        <meta name="theme-color" content="#6366f1" />
        <link rel="apple-touch-icon" href="/icons/icon-192x192.png" />
      </head>
      <body>
        {children}
        <PWAInstallPrompt />
      </body>
    </html>
  );
}
```

#### 4. Register Service Worker

Tambahkan ke `src/app/layout.tsx`:

```tsx
'use client';

import { useEffect } from 'react';

export default function RootLayout({ children }) {
  useEffect(() => {
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.register('/sw.js')
        .then((registration) => {
          console.log('SW registered:', registration);
        })
        .catch((error) => {
          console.log('SW registration failed:', error);
        });
    }
  }, []);

  return (
    // ... rest of layout
  );
}
```

### Testing PWA:

1. **Chrome DevTools**:
   - Buka DevTools (F12)
   - Tab "Application" → "Manifest"
   - Cek semua info manifest
   - Tab "Service Workers" → cek status

2. **Lighthouse**:
   - DevTools → Tab "Lighthouse"
   - Select "Progressive Web App"
   - Run audit
   - Target score: 90+

3. **Install Prompt**:
   - Buka website di Chrome
   - Tunggu 3 detik
   - Popup "Install Aplikasi" akan muncul
   - Klik "Install"

---

## 🔄 Real-time Collaboration

### Fitur Real-time:
- ✅ **Presence System** - Lihat siapa yang online
- ✅ **Live Updates** - Data update real-time tanpa refresh
- ✅ **Typing Indicators** - Lihat siapa yang sedang mengetik
- ✅ **Cursor Positions** - (Advanced) Lihat posisi cursor user lain

### Components:

#### 1. PresenceIndicator

Menampilkan siapa yang sedang online.

**Usage:**
```tsx
import { PresenceIndicator } from '@/components/PresenceIndicator';

// Di navbar atau header
<PresenceIndicator showCount={true} maxDisplay={5} />

// Di halaman tertentu (show users on same page)
<PresenceIndicator page="/dashboard/messages" />
```

**Props:**
- `page?: string` - Filter users by current page
- `showCount?: boolean` - Show online count badge (default: true)
- `maxDisplay?: number` - Max avatars to display (default: 5)

#### 2. TypingIndicator

Menampilkan siapa yang sedang mengetik di chat.

**Usage:**
```tsx
import { TypingIndicator } from '@/components/TypingIndicator';

function ChatInput() {
  const { typingUsers, handleTyping, TypingDisplay } = TypingIndicator({
    channelName: 'chat-room-1'
  });

  return (
    <div>
      <TypingDisplay />
      <input
        type="text"
        onChange={handleTyping}
        placeholder="Ketik pesan..."
      />
    </div>
  );
}
```

#### 3. usePresence Hook

Custom hook untuk presence data.

**Usage:**
```tsx
import { usePresence } from '@/hooks/usePresence';

function MyComponent() {
  const { onlineUsers, isLoading, getOnlineCount, getUsersOnPage } = usePresence();

  return (
    <div>
      <p>Online: {getOnlineCount()}</p>
      <ul>
        {onlineUsers.map(user => (
          <li key={user.id}>{user.full_name}</li>
        ))}
      </ul>
    </div>
  );
}
```

### Real-time Data Sync

Supabase Realtime sudah otomatis sync untuk:
- ✅ Messages (chat)
- ✅ Notifications
- ✅ Attendance
- ✅ Announcements

**Example:**
```tsx
useEffect(() => {
  const channel = supabase
    .channel('messages')
    .on('postgres_changes', {
      event: 'INSERT',
      schema: 'public',
      table: 'messages',
    }, (payload) => {
      console.log('New message:', payload.new);
      // Update UI
    })
    .subscribe();

  return () => {
    supabase.removeChannel(channel);
  };
}, []);
```

---

## 🎨 Integration Examples

### Example 1: Navbar dengan Presence

```tsx
// src/components/layout/StudentNavbar.tsx
import { PresenceIndicator } from '@/components/PresenceIndicator';

export function StudentNavbar() {
  return (
    <nav className="...">
      {/* ... other navbar items ... */}
      
      <div className="flex items-center gap-4">
        <PresenceIndicator showCount={true} maxDisplay={3} />
        
        {/* Notifications, Messages, Profile */}
      </div>
    </nav>
  );
}
```

### Example 2: Chat dengan Typing Indicator

```tsx
// src/app/dashboard/messages/page.tsx
import { TypingIndicator } from '@/components/TypingIndicator';

export default function MessagesPage() {
  const { typingUsers, handleTyping, TypingDisplay } = TypingIndicator({
    channelName: `chat-${selectedChat}`
  });

  return (
    <div className="...">
      {/* Messages list */}
      
      {/* Typing indicator */}
      <TypingDisplay />
      
      {/* Input */}
      <input
        value={input}
        onChange={(e) => {
          setInput(e.target.value);
          handleTyping();
        }}
        placeholder="Ketik pesan..."
      />
    </div>
  );
}
```

### Example 3: Dashboard dengan Live Updates

```tsx
// src/app/dashboard/page.tsx
import { PresenceIndicator } from '@/components/PresenceIndicator';
import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';

const supabase = createClient();

export default function DashboardPage() {
  const [stats, setStats] = useState({ ... });

  useEffect(() => {
    // Subscribe to real-time updates
    const channel = supabase
      .channel('dashboard-updates')
      .on('postgres_changes', {
        event: '*',
        schema: 'public',
        table: 'attendance',
      }, (payload) => {
        // Refresh stats
        fetchDashboardData();
      })
      .subscribe();

    return () => {
      supabase.removeChannel(channel);
    };
  }, []);

  return (
    <div>
      {/* Presence indicator */}
      <PresenceIndicator showCount={true} />
      
      {/* Stats cards with live data */}
      <StatsCards stats={stats} />
    </div>
  );
}
```

---

## 🔧 Troubleshooting

### PWA Issues:

**Problem: Install prompt tidak muncul**
- ✅ Pastikan service worker registered
- ✅ Pastikan manifest.json valid
- ✅ Pastikan website di-serve via HTTPS
- ✅ Cek Lighthouse score (harus 90+)

**Problem: Icons tidak muncul**
- ✅ Cek path icons di manifest.json
- ✅ Pastikan semua icon files ada di `public/icons/`
- ✅ Clear browser cache

**Problem: Offline mode tidak bekerja**
- ✅ Cek service worker di DevTools → Application → Service Workers
- ✅ Pastikan `sw.js` ada di `public/`
- ✅ Test di DevTools → Application → Offline

### Real-time Issues:

**Problem: Presence tidak muncul**
- ✅ Pastikan user logged in
- ✅ Cek Supabase Realtime enabled
- ✅ Cek browser console untuk errors
- ✅ Pastikan channel name unique

**Problem: Typing indicator tidak muncul**
- ✅ Pastikan channel name sama antara users
- ✅ Cek broadcast event di Supabase
- ✅ Test di browser console

**Problem: Live updates tidak bekerja**
- ✅ Pastikan RLS policies benar
- ✅ Cek Supabase Realtime enabled untuk table
- ✅ Test INSERT/UPDATE manual di Supabase

---

## 📊 Performance Tips

### PWA:
- ✅ Compress icons (gunakan WebP format)
- ✅ Preload critical resources
- ✅ Use cache-first strategy untuk static assets
- ✅ Implement background sync untuk offline actions

### Real-time:
- ✅ Limit presence updates (setiap 30 detik)
- ✅ Use specific channels (jangan broadcast semua)
- ✅ Unsubscribe saat component unmount
- ✅ Debounce typing events

---

## 🎯 Next Steps

1. **Generate PWA Icons** - Gunakan tools di atas
2. **Test PWA** - Chrome DevTools → Lighthouse
3. **Test Real-time** - Buka 2 browser, cek presence
4. **Optimize** - Compress images, lazy load
5. **Deploy** - Push ke production

---

## 📚 Resources

- [PWA Builder](https://www.pwabuilder.com/)
- [Supabase Realtime Docs](https://supabase.com/docs/guides/realtime)
- [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API)
- [Web App Manifest](https://developer.mozilla.org/en-US/docs/Web/Manifest)

---

## ✅ Checklist

### PWA:
- [ ] manifest.json configured
- [ ] Icons generated (72px - 512px)
- [ ] Service worker registered
- [ ] PWAInstallPrompt added to layout
- [ ] Lighthouse score 90+
- [ ] Install prompt works
- [ ] Offline mode works

### Real-time:
- [ ] PresenceIndicator added to navbar
- [ ] usePresence hook working
- [ ] TypingIndicator in chat
- [ ] Live updates for messages
- [ ] Live updates for notifications
- [ ] Live updates for attendance

---

**Semua fitur PWA dan Real-time Collaboration sudah siap! 🚀✨**
