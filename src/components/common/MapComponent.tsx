import React from 'react';
import { Driver, Address, Depot, OrderStatus } from '../../types';
import { Navigation, MapPin, Warehouse, Truck, CheckCircle2 } from 'lucide-react';

interface MapComponentProps {
  driver?: Driver;
  address?: Address;
  depot?: Depot;
  status?: OrderStatus;
  etaMinutes?: number;
  height?: string;
  showDetailsCard?: boolean;
}

export const MapComponent: React.FC<MapComponentProps> = ({
  driver,
  address,
  depot,
  status = 'out_for_delivery',
  etaMinutes = 18,
  height = '280px',
  showDetailsCard = true,
}) => {
  // Compute positions on 400x260 canvas grid
  const depotX = 60;
  const depotY = 200;
  
  const destX = 330;
  const destY = 60;

  // Drivers location interpolation (if status is out_for_delivery or preparing)
  let driverX = depotX;
  let driverY = depotY;

  if (driver && status === 'out_for_delivery') {
    // Convert lat/long offset into SVG grid position
    // Base Gaborone center lat: -24.65, lng: 25.91
    const latProgress = Math.min(1, Math.max(0, (driver.current_lat - (-24.6612)) / (-24.6541 - (-24.6612))));
    const lngProgress = Math.min(1, Math.max(0, (driver.current_lng - 25.8998) / (25.9087 - 25.8998)));
    
    // Average progress along route curve
    const progress = (latProgress + lngProgress) / 2 || 0.65;
    driverX = depotX + (destX - depotX) * progress;
    driverY = depotY + (destY - depotY) * progress;
  } else if (status === 'delivered') {
    driverX = destX;
    driverY = destY;
  }

  return (
    <div
      style={{
        position: 'relative',
        width: '100%',
        height,
        borderRadius: 'var(--radius-md)',
        overflow: 'hidden',
        background: '#0b1329',
        border: '1px solid var(--border-color)',
        boxShadow: 'inset 0 0 20px rgba(0,0,0,0.5)',
      }}
    >
      <svg width="100%" height="100%" viewBox="0 0 400 260" preserveAspectRatio="none">
        <defs>
          <linearGradient id="routeGradient" x1="0%" y1="100%" x2="100%" y2="0%">
            <stop offset="0%" stopColor="#00f0ff" stopOpacity="0.4" />
            <stop offset="100%" stopColor="#ff6b00" stopOpacity="0.9" />
          </linearGradient>

          <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
            <path d="M 40 0 L 0 0 0 40" fill="none" stroke="rgba(255,255,255,0.03)" strokeWidth="1" />
          </pattern>
        </defs>

        {/* Map Grid & Background city terrain */}
        <rect width="100%" height="100%" fill="#091024" />
        <rect width="100%" height="100%" fill="url(#grid)" />

        {/* Parks & City Blocks */}
        <rect x="20" y="20" width="80" height="60" rx="8" fill="rgba(34, 197, 94, 0.05)" stroke="rgba(34, 197, 94, 0.15)" />
        <rect x="240" y="140" width="110" height="70" rx="8" fill="rgba(255, 255, 255, 0.02)" stroke="rgba(255, 255, 255, 0.05)" />
        <rect x="140" y="40" width="70" height="80" rx="8" fill="rgba(255, 255, 255, 0.02)" stroke="rgba(255, 255, 255, 0.05)" />

        {/* Road network lines */}
        <path d="M 0 200 L 400 200" stroke="rgba(255,255,255,0.08)" strokeWidth="12" fill="none" />
        <path d="M 120 0 L 120 260" stroke="rgba(255,255,255,0.08)" strokeWidth="12" fill="none" />
        <path d="M 280 0 L 280 260" stroke="rgba(255,255,255,0.08)" strokeWidth="12" fill="none" />
        <path d="M 0 60 L 400 60" stroke="rgba(255,255,255,0.08)" strokeWidth="12" fill="none" />

        {/* Curved Route Line from Depot to Customer */}
        <path
          d={`M ${depotX} ${depotY} C 120 ${depotY}, 280 ${destY}, ${destX} ${destY}`}
          fill="none"
          stroke="url(#routeGradient)"
          strokeWidth="5"
          strokeDasharray="8 4"
        />

        {/* Depot Marker */}
        <g transform={`translate(${depotX}, ${depotY})`}>
          <circle r="16" fill="rgba(0, 240, 255, 0.15)" stroke="#00f0ff" strokeWidth="2" />
          <foreignObject x="-10" y="-10" width="20" height="20">
            <Warehouse size={20} color="#00f0ff" />
          </foreignObject>
        </g>

        {/* Customer Destination Pin */}
        <g transform={`translate(${destX}, ${destY})`}>
          <circle r="18" fill="rgba(239, 68, 68, 0.2)" stroke="#ef4444" strokeWidth="2" />
          <foreignObject x="-11" y="-14" width="22" height="22">
            <MapPin size={22} color="#ef4444" fill="#ef4444" />
          </foreignObject>
        </g>

        {/* Active Driver Live Vehicle Marker */}
        {(status === 'out_for_delivery' || status === 'preparing') && (
          <g transform={`translate(${driverX}, ${driverY})`}>
            {/* Glowing Pulse Ring */}
            <circle r="22" fill="rgba(255, 107, 0, 0.25)" className="pulse-marker" />
            <circle r="14" fill="#ff6b00" stroke="#ffffff" strokeWidth="2" />
            <foreignObject x="-8" y="-8" width="16" height="16">
              <Truck size={16} color="#ffffff" />
            </foreignObject>
          </g>
        )}

        {status === 'delivered' && (
          <g transform={`translate(${destX}, ${destY})`}>
            <circle r="22" fill="rgba(34, 197, 94, 0.3)" />
            <foreignObject x="-10" y="-10" width="20" height="20">
              <CheckCircle2 size={20} color="#4ade80" />
            </foreignObject>
          </g>
        )}
      </svg>

      {/* Live Overlay Badge */}
      {showDetailsCard && (
        <div
          style={{
            position: 'absolute',
            top: '12px',
            left: '12px',
            right: '12px',
            background: 'rgba(15, 23, 42, 0.9)',
            backdropFilter: 'blur(12px)',
            padding: '10px 14px',
            borderRadius: 'var(--radius-sm)',
            border: '1px solid var(--border-color)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'space-between',
          }}
        >
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Navigation size={16} color="var(--brand-orange)" />
            <div>
              <p style={{ fontSize: '0.75rem', fontWeight: 700, color: '#f8fafc' }}>
                {status === 'out_for_delivery'
                  ? 'Driver is on the way'
                  : status === 'preparing'
                  ? 'Depot staging order'
                  : status === 'delivered'
                  ? 'Package Delivered'
                  : 'Order Confirmed'}
              </p>
              <p style={{ fontSize: '0.65rem', color: 'var(--text-secondary)' }}>
                {depot?.name || 'Gaborone Hub'} → {address?.street || ' Khama Crescent'}
              </p>
            </div>
          </div>

          {status === 'out_for_delivery' && (
            <div
              style={{
                background: 'rgba(255,107,0,0.15)',
                border: '1px solid rgba(255,107,0,0.4)',
                padding: '4px 8px',
                borderRadius: '6px',
                textAlign: 'right',
              }}
            >
              <p style={{ fontSize: '0.6rem', color: 'var(--brand-orange)', fontWeight: 600 }}>ESTIMATED ETA</p>
              <p style={{ fontSize: '0.85rem', fontWeight: 800, color: '#ffffff' }}>~{etaMinutes} MINS</p>
            </div>
          )}
        </div>
      )}
    </div>
  );
};
