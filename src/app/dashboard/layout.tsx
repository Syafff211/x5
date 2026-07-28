'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { StudentSidebar } from '@/components/layout/StudentSidebar';
import { useAuthStore } from '@/store';

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const { user, loading } = useAuthStore();
  const [isChecking, setIsChecking] = useState(true);

  useEffect(() => {
    if (!loading) {
      setIsChecking(false);
      
      if (!user) {
        router.replace('/auth/login');
      } else if (user.role === 'admin') {
        // Kalau admin login ke dashboard, redirect ke admin panel
        router.replace('/admin');
      }
    }
  }, [user, loading, router]);

  if (loading || isChecking) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <div className="text-center">
          <div className="spinner mb-4" />
          <p className="text-muted-foreground">Memuat dashboard...</p>
        </div>
      </div>
    );
  }

  if (!user) {
    return null;
  }

  return (
    <div className="min-h-screen bg-background">
      <StudentSidebar />
      <main className="lg:pl-[280px] transition-all duration-300">
        <div className="container mx-auto px-4 py-6 pt-20 lg:pt-6">
          {children}
        </div>
      </main>
    </div>
  );
}
