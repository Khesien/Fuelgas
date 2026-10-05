import React from 'react';
import { Wifi, Battery, Signal } from 'lucide-react';

interface MobileFrameProps {
  children: React.ReactNode;
  bottomNav?: React.ReactNode;
  mode: 'frame' | 'fullscreen';
}

export const MobileFrame: React.FC<MobileFrameProps> = ({ children, bottomNav, mode }) => {
  const currentTime = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit', hour12: false });

  if (mode === 'fullscreen') {
    return (
      <div style={{ width: '100%', minHeight: 'calc(100vh - 60px)', background: '#0f172a', position: 'relative' }}>
        <div style={{ paddingBottom: bottomNav ? '70px' : '0' }}>{children}</div>
        {bottomNav}
      </div>
    );
  }

  return (
    <div className="mobile-device-container">
      <div className="mobile-frame">
        {/* Device Top Notch */}
        <div className="mobile-notch" />

        {/* Status Bar */}
        <div className="mobile-status-bar">
          <span>{currentTime}</span>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
            <Signal size={12} color="#cbd5e1" />
            <Wifi size={12} color="#cbd5e1" />
            <Battery size={14} color="#cbd5e1" />
          </div>
        </div>

        {/* Scrollable Content */}
        <div className="mobile-app-content">
          {children}
        </div>

        {/* Fixed Mobile Bottom Bar */}
        {bottomNav}
      </div>
    </div>
  );
};
