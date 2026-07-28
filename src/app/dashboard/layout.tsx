'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { StudentSidebar } from '@/components/layout/StudentSidebar';
import { createClient } from '@/lib/supabase/client';

const supabase = createClient();

export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const router = useRouter();
  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    const checkAuth = async () => {
      try {
        // Wait a bit for session to be ready
        await new Promise(resolve => setTimeout(resolve, 500));

        const { data: { session } } = await supabase.auth.getSession();
        
        if (!session?.user) {
          // Retry once after 1 second
          await new Promise(resolve => setTimeout(resolve, 1000));
          const { data: { session: retrySession } } = await supabase.auth.getSession();
          
          if (!retrySession?.user) {
            router.replace('/auth/login');
            return;
          }
        }

        // Check role
        const { data: profile } = await supabase
          .from('profiles')
          .select('role')
          .eq('user_id', session?.user.id)
          .single();

        if (profile?.role === 'admin') {
          router.replace('/admin');
          return;
        }

        setIsReady(true);
      } catch (error) {
        console.error('Auth check error:', error);
        router.replace('/auth/login');
      }
    };

    checkAuth();
  }, [router]);

  if (!isReady) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-background">
        <div className="text-center">
          <div className="spinner mb-4" />
          <p className="text-muted-foreground">Memuat dashboard...</p>
        </div>
      </div>
    );
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
