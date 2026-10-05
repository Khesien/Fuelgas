import React, { useState } from 'react';
import { Depot, CylinderProduct, GasProvider } from '../../types';
import { Warehouse, Edit3, Save } from 'lucide-react';

interface InventoryManagementProps {
  provider: GasProvider;
  depots: Depot[];
  products: CylinderProduct[];
  currencySymbol: string;
  onUpdateStock: (depotId: string, productId: string, newQty: number) => void;
  onUpdatePrices: (providerId: string, productId: string, refillPrice: number, exchangePrice: number) => void;
}

export const InventoryManagement: React.FC<InventoryManagementProps> = ({
  provider,
  depots,
  products,
  currencySymbol,
  onUpdateStock,
  onUpdatePrices,
}) => {
  const [editingPriceProductId, setEditingPriceProductId] = useState<string | null>(null);
  const [refillInput, setRefillInput] = useState<number>(0);
  const [exchangeInput, setExchangeInput] = useState<number>(0);

  const providerDepots = depots.filter((d) => d.provider_id === provider.provider_id) || depots;

  const handleStartEdit = (prod: CylinderProduct) => {
    const prices = provider.prices[prod.product_id] || { refill: 195, exchange: 320 };
    setEditingPriceProductId(prod.product_id);
    setRefillInput(prices.refill);
    setExchangeInput(prices.exchange);
  };

  const handleSavePrices = (prodId: string) => {
    onUpdatePrices(provider.provider_id, prodId, Number(refillInput), Number(exchangeInput));
    setEditingPriceProductId(null);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      <div>
        <h2 style={{ fontSize: '1.4rem', fontWeight: 800, color: '#ffffff' }}>
          {provider.company_name} — Depot Stock & Pricing Matrix
        </h2>
        <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
          Manage company cylinder stock levels per warehouse and configure Refill/Exchange pricing
        </p>
      </div>

      {/* Product Refill & Exchange Pricing Table */}
      <div className="glass-panel" style={{ padding: '20px' }}>
        <h3 style={{ fontSize: '1rem', fontWeight: 800, color: '#ffffff', marginBottom: '16px' }}>
          Company Refill & Exchange Price Catalogue
        </h3>

        <div style={{ overflowX: 'auto' }}>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '0.85rem' }}>
            <thead>
              <tr style={{ borderBottom: '1px solid var(--border-color)', textAlign: 'left', color: 'var(--text-secondary)' }}>
                <th style={{ padding: '10px' }}>Cylinder Size</th>
                <th style={{ padding: '10px' }}>Product Name</th>
                <th style={{ padding: '10px' }}>Refill Price</th>
                <th style={{ padding: '10px' }}>Exchange Price</th>
                <th style={{ padding: '10px' }}>Action</th>
              </tr>
            </thead>
            <tbody>
              {products.map((prod) => {
                const isEditing = editingPriceProductId === prod.product_id;
                const pPrices = provider.prices[prod.product_id] || { refill: 195, exchange: 320 };

                return (
                  <tr key={prod.product_id} style={{ borderBottom: '1px solid rgba(255,255,255,0.05)' }}>
                    <td style={{ padding: '12px 10px', fontWeight: 900, color: 'var(--brand-orange)' }}>{prod.size}</td>
                    <td style={{ padding: '12px 10px', color: '#ffffff' }}>{prod.name}</td>
                    <td style={{ padding: '12px 10px', color: '#ffffff' }}>
                      {isEditing ? (
                        <input
                          type="number"
                          value={refillInput}
                          onChange={(e) => setRefillInput(Number(e.target.value))}
                          style={{ width: '80px', padding: '4px', background: 'rgba(255,255,255,0.1)', color: '#fff', border: '1px solid var(--border-color)', borderRadius: '4px' }}
                        />
                      ) : (
                        `${currencySymbol}${pPrices.refill.toFixed(2)}`
                      )}
                    </td>
                    <td style={{ padding: '12px 10px', color: '#ffffff' }}>
                      {isEditing ? (
                        <input
                          type="number"
                          value={exchangeInput}
                          onChange={(e) => setExchangeInput(Number(e.target.value))}
                          style={{ width: '80px', padding: '4px', background: 'rgba(255,255,255,0.1)', color: '#fff', border: '1px solid var(--border-color)', borderRadius: '4px' }}
                        />
                      ) : (
                        `${currencySymbol}${pPrices.exchange.toFixed(2)}`
                      )}
                    </td>
                    <td style={{ padding: '12px 10px' }}>
                      {isEditing ? (
                        <button
                          onClick={() => handleSavePrices(prod.product_id)}
                          className="glow-btn"
                          style={{ padding: '4px 10px', fontSize: '0.75rem' }}
                        >
                          <Save size={14} /> Save
                        </button>
                      ) : (
                        <button
                          onClick={() => handleStartEdit(prod)}
                          className="secondary-btn"
                          style={{ padding: '4px 10px', fontSize: '0.75rem' }}
                        >
                          <Edit3 size={14} /> Edit Price
                        </button>
                      )}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </div>

      {/* Depot Stock Matrix */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '16px' }}>
        {providerDepots.map((depot) => (
          <div key={depot.depot_id} className="glass-panel" style={{ padding: '20px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', marginBottom: '14px' }}>
              <Warehouse size={22} color="var(--brand-orange)" />
              <div>
                <h4 style={{ fontSize: '1rem', fontWeight: 800, color: '#ffffff' }}>{depot.name}</h4>
                <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{depot.location}</p>
              </div>
            </div>

            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              {products.map((prod) => {
                const stockQty = depot.stock[prod.product_id] || 0;
                const isLow = stockQty < 25;

                return (
                  <div
                    key={prod.product_id}
                    style={{
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      padding: '8px 10px',
                      background: isLow ? 'rgba(239,68,68,0.1)' : 'rgba(255,255,255,0.03)',
                      borderRadius: '6px',
                      border: `1px solid ${isLow ? 'rgba(239,68,68,0.3)' : 'var(--border-color)'}`,
                    }}
                  >
                    <div>
                      <span style={{ fontSize: '0.85rem', fontWeight: 800, color: '#ffffff' }}>{prod.size}</span>
                      {isLow && <span style={{ fontSize: '0.65rem', color: '#f87171', marginLeft: '8px' }}>⚠️ LOW STOCK</span>}
                    </div>

                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                      <input
                        type="number"
                        value={stockQty}
                        onChange={(e) => onUpdateStock(depot.depot_id, prod.product_id, Number(e.target.value))}
                        style={{
                          width: '60px',
                          padding: '4px 6px',
                          background: 'rgba(255,255,255,0.1)',
                          border: '1px solid var(--border-color)',
                          borderRadius: '4px',
                          color: '#ffffff',
                          fontWeight: 800,
                          fontSize: '0.85rem',
                          textAlign: 'center',
                        }}
                      />
                      <span style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Units</span>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};
