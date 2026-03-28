// ============================================================
// ASTANA PGL 2026 — SHARED UTILS
// ============================================================

const API = '';  // same origin — FastAPI serves from root

// ── FETCH HELPER ────────────────────────────────────────────
async function apiFetch(path) {
  const res = await fetch(API + path);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

// ── LOADING / ERROR HELPERS ──────────────────────────────────
function renderLoading(container) {
  container.innerHTML = `
    <div class="loading">
      <div class="spinner"></div>
      <div class="loading-text">ЗАГРУЗКА ДАННЫХ...</div>
    </div>`;
}

function renderError(container, msg = 'Ошибка загрузки данных') {
  container.innerHTML = `<div class="error-box">// ERR: ${msg}</div>`;
}

// ── STATUS HELPERS ───────────────────────────────────────────
function statusClass(status) {
  const map = { live: 'live', ongoing: 'live', upcoming: 'upcoming', scheduled: 'upcoming', finished: 'finished', completed: 'finished' };
  return map[status?.toLowerCase()] || 'upcoming';
}
function statusLabel(status) {
  const map = { live: 'LIVE', ongoing: 'LIVE', upcoming: 'СКОРО', scheduled: 'СКОРО', finished: 'ЗАВЕРШЁН', completed: 'ЗАВЕРШЁН' };
  return map[status?.toLowerCase()] || status?.toUpperCase();
}

// ── DATE FORMAT ──────────────────────────────────────────────
function fmtDate(iso) {
  if (!iso) return '—';
  const d = new Date(iso);
  return d.toLocaleString('ru-RU', { day: '2-digit', month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' });
}
function fmtDateShort(iso) {
  if (!iso) return '—';
  const d = new Date(iso);
  return d.toLocaleString('ru-RU', { day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit' });
}

// ── LOGO / FLAG FALLBACKS ────────────────────────────────────
function logoSrc(url) { return url || '/static/img/placeholder-logo.svg'; }
function flagSrc(url) { return url || ''; }

// ── RATING COLOR ─────────────────────────────────────────────
function ratingClass(r) {
  if (!r) return '';
  if (r >= 1.2) return 'rating-high';
  if (r < 0.8) return 'rating-low';
  return '';
}

// ── NAV ACTIVE STATE ─────────────────────────────────────────
function setNavActive() {
  const path = window.location.pathname;
  document.querySelectorAll('.nav-link').forEach(a => {
    const href = a.getAttribute('href') || '';
    if (href !== '/' && path.startsWith(href.replace('/static/', '/'))) {
      a.classList.add('active');
    } else if (href === '/static/index.html' && (path === '/' || path.endsWith('index.html'))) {
      a.classList.add('active');
    }
  });
}

// ── BURGER MENU ───────────────────────────────────────────────
function initBurger() {
  const burger = document.getElementById('burger');
  const menu = document.getElementById('mobileMenu');
  if (!burger || !menu) return;
  burger.addEventListener('click', () => {
    menu.classList.toggle('open');
    burger.classList.toggle('open');
  });
  menu.querySelectorAll('.m-link').forEach(a => {
    a.addEventListener('click', () => menu.classList.remove('open'));
  });
}

// ── NAV SCROLL ───────────────────────────────────────────────
function initNavScroll() {
  const nav = document.getElementById('nav');
  if (!nav) return;
  window.addEventListener('scroll', () => {
    nav.style.borderBottomColor = window.scrollY > 20 ? 'var(--border2)' : 'var(--border)';
  }, { passive: true });
}

// ── SHARED NAV HTML ──────────────────────────────────────────
function renderNav() {
  return `
  <nav class="nav" id="nav">
    <a class="nav-logo" href="/static/index.html">
      <span class="logo-bracket">[</span>
      <span class="logo-text">ASTANA<span class="logo-accent">PGL</span></span>
      <span class="logo-bracket">]</span>
      <span class="logo-year">2026</span>
    </a>
    <ul class="nav-links">
      <li><a href="/static/index.html" class="nav-link">ГЛАВНАЯ</a></li>
      <li><a href="/static/teams.html" class="nav-link">КОМАНДЫ</a></li>
      <li><a href="/static/matches.html" class="nav-link">МАТЧИ</a></li>
    </ul>
    <button class="nav-burger" id="burger" aria-label="Menu">
      <span></span><span></span><span></span>
    </button>
  </nav>
  <div class="mobile-menu" id="mobileMenu">
    <ul>
      <li><a href="/static/index.html" class="m-link">ГЛАВНАЯ</a></li>
      <li><a href="/static/teams.html" class="m-link">КОМАНДЫ</a></li>
      <li><a href="/static/matches.html" class="m-link">МАТЧИ</a></li>
    </ul>
  </div>`;
}

function renderFooter() {
  return `
  <footer>
    <div class="footer-logo">[ASTANA<span>PGL</span>] <span style="font-family:var(--font-mono);font-size:11px;color:var(--text3)">2026</span></div>
    <div>© 2026 Astana Pro Gaming League. All rights reserved.</div>
    <div style="display:flex;gap:16px;">
      <a href="/static/teams.html" style="color:var(--text3);transition:.2s" onmouseover="this.style.color='var(--accent)'" onmouseout="this.style.color='var(--text3)'">КОМАНДЫ</a>
      <a href="/static/matches.html" style="color:var(--text3);transition:.2s" onmouseover="this.style.color='var(--accent)'" onmouseout="this.style.color='var(--text3)'">МАТЧИ</a>
    </div>
  </footer>`;
}

// ── INIT ─────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  setNavActive();
  initBurger();
  initNavScroll();
});
