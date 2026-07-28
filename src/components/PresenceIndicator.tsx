'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { Users, Wifi, WifiOff } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Avatar, AvatarFallback, AvatarImage } from '@/components/ui/avatar';
import { usePresence } from '@/hooks/usePresence';

interface PresenceIndicatorProps {
  page?: string;
  showCount?: boolean;
  maxDisplay?: number;
}

export function PresenceIndicator({ 
  page, 
  showCount = true, 
  maxDisplay = 5 
}: PresenceIndicatorProps) {
  const { onlineUsers, isLoading, getOnlineCount, getUsersOnPage } = usePresence(page);

  const usersToShow = page ? getUsersOnPage(page) : onlineUsers;
  const displayUsers = usersToShow.slice(0, maxDisplay);
  const remainingCount = usersToShow.length - maxDisplay;
  const onlineCount = getOnlineCount();

  if (isLoading) {
    return (
      <div className="flex items-center gap-2">
        <div className="h-8 w-8 rounded-full bg-muted animate-pulse" />
      </div>
    );
  }

  if (onlineCount === 0) {
    return (
      <div className="flex items-center gap-2 px-3 py-1.5 rounded-full bg-muted/50 cursor-default" title="Tidak ada user yang online">
        <WifiOff className="h-4 w-4 text-muted-foreground" />
        {showCount && (
          <span className="text-xs text-muted-foreground">Offline</span>
        )}
      </div>
    );
  }

  return (
    <div className="flex items-center gap-2">
      <div className="flex -space-x-2">
        <AnimatePresence>
          {displayUsers.map((user, index) => (
            <motion.div
              key={user.id}
              initial={{ opacity: 0, scale: 0.8 }}
              animate={{ opacity: 1, scale: 1 }}
              exit={{ opacity: 0, scale: 0.8 }}
              transition={{ delay: index * 0.05 }}
              className="relative group"
              title={`${user.full_name} - ${user.status}${user.current_page ? ` (di ${user.current_page})` : ''}`}
            >
              <Avatar className="h-8 w-8 border-2 border-background">
                <AvatarImage src={user.avatar_url} alt={user.full_name} />
                <AvatarFallback className="text-xs">
                  {user.full_name.charAt(0)}
                </AvatarFallback>
              </Avatar>
              <div
                className={`absolute -bottom-0.5 -right-0.5 h-3 w-3 rounded-full border-2 border-background ${
                  user.status === 'online'
                    ? 'bg-green-500'
                    : user.status === 'away'
                    ? 'bg-yellow-500'
                    : 'bg-gray-500'
                }`}
              />
            </motion.div>
          ))}
        </AnimatePresence>

        {remainingCount > 0 && (
          <motion.div
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            className="relative"
            title={`Dan ${remainingCount} user lainnya`}
          >
            <div className="h-8 w-8 rounded-full bg-muted border-2 border-background flex items-center justify-center">
              <span className="text-xs font-semibold">+{remainingCount}</span>
            </div>
          </motion.div>
        )}
      </div>

      {showCount && (
        <Badge variant="secondary" className="gap-1">
          <Wifi className="h-3 w-3" />
          <span>{onlineCount} online</span>
        </Badge>
      )}
    </div>
  );
}
