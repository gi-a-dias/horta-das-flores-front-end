import { FormEvent, ReactNode, useState } from 'react'

type Screen = 'login' | 'garden' | 'irrigation'

type IconName =
  | 'arrow-left'
  | 'chevron-left'
  | 'chevron-right'
  | 'coin'
  | 'droplet'
  | 'eye'
  | 'eye-off'
  | 'home'
  | 'leaf'
  | 'lock'
  | 'logout'
  | 'sprout'
  | 'user'
  | 'water'

const iconPaths: Record<IconName, ReactNode> = {
  'arrow-left': <path d="m15 18-6-6 6-6M9 12h10" />,
  'chevron-left': <path d="m15 18-6-6 6-6" />,
  'chevron-right': <path d="m9 18 6-6-6-6" />,
  coin: (
    <>
      <circle cx="12" cy="12" r="8" />
      <path d="M14.7 8.8c-.5-.5-1.3-.8-2.2-.8-1.4 0-2.5.7-2.5 1.7s.8 1.5 2.6 1.9c1.7.4 2.4.9 2.4 1.9 0 1.1-1.1 1.9-2.7 1.9-.9 0-1.9-.3-2.6-.9M12.4 6.5v11" />
    </>
  ),
  droplet: <path d="M12 3.2S6.5 9.2 6.5 13.7a5.5 5.5 0 0 0 11 0C17.5 9.2 12 3.2 12 3.2Z" />,
  eye: (
    <>
      <path d="M2.5 12s3.4-5 9.5-5 9.5 5 9.5 5-3.4 5-9.5 5-9.5-5-9.5-5Z" />
      <circle cx="12" cy="12" r="2.3" />
    </>
  ),
  'eye-off': (
    <>
      <path d="m3 3 18 18M10.7 7.1c.4-.1.8-.1 1.3-.1 6.1 0 9.5 5 9.5 5a14 14 0 0 1-2.1 2.5M6.2 6.2C3.8 7.8 2.5 12 2.5 12s3.4 5 9.5 5c1.4 0 2.7-.3 3.7-.7" />
    </>
  ),
  home: (
    <>
      <path d="m3.5 10 8.5-7 8.5 7" />
      <path d="M5.5 9v11h13V9M9.5 20v-6h5v6" />
    </>
  ),
  leaf: (
    <>
      <path d="M5 20c0-7 4.4-12 14-15 0 9.2-4.8 14-12.2 13" />
      <path d="M5 20c3.2-4.7 6.3-7.5 10.5-10" />
    </>
  ),
  lock: (
    <>
      <rect x="5" y="10" width="14" height="11" rx="3" />
      <path d="M8 10V7a4 4 0 0 1 8 0v3M12 14.5v2.5" />
    </>
  ),
  logout: (
    <>
      <path d="M10 5H5v14h5M14 8l4 4-4 4M9 12h9" />
    </>
  ),
  sprout: (
    <>
      <path d="M12 21V10" />
      <path d="M12 12C6.5 12 4 9.5 4 5c5.5 0 8 2.5 8 7ZM12 16c5 0 8-2.5 8-7-5 0-8 2.5-8 7Z" />
    </>
  ),
  user: (
    <>
      <circle cx="12" cy="8" r="4" />
      <path d="M4.5 21c.5-4.5 3-6.5 7.5-6.5s7 2 7.5 6.5" />
    </>
  ),
  water: (
    <>
      <path d="M9 3v6M15 3v6M6 9h12l-1.5 11h-9L6 9Z" />
      <path d="M8 13c2 1 6 1 8 0" />
    </>
  ),
}

function Icon({ name, size = 22 }: { name: IconName; size?: number }) {
  return (
    <svg
      aria-hidden="true"
      className="icon"
      fill="none"
      height={size}
      viewBox="0 0 24 24"
      width={size}
    >
      {iconPaths[name]}
    </svg>
  )
}

function AppButton({
  children,
  className = '',
  onClick,
  type = 'button',
}: {
  children: ReactNode
  className?: string
  onClick?: () => void
  type?: 'button' | 'submit'
}) {
  return (
    <button className={`app-button ${className}`} onClick={onClick} type={type}>
      {children}
    </button>
  )
}

function BrandMark({ compact = false }: { compact?: boolean }) {
  return (
    <div className={`brand-mark ${compact ? 'brand-mark--compact' : ''}`} aria-hidden="true">
      <div className="brand-glow" />
      <div className="greenhouse">
        <span className="greenhouse-roof" />
        <span className="greenhouse-frame" />
        <span className="greenhouse-soil" />
        <span className="greenhouse-sprout">
          <Icon name="sprout" size={compact ? 30 : 44} />
        </span>
      </div>
    </div>
  )
}

function LoginScreen({ onEnter }: { onEnter: () => void }) {
  const [showPassword, setShowPassword] = useState(false)

  function submit(event: FormEvent) {
    event.preventDefault()
    onEnter()
  }

  return (
    <main className="screen login-screen">
      <div className="botanical-pattern" aria-hidden="true">
        <span className="pattern-leaf pattern-leaf--one" />
        <span className="pattern-leaf pattern-leaf--two" />
        <span className="pattern-leaf pattern-leaf--three" />
        <span className="pattern-leaf pattern-leaf--four" />
      </div>

      <div className="login-content">
        <section className="login-hero" aria-labelledby="login-title">
          <BrandMark />
          <p className="eyebrow">CULTIVE • CONECTE • TRANSFORME</p>
          <h1 id="login-title">Horta das Flores</h1>
          <p className="hero-subtitle">Monitoramento IoT &amp; Cultivo Comunitário</p>
        </section>

        <form className="login-form" onSubmit={submit}>
          <label className="field">
            <span className="sr-only">E-mail ou Usuário</span>
            <span className="field-icon"><Icon name="user" /></span>
            <input autoComplete="username" placeholder="E-mail ou Usuário" type="text" />
          </label>

          <label className="field">
            <span className="sr-only">Senha</span>
            <span className="field-icon"><Icon name="lock" /></span>
            <input
              autoComplete="current-password"
              placeholder="Senha"
              type={showPassword ? 'text' : 'password'}
            />
            <button
              aria-label={showPassword ? 'Ocultar senha' : 'Mostrar senha'}
              className="visibility-button"
              onClick={() => setShowPassword((value) => !value)}
              type="button"
            >
              <Icon name={showPassword ? 'eye-off' : 'eye'} />
            </button>
          </label>

          <button className="forgot-link" type="button">Esqueceu a senha?</button>

          <AppButton className="primary-button" type="submit">
            Entrar no Jardim
            <Icon name="chevron-right" size={20} />
          </AppButton>
          <AppButton className="secondary-button" onClick={onEnter}>
            <Icon name="leaf" size={20} />
            Continuar como Voluntário Convidado
          </AppButton>
        </form>

        <p className="signup-copy">
          Novo na horta? <button type="button">Cadastre-se</button>
        </p>
      </div>
    </main>
  )
}

function CurrencyBadge({
  icon,
  value,
  variant,
}: {
  icon: IconName
  value: string
  variant: 'gold' | 'cyan'
}) {
  return (
    <div className={`currency currency--${variant}`} aria-label={`${value} recursos`}>
      <span><Icon name={icon} size={16} /></span>
      <strong>{value}</strong>
    </div>
  )
}

function GardenIllustration({ onOpenSensor }: { onOpenSensor: () => void }) {
  return (
    <button
      aria-label="Abrir Canteiro 1, umidade 78%"
      className="garden-map"
      onClick={onOpenSensor}
      type="button"
    >
      <div className="map-sky">
        <span className="cloud cloud--one" />
        <span className="cloud cloud--two" />
      </div>
      <div className="floating-island">
        <div className="island-top">
          <div className="path path--one" />
          <div className="path path--two" />
          <div className="bed bed--one">
            <span /><span /><span /><span />
          </div>
          <div className="bed bed--two">
            <span /><span /><span />
          </div>
          <div className="bed bed--three">
            <span /><span /><span />
          </div>
          <div className="pond"><i /><i /><i /></div>
          <div className="tree tree--one"><i /><span /></div>
          <div className="tree tree--two"><i /><span /></div>
          <div className="tree tree--three"><i /><span /></div>
          <div className="sensor-pin">
            <span><Icon name="droplet" size={14} /></span>
            <strong>78%</strong>
          </div>
        </div>
        <div className="island-side" />
      </div>
      <div className="map-caption">
        <span><Icon name="sprout" size={17} /> 10 canteiros conectados</span>
        <strong>Toque para explorar</strong>
      </div>
    </button>
  )
}

const moistureValues = [54, 69, 61, 78, 64, 72, 58, 67, 75, 63]

function AnalyticsCard({ onOpenSensor }: { onOpenSensor: () => void }) {
  return (
    <section className="analytics-card" aria-labelledby="analytics-title">
      <div className="analytics-heading">
        <div>
          <p>ANÁLISE DOS SENSORES</p>
          <h2 id="analytics-title">Umidade do Solo</h2>
        </div>
        <div className="active-beds"><span /> Canteiros Ativos: <strong>10</strong></div>
      </div>

      <div className="chart-area">
        <div className="chart-scale" aria-hidden="true">
          <span>100</span><span>50</span><span>0</span>
        </div>
        <div className="bar-chart" role="img" aria-label="Gráfico de umidade dos dez canteiros">
          {moistureValues.map((value, index) => (
            <button
              aria-label={`Canteiro ${index + 1}: ${value}% de umidade`}
              className={index === 3 ? 'bar-column bar-column--active' : 'bar-column'}
              key={index}
              onClick={index === 3 ? onOpenSensor : undefined}
              type="button"
            >
              <span className="bar-value">{value}%</span>
              <span className="bar-fill" style={{ height: `${value}%` }} />
              <small>{index + 1}</small>
            </button>
          ))}
        </div>
      </div>

      <button className="wettest-badge" onClick={onOpenSensor} type="button">
        <span className="wettest-icon"><Icon name="droplet" size={19} /></span>
        <span>
          <small>CANTEIRO MAIS ÚMIDO</small>
          <strong>Canteiro 4 • Sensor ESP32</strong>
        </span>
        <Icon name="chevron-right" size={19} />
      </button>
    </section>
  )
}

function BottomDock({
  active,
  onChange,
}: {
  active: Screen
  onChange: (screen: Screen) => void
}) {
  return (
    <nav className="bottom-dock" aria-label="Navegação principal">
      <button
        aria-current={active === 'garden' ? 'page' : undefined}
        className={active === 'garden' ? 'dock-item dock-item--active' : 'dock-item'}
        onClick={() => onChange('garden')}
        type="button"
      >
        <Icon name="home" size={21} />
        <span>Jardim</span>
      </button>
      <button
        aria-current={active === 'irrigation' ? 'page' : undefined}
        className={active === 'irrigation' ? 'dock-item dock-item--active' : 'dock-item'}
        onClick={() => onChange('irrigation')}
        type="button"
      >
        <Icon name="water" size={21} />
        <span>Rega</span>
      </button>
      <button className="dock-item" onClick={() => onChange('login')} type="button">
        <Icon name="logout" size={21} />
        <span>Sair</span>
      </button>
    </nav>
  )
}

function GardenScreen({ onNavigate }: { onNavigate: (screen: Screen) => void }) {
  const [period, setPeriod] = useState('Mês')

  return (
    <main className="screen garden-screen">
      <header className="garden-header">
        <div className="header-topline">
          <div className="header-brand">
            <BrandMark compact />
            <div>
              <span>HORTA DAS FLORES</span>
              <strong>Visão Geral</strong>
            </div>
          </div>
          <div className="currency-row">
            <CurrencyBadge icon="coin" value="1.569" variant="gold" />
            <CurrencyBadge icon="droplet" value="137" variant="cyan" />
          </div>
        </div>
        <div className="month-selector">
          <button aria-label="Mês anterior" type="button"><Icon name="chevron-left" size={20} /></button>
          <div><small>PERÍODO ATUAL</small><strong>Set 2026</strong></div>
          <button aria-label="Próximo mês" type="button"><Icon name="chevron-right" size={20} /></button>
        </div>
      </header>

      <div className="garden-content">
        <div className="period-tabs" aria-label="Filtrar período">
          {['Dia', 'Semana', 'Mês', 'Ano'].map((item) => (
            <button
              aria-pressed={period === item}
              className={period === item ? 'period-tab period-tab--active' : 'period-tab'}
              key={item}
              onClick={() => setPeriod(item)}
              type="button"
            >
              {item}
            </button>
          ))}
        </div>
        <GardenIllustration onOpenSensor={() => onNavigate('irrigation')} />
        <AnalyticsCard onOpenSensor={() => onNavigate('irrigation')} />
      </div>
      <BottomDock active="garden" onChange={onNavigate} />
    </main>
  )
}

function PlantOrb() {
  return (
    <div className="orb-wrap" aria-hidden="true">
      <span className="orbit orbit--one" />
      <span className="orbit orbit--two" />
      <span className="orb-particle particle--one" />
      <span className="orb-particle particle--two" />
      <div className="plant-orb">
        <div className="orb-shine" />
        <svg className="plant-art" viewBox="0 0 180 180">
          <defs>
            <linearGradient id="trunk" x1="0" y1="0" x2="1" y2="1">
              <stop offset="0" stopColor="#9c643b" />
              <stop offset="1" stopColor="#5a3428" />
            </linearGradient>
            <linearGradient id="canopy" x1="0" y1="0" x2="1" y2="1">
              <stop offset="0" stopColor="#79e6a1" />
              <stop offset="1" stopColor="#15935a" />
            </linearGradient>
          </defs>
          <ellipse cx="90" cy="146" rx="52" ry="12" fill="#164d3a" opacity=".25" />
          <path d="M87 138c6-33 2-55-7-72M91 113c16-14 24-27 28-39M84 104c-15-9-25-21-30-34" fill="none" stroke="url(#trunk)" strokeLinecap="round" strokeWidth="12" />
          <g fill="url(#canopy)">
            <circle cx="79" cy="55" r="28" /><circle cx="52" cy="70" r="23" />
            <circle cx="106" cy="58" r="27" /><circle cx="124" cy="82" r="22" />
            <circle cx="84" cy="82" r="30" />
          </g>
          <g fill="#b7f2ca" opacity=".72">
            <circle cx="67" cy="44" r="8" /><circle cx="102" cy="44" r="7" />
            <circle cx="48" cy="66" r="6" />
          </g>
          <path d="M50 138c24-9 57-10 82 1-4 14-75 17-82-1Z" fill="#704a32" />
          <path d="M60 137c19-6 43-6 62 0-12 7-50 7-62 0Z" fill="#3d2c22" />
        </svg>
      </div>
    </div>
  )
}

function IrrigationScreen({ onNavigate }: { onNavigate: (screen: Screen) => void }) {
  const [watering, setWatering] = useState(false)

  return (
    <main className="screen irrigation-screen">
      <div className="irrigation-glow" aria-hidden="true" />
      <header className="sensor-header">
        <button
          aria-label="Voltar para o jardim"
          className="back-button"
          onClick={() => onNavigate('garden')}
          type="button"
        >
          <Icon name="arrow-left" size={21} />
        </button>
        <div className="breadcrumb">
          <small>HORTA</small>
          <strong>Canteiro 1 <span>•</span> Sensor ESP32</strong>
        </div>
        <CurrencyBadge icon="coin" value="1.569" variant="gold" />
      </header>

      <section className="sensor-content" aria-labelledby="moisture-reading">
        <div className="connection-status"><span /> SENSOR CONECTADO</div>
        <PlantOrb />
        <div className="sensor-reading">
          <p>UMIDADE DO SOLO</p>
          <h1 id="moisture-reading"><strong>78</strong><span>%</span></h1>
          <div className="ideal-status"><span><Icon name="leaf" size={16} /></span> Status: <strong>Solo Ideal</strong></div>
        </div>

        <div className="sensor-meta">
          <div><small>ÚLTIMA LEITURA</small><strong>Agora mesmo</strong></div>
          <span />
          <div><small>PRÓXIMA LEITURA</small><strong>em 4 min</strong></div>
        </div>

        <AppButton
          className={watering ? 'watering-button watering-button--active' : 'watering-button'}
          onClick={() => setWatering((value) => !value)}
        >
          <span className="watering-icon"><Icon name="water" size={24} /></span>
          <span>
            <small>{watering ? 'REGA EM ANDAMENTO' : 'AÇÃO MANUAL'}</small>
            <strong>{watering ? 'Finalizar Rega' : 'Iniciar Rega Presencial'}</strong>
          </span>
          <Icon name="chevron-right" size={21} />
        </AppButton>
      </section>
      <BottomDock active="irrigation" onChange={onNavigate} />
    </main>
  )
}

export default function App() {
  const [screen, setScreen] = useState<Screen>('login')

  return (
    <div className="app-shell">
      <div className="phone-viewport">
        {screen === 'login' && <LoginScreen onEnter={() => setScreen('garden')} />}
        {screen === 'garden' && <GardenScreen onNavigate={setScreen} />}
        {screen === 'irrigation' && <IrrigationScreen onNavigate={setScreen} />}
      </div>
    </div>
  )
}
