import React, { useState } from 'react';
import { useAppStore } from '../../store/useStore';
import { GasProvider, District, ComplianceStatus } from '../../types';
import { 
  ShieldCheck, ShieldAlert, Building2, Plus, Users, DollarSign, 
  CheckCircle2, AlertTriangle, XCircle, Search, Filter, Layers, Globe, Power
} from 'lucide-react';

export const SuperAdminDashboard: React.FC = () => {
  const store = useAppStore();
  const [activeSubTab, setActiveSubTab] = useState<'providers' | 'onboarding' | 'compliance' | 'districts'>('providers');
  const [searchTerm, setSearchTerm] = useState('');
  const [complianceFilter, setComplianceFilter] = useState<string>('all');

  // New Provider Form State
  const [newCompanyName, setNewCompanyName] = useState('');
  const [newLicenseNo, setNewLicenseNo] = useState('');
  const [newPhone, setNewPhone] = useState('');
  const [newEmail, setNewEmail] = useState('');
  const [newFee, setNewFee] = useState<number>(25);
  const [selectedDistricts, setSelectedDistricts] = useState<District[]>(['Gaborone Central']);

  // Global calculations
  const totalSystemOrders = store.orders.length + 2840;
  const grossPlatformRevenue = store.orders.reduce((acc, o) => acc + o.total_amount, 0) + 248900;
  const platformCommission = grossPlatformRevenue * 0.05; // 5% platform cut

  const filteredProviders = store.providers.filter((p) => {
    const matchesSearch = p.company_name.toLowerCase().includes(searchTerm.toLowerCase()) || p.license_number.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = complianceFilter === 'all' || p.compliance_status === complianceFilter;
    return matchesSearch && matchesStatus;
  });

  const handleRegisterNewProvider = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newCompanyName || !newLicenseNo) return;

    store.registerGasProvider({
      company_name: newCompanyName,
      slug: newCompanyName.toLowerCase().replace(/\s+/g, '-'),
      logo_url: 'https://images.unsplash.com/photo-1584269600464-37b1b58a9fe7?auto=format&fit=crop&w=150&q=80',
      description: 'Newly registered certified LPG gas provider.',
      districts_served: selectedDistricts,
      license_number: newLicenseNo,
      contact_phone: newPhone || '+267 390 0000',
      contact_email: newEmail || 'admin@company.bw',
      base_delivery_fee: Number(newFee),
      est_delivery_mins: 35,
      prices: {
        'prod-3kg': { refill: 65, exchange: 110 },
        'prod-5kg': { refill: 115, exchange: 185 },
        'prod-9kg': { refill: 195, exchange: 320 },
        'prod-14kg': { refill: 290, exchange: 460 },
        'prod-19kg': { refill: 395, exchange: 620 },
        'prod-48kg': { refill: 950, exchange: 1450 },
      }
    });

    setNewCompanyName('');
    setNewLicenseNo('');
    setNewPhone('');
    setNewEmail('');
    setActiveSubTab('providers');
  };

  const toggleDistrictSelection = (dist: District) => {
    if (selectedDistricts.includes(dist)) {
      setSelectedDistricts((prev) => prev.filter((d) => d !== dist));
    } else {
      setSelectedDistricts((prev) => [...prev, dist]);
    }
  };

  return (
    <div style={{ display: 'flex', minHeight: 'calc(100vh - 60px)', background: '#070b14' }}>
      {/* Super Admin Left Sidebar */}
      <aside
        style={{
          width: '260px',
          background: '#04070f',
          borderRight: '1px solid var(--border-color)',
          padding: '24px 16px',
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'space-between',
        }}
      >
        <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', padding: '0 4px' }}>
            <div
              style={{
                width: '38px',
                height: '38px',
                borderRadius: '10px',
                background: 'linear-gradient(135deg, #00f0ff, #0088ff)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                boxShadow: '0 0 14px rgba(0,240,255,0.4)',
              }}
            >
              <ShieldCheck size={22} color="#ffffff" />
            </div>
            <div>
              <h2 style={{ fontSize: '0.95rem', fontWeight: 900, color: '#ffffff', letterSpacing: '0.5px' }}>
                SUPER ADMIN
              </h2>
              <p style={{ fontSize: '0.65rem', color: '#00f0ff', fontWeight: 700 }}>SYSTEM GOVERNANCE HUB</p>
            </div>
          </div>

          <nav style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
            {[
              { key: 'providers', label: 'Gas Provider Directory', icon: <Building2 size={18} /> },
              { key: 'onboarding', label: 'Register New Provider', icon: <Plus size={18} /> },
              { key: 'compliance', label: 'Compliance & Audits', icon: <ShieldAlert size={18} /> },
              { key: 'districts', label: 'District Coverage', icon: <Globe size={18} /> },
            ].map((tab) => {
              const isActive = activeSubTab === tab.key;
              return (
                <button
                  key={tab.key}
                  onClick={() => setActiveSubTab(tab.key as any)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '12px',
                    padding: '12px 14px',
                    borderRadius: 'var(--radius-sm)',
                    fontSize: '0.85rem',
                    fontWeight: 700,
                    background: isActive ? 'var(--brand-orange)' : 'transparent',
                    color: isActive ? '#ffffff' : 'var(--text-secondary)',
                    textAlign: 'left',
                  }}
                >
                  {tab.icon}
                  {tab.label}
                </button>
              );
            })}
          </nav>
        </div>

        <div className="glass-panel" style={{ padding: '14px', textAlign: 'center', borderColor: 'rgba(0,240,255,0.3)' }}>
          <span style={{ fontSize: '0.65rem', color: '#00f0ff', fontWeight: 800 }}>MASTER CONTROLLER</span>
          <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', marginTop: '2px' }}>
            Full Authority over Gas Companies & Compliance
          </p>
        </div>
      </aside>

      {/* Main Panel */}
      <main style={{ flex: 1, padding: '28px', overflowY: 'auto' }}>
        {/* Top Master Metrics Banner */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '16px', marginBottom: '24px' }}>
          <div className="glass-panel" style={{ padding: '18px' }}>
            <span style={{ fontSize: '0.75rem', fontWeight: 700, color: 'var(--text-secondary)' }}>REGISTERED GAS COMPANIES</span>
            <h3 style={{ fontSize: '1.6rem', fontWeight: 900, color: '#ffffff', marginTop: '6px' }}>
              {store.providers.length} Companies
            </h3>
            <p style={{ fontSize: '0.7rem', color: '#4ade80', fontWeight: 700, marginTop: '4px' }}>
              {store.providers.filter((p) => p.compliance_status === 'approved').length} Compliant & Active
            </p>
          </div>

          <div className="glass-panel" style={{ padding: '18px' }}>
            <span style={{ fontSize: '0.75rem', fontWeight: 700, color: 'var(--text-secondary)' }}>SYSTEM PLATFORM GMV</span>
            <h3 style={{ fontSize: '1.6rem', fontWeight: 900, color: '#ffffff', marginTop: '6px' }}>
              {store.currencySymbol}{grossPlatformRevenue.toLocaleString(undefined, { minimumFractionDigits: 2 })}
            </h3>
            <p style={{ fontSize: '0.7rem', color: 'var(--brand-orange)', fontWeight: 700, marginTop: '4px' }}>
              Across {totalSystemOrders.toLocaleString()} Orders
            </p>
          </div>

          <div className="glass-panel" style={{ padding: '18px' }}>
            <span style={{ fontSize: '0.75rem', fontWeight: 700, color: 'var(--text-secondary)' }}>PLATFORM COMMISSION (5%)</span>
            <h3 style={{ fontSize: '1.6rem', fontWeight: 900, color: '#00f0ff', marginTop: '6px' }}>
              {store.currencySymbol}{platformCommission.toLocaleString(undefined, { minimumFractionDigits: 2 })}
            </h3>
            <p style={{ fontSize: '0.7rem', color: 'var(--text-muted)', marginTop: '4px' }}>System net earnings</p>
          </div>

          <div className="glass-panel" style={{ padding: '18px' }}>
            <span style={{ fontSize: '0.75rem', fontWeight: 700, color: 'var(--text-secondary)' }}>COMPLIANCE ALERTS</span>
            <h3 style={{ fontSize: '1.6rem', fontWeight: 900, color: store.providers.some((p) => p.compliance_status === 'under_review') ? '#ffb703' : '#4ade80', marginTop: '6px' }}>
              {store.providers.filter((p) => p.compliance_status !== 'approved').length} Pending / Flagged
            </h3>
            <p style={{ fontSize: '0.7rem', color: 'var(--text-secondary)', marginTop: '4px' }}>Safety audit actions</p>
          </div>
        </div>

        {/* SubTab 1: Providers Directory */}
        {activeSubTab === 'providers' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '12px' }}>
              <div>
                <h2 style={{ fontSize: '1.4rem', fontWeight: 800, color: '#ffffff' }}>Gas Provider Master Directory</h2>
                <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>Monitor registered LPG providers, licenses, and operating statuses</p>
              </div>

              <div style={{ display: 'flex', gap: '10px' }}>
                <div style={{ position: 'relative' }}>
                  <Search size={16} color="var(--text-muted)" style={{ position: 'absolute', left: '10px', top: '10px' }} />
                  <input
                    type="text"
                    placeholder="Search Gas Company or License..."
                    value={searchTerm}
                    onChange={(e) => setSearchTerm(e.target.value)}
                    style={{
                      padding: '8px 12px 8px 34px',
                      background: 'rgba(255,255,255,0.05)',
                      border: '1px solid var(--border-color)',
                      borderRadius: '8px',
                      color: '#ffffff',
                      fontSize: '0.85rem',
                    }}
                  />
                </div>

                <select
                  value={complianceFilter}
                  onChange={(e) => setComplianceFilter(e.target.value)}
                  style={{
                    background: 'rgba(255,255,255,0.05)',
                    border: '1px solid var(--border-color)',
                    color: '#ffffff',
                    padding: '8px 12px',
                    borderRadius: '8px',
                    fontSize: '0.85rem',
                  }}
                >
                  <option value="all">All Compliance Statuses</option>
                  <option value="approved">Approved</option>
                  <option value="under_review">Under Review</option>
                  <option value="suspended">Suspended</option>
                </select>
              </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: '16px' }}>
              {filteredProviders.map((prov) => (
                <div key={prov.provider_id} className="glass-panel" style={{ padding: '18px', display: 'flex', flexDirection: 'column', gap: '14px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <img
                      src={prov.logo_url}
                      alt={prov.company_name}
                      style={{ width: '48px', height: '48px', borderRadius: '10px', objectFit: 'cover' }}
                    />
                    <div style={{ flex: 1 }}>
                      <h4 style={{ fontSize: '1rem', fontWeight: 800, color: '#ffffff' }}>{prov.company_name}</h4>
                      <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>License: {prov.license_number}</p>
                      <div style={{ display: 'flex', gap: '6px', marginTop: '4px' }}>
                        <span
                          style={{
                            fontSize: '0.65rem',
                            fontWeight: 800,
                            padding: '2px 8px',
                            borderRadius: '4px',
                            background:
                              prov.compliance_status === 'approved'
                                ? 'rgba(34,197,94,0.15)'
                                : prov.compliance_status === 'under_review'
                                ? 'rgba(255,183,3,0.15)'
                                : 'rgba(239,68,68,0.15)',
                            color:
                              prov.compliance_status === 'approved'
                                ? '#4ade80'
                                : prov.compliance_status === 'under_review'
                                ? '#ffb703'
                                : '#f87171',
                          }}
                        >
                          {prov.compliance_status.toUpperCase()}
                        </span>
                        <span style={{ fontSize: '0.65rem', color: '#00f0ff', fontWeight: 700 }}>
                          ★ {prov.rating} ({prov.review_count} reviews)
                        </span>
                      </div>
                    </div>
                  </div>

                  <div style={{ height: '1px', background: 'var(--border-color)' }} />

                  <div style={{ display: 'flex', flexDirection: 'column', gap: '4px', fontSize: '0.75rem', color: 'var(--text-secondary)' }}>
                    <div>Safety Score: <strong style={{ color: '#ffffff' }}>{prov.safety_score}% Certified</strong></div>
                    <div>Districts Served: <strong style={{ color: '#ffffff' }}>{prov.districts_served.join(', ')}</strong></div>
                    <div>Base Delivery Fee: <strong style={{ color: 'var(--brand-orange)' }}>{store.currencySymbol}{prov.base_delivery_fee.toFixed(2)}</strong></div>
                    <div>Contact Phone: <strong style={{ color: '#ffffff' }}>{prov.contact_phone}</strong></div>
                  </div>

                  <div style={{ display: 'flex', gap: '8px', marginTop: '6px' }}>
                    {prov.compliance_status === 'approved' ? (
                      <button
                        onClick={() => store.updateProviderCompliance(prov.provider_id, 'suspended')}
                        style={{
                          flex: 1,
                          padding: '8px',
                          borderRadius: '6px',
                          background: 'rgba(239,68,68,0.2)',
                          color: '#f87171',
                          border: '1px solid rgba(239,68,68,0.4)',
                          fontWeight: 700,
                          fontSize: '0.75rem',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          gap: '6px',
                        }}
                      >
                        <XCircle size={14} /> Suspend / Remove Provider
                      </button>
                    ) : (
                      <button
                        onClick={() => store.updateProviderCompliance(prov.provider_id, 'approved')}
                        className="glow-btn"
                        style={{ flex: 1, padding: '8px', fontSize: '0.75rem', background: 'linear-gradient(135deg, #22c55e, #16a34a)' }}
                      >
                        <CheckCircle2 size={14} /> Approve Compliance License
                      </button>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* SubTab 2: Register New Gas Provider */}
        {activeSubTab === 'onboarding' && (
          <div style={{ maxWidth: '600px' }}>
            <div style={{ marginBottom: '20px' }}>
              <h2 style={{ fontSize: '1.4rem', fontWeight: 800, color: '#ffffff' }}>Register New Gas Company & Admin</h2>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>Onboard an authorized LPG provider into the delivery platform network</p>
            </div>

            <form onSubmit={handleRegisterNewProvider} className="glass-panel" style={{ padding: '24px', display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div>
                <label style={{ fontSize: '0.75rem', fontWeight: 700, color: 'var(--text-secondary)' }}>COMPANY / PROVIDER NAME</label>
                <input
                  type="text"
                  placeholder="e.g. TotalEnergies LPG Botswana"
                  value={newCompanyName}
                  onChange={(e) => setNewCompanyName(e.target.value)}
                  style={{ width: '100%', padding: '10px', marginTop: '4px', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-color)', borderRadius: '8px', color: '#fff' }}
                  required
                />
              </div>

              <div>
                <label style={{ fontSize: '0.75rem', fontWeight: 700, color: 'var(--text-secondary)' }}>COMMERCIAL SAFETY LICENSE NUMBER</label>
                <input
                  type="text"
                  placeholder="e.g. BW-LPG-99481-TOT"
                  value={newLicenseNo}
                  onChange={(e) => setNewLicenseNo(e.target.value)}
                  style={{ width: '100%', padding: '10px', marginTop: '4px', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-color)', borderRadius: '8px', color: '#fff' }}
                  required
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={{ fontSize: '0.75rem', fontWeight: 700, color: 'var(--text-secondary)' }}>CONTACT PHONE</label>
                  <input
                    type="text"
                    placeholder="+267 390 1234"
                    value={newPhone}
                    onChange={(e) => setNewPhone(e.target.value)}
                    style={{ width: '100%', padding: '10px', marginTop: '4px', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-color)', borderRadius: '8px', color: '#fff' }}
                  />
                </div>
                <div>
                  <label style={{ fontSize: '0.75rem', fontWeight: 700, color: 'var(--text-secondary)' }}>BASE DELIVERY FEE ({store.currencySymbol})</label>
                  <input
                    type="number"
                    value={newFee}
                    onChange={(e) => setNewFee(Number(e.target.value))}
                    style={{ width: '100%', padding: '10px', marginTop: '4px', background: 'rgba(255,255,255,0.05)', border: '1px solid var(--border-color)', borderRadius: '8px', color: '#fff' }}
                  />
                </div>
              </div>

              <div>
                <label style={{ fontSize: '0.75rem', fontWeight: 700, color: 'var(--text-secondary)' }}>DISTRICTS SERVED</label>
                <div style={{ display: 'flex', flexWrap: 'wrap', gap: '8px', marginTop: '6px' }}>
                  {store.districts.map((d) => {
                    const isSelected = selectedDistricts.includes(d);
                    return (
                      <button
                        type="button"
                        key={d}
                        onClick={() => toggleDistrictSelection(d)}
                        style={{
                          padding: '6px 12px',
                          borderRadius: '6px',
                          fontSize: '0.75rem',
                          fontWeight: 700,
                          background: isSelected ? 'var(--brand-orange)' : 'rgba(255,255,255,0.08)',
                          color: '#ffffff',
                        }}
                      >
                        {d} {isSelected ? '✓' : '+'}
                      </button>
                    );
                  })}
                </div>
              </div>

              <button type="submit" className="glow-btn" style={{ padding: '14px', marginTop: '10px' }}>
                <CheckCircle2 size={18} /> Approve & Onboard Gas Provider
              </button>
            </form>
          </div>
        )}

        {/* SubTab 3: Compliance & Audits */}
        {activeSubTab === 'compliance' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div>
              <h2 style={{ fontSize: '1.4rem', fontWeight: 800, color: '#ffffff' }}>Safety Audit & Regulatory Compliance</h2>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
                System-wide compliance monitoring for cylinder hydro-testing and safety scores
              </p>
            </div>

            <div className="glass-panel" style={{ padding: '20px' }}>
              <div style={{ overflowX: 'auto' }}>
                <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: '0.85rem' }}>
                  <thead>
                    <tr style={{ borderBottom: '1px solid var(--border-color)', textAlign: 'left', color: 'var(--text-secondary)' }}>
                      <th style={{ padding: '10px' }}>Provider Name</th>
                      <th style={{ padding: '10px' }}>License Ref</th>
                      <th style={{ padding: '10px' }}>Safety Audit Score</th>
                      <th style={{ padding: '10px' }}>Compliance Status</th>
                      <th style={{ padding: '10px' }}>Super Admin Action</th>
                    </tr>
                  </thead>
                  <tbody>
                    {store.providers.map((p) => (
                      <tr key={p.provider_id} style={{ borderBottom: '1px solid rgba(255,255,255,0.05)' }}>
                        <td style={{ padding: '12px 10px', fontWeight: 800, color: '#ffffff' }}>{p.company_name}</td>
                        <td style={{ padding: '12px 10px', color: 'var(--text-secondary)' }}>{p.license_number}</td>
                        <td style={{ padding: '12px 10px' }}>
                          <span style={{ fontWeight: 800, color: p.safety_score > 90 ? '#4ade80' : '#ffb703' }}>
                            {p.safety_score}% Verified
                          </span>
                        </td>
                        <td style={{ padding: '12px 10px' }}>
                          <span
                            style={{
                              fontSize: '0.7rem',
                              fontWeight: 800,
                              padding: '2px 8px',
                              borderRadius: '4px',
                              background: p.compliance_status === 'approved' ? 'rgba(34,197,94,0.15)' : 'rgba(255,183,3,0.15)',
                              color: p.compliance_status === 'approved' ? '#4ade80' : '#ffb703',
                            }}
                          >
                            {p.compliance_status.toUpperCase()}
                          </span>
                        </td>
                        <td style={{ padding: '12px 10px' }}>
                          {p.compliance_status === 'approved' ? (
                            <button
                              onClick={() => store.updateProviderCompliance(p.provider_id, 'suspended')}
                              style={{ padding: '4px 10px', background: 'rgba(239,68,68,0.2)', color: '#f87171', borderRadius: '4px', fontSize: '0.75rem', fontWeight: 700 }}
                            >
                              Suspend Provider
                            </button>
                          ) : (
                            <button
                              onClick={() => store.updateProviderCompliance(p.provider_id, 'approved')}
                              style={{ padding: '4px 10px', background: '#4ade80', color: '#0f172a', borderRadius: '4px', fontSize: '0.75rem', fontWeight: 800 }}
                            >
                              Approve Compliance
                            </button>
                          )}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        )}

        {/* SubTab 4: District Coverage */}
        {activeSubTab === 'districts' && (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div>
              <h2 style={{ fontSize: '1.4rem', fontWeight: 800, color: '#ffffff' }}>District Coverage Matrix</h2>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>Density of registered LPG gas suppliers per region</p>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '16px' }}>
              {store.districts.map((d) => {
                const providersInDist = store.providers.filter((p) => p.compliance_status === 'approved' && p.districts_served.includes(d));
                return (
                  <div key={d} className="glass-panel" style={{ padding: '18px', display: 'flex', flexDirection: 'column', gap: '10px' }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                      <h4 style={{ fontSize: '1.05rem', fontWeight: 800, color: '#ffffff' }}>{d}</h4>
                      <span style={{ fontSize: '0.75rem', color: 'var(--brand-orange)', fontWeight: 800 }}>
                        {providersInDist.length} Providers
                      </span>
                    </div>

                    <div style={{ height: '1px', background: 'var(--border-color)' }} />

                    <div style={{ display: 'flex', flexDirection: 'column', gap: '6px' }}>
                      {providersInDist.map((p) => (
                        <div key={p.provider_id} style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
                          <span style={{ color: '#4ade80' }}>✓</span> {p.company_name} ({store.currencySymbol}{p.base_delivery_fee.toFixed(0)} deliv)
                        </div>
                      ))}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        )}
      </main>
    </div>
  );
};
