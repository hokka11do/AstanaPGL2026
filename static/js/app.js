/* ═══════════════════════════════════════════════
   PGL ASTANA 2026 — Shared Utilities (app.js)
   ═══════════════════════════════════════════════ */

const API = 'http://localhost:8000';

/* ── Fetch helper ── */
async function apiFetch(path) {
  const r = await fetch(API + path);
  if (!r.ok) throw new Error('HTTP ' + r.status);
  return r.json();
}

/* ── Status helpers ── */
function statusClass(s) {
  if (!s) return 'sp-soon';
  const v = s.toLowerCase();
  if (v.includes('live') || v === 'ongoing') return 'sp-live';
  if (v.includes('fin') || v.includes('comp') || v === 'done') return 'sp-done';
  return 'sp-soon';
}

function isLive(s) { return statusClass(s) === 'sp-live'; }

/* ── Date formatter ── */
function fmtDate(iso) {
  if (!iso) return '—';
  try {
    return new Date(iso).toLocaleString('en-GB', {
      day: '2-digit', month: 'short',
      hour: '2-digit', minute: '2-digit'
    });
  } catch { return iso; }
}

/* ── Logo / photo helper ── */
function logoEl(url, name, cssClass, phClass) {
  const initial = (name || '?')[0].toUpperCase();
  if (url) return `<img src="${url}" class="${cssClass}" alt="${name}" onerror="this.style.opacity=0">`;
  return `<div class="${phClass}">${initial}</div>`;
}

/* ── Loader HTML ── */
function loaderHTML(text = 'Loading') {
  return `<div class="loader">
    <div class="loader-ring"></div>
    <div class="loader-text">${text}</div>
  </div>`;
}

/* ── Error HTML ── */
function errHTML(msg) {
  return `<div class="err-box">${msg}</div>`;
}

/* ── Cursor ── */
function initCursor() {
  const cur   = document.getElementById('cursor');
  const trail = document.getElementById('cursor-trail');
  if (!cur || !trail) return;
  let mx = 0, my = 0, tx = 0, ty = 0;
  document.addEventListener('mousemove', e => {
    mx = e.clientX; my = e.clientY;
    cur.style.left = mx + 'px';
    cur.style.top  = my + 'px';
  });
  setInterval(() => {
    tx += (mx - tx) * 0.12;
    ty += (my - ty) * 0.12;
    trail.style.left = tx + 'px';
    trail.style.top  = ty + 'px';
  }, 16);
  document.querySelectorAll('button,a,.team-card,.match-row,.map-card,.player-card').forEach(el => {
    el.addEventListener('mouseenter', () => { cur.style.width = '20px'; cur.style.height = '20px'; });
    el.addEventListener('mouseleave', () => { cur.style.width = '12px'; cur.style.height = '12px'; });
  });
}

/* ── Particles ── */
function initParticles() {
  const canvas = document.getElementById('particles');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  let W, H, pts = [];
  function resize() { W = canvas.width = window.innerWidth; H = canvas.height = window.innerHeight; }
  resize();
  window.addEventListener('resize', resize);
  for (let i = 0; i < 60; i++) pts.push({
    x: Math.random() * 1400, y: Math.random() * 900,
    vx: (Math.random() - .5) * .3, vy: (Math.random() - .5) * .3,
    r: Math.random() * 1.5 + .5, a: Math.random(),
    c: Math.random() > .5 ? '0,255,231' : '255,45,120'
  });
  function draw() {
    ctx.clearRect(0, 0, W, H);
    pts.forEach(p => {
      p.x += p.vx; p.y += p.vy; p.a += .005;
      if (p.x < 0) p.x = W; if (p.x > W) p.x = 0;
      if (p.y < 0) p.y = H; if (p.y > H) p.y = 0;
      const alpha = (.3 + .3 * Math.sin(p.a));
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(${p.c},${alpha})`;
      ctx.fill();
    });
    requestAnimationFrame(draw);
  }
  draw();
}

/* ── Nav date ── */
function initNavDate() {
  const el = document.getElementById('nav-date');
  if (el) el.textContent = new Date().toLocaleDateString('en-GB', {
    day: '2-digit', month: 'short', year: 'numeric'
  }).toUpperCase();
}

/* ── Highlight active nav link ── */
function highlightNav() {
  const page = location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.nav-btn').forEach(btn => {
    btn.classList.toggle('active', btn.getAttribute('href') === page || btn.getAttribute('href') === './' && (page === '' || page === 'index.html'));
  });
}

/* ── Shared init ── */
function sharedInit() {
  initCursor();
  initParticles();
  initNavDate();
  highlightNav();
}

/* ── Match row HTML ── */
function matchRowHTML(m, href) {
  const sc   = statusClass(m.status);
  const live = isLive(m.status);
  return `
    <a class="match-row${live ? ' is-live' : ''}" href="${href}">
      <div class="mr-team">
        ${logoEl(m.team1?.logo_url, m.team1?.name, 'mr-logo', 'mr-logo-ph')}
        <div class="mr-tname">${m.team1?.name || 'TBD'}</div>
      </div>
      <div class="mr-score-wrap">
        <div class="mr-score">${m.score_team1 ?? '—'}&nbsp;:&nbsp;${m.score_team2 ?? '—'}</div>
        <div class="mr-meta">
          <span class="mr-stage">${m.bo_type || ''}</span>
          <span class="status-pill ${sc}">${live ? '● LIVE' : m.status || ''}</span>
        </div>
      </div>
      <div class="mr-team r">
        ${logoEl(m.team2?.logo_url, m.team2?.name, 'mr-logo', 'mr-logo-ph')}
        <div class="mr-tname">${m.team2?.name || 'TBD'}</div>
      </div>
      <div style="text-align:right">
        <div class="mr-time">${fmtDate(m.start_time)}</div>
        <div class="mr-sub">${m.stage || ''}</div>
      </div>
    </a>`;
}
