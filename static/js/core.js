const API_BASE = '/api';

const routes = {
  home: '/',
  teams: '/teams',
  matches: '/matches',
  team: (slug) => `/teams/${encodeURIComponent(slug)}`,
  player: (teamSlug, nickname) => `/players/${encodeURIComponent(nickname)}?team=${encodeURIComponent(teamSlug)}`,
  match: (id) => `/matches/${encodeURIComponent(id)}`,
  map: (matchId, mapId) => `/matches/${encodeURIComponent(matchId)}/maps/${encodeURIComponent(mapId)}`
};

async function fetchJson(path){
  const res = await fetch(`${API_BASE}${path}`);
  if(!res.ok){
    let message = `Ошибка ${res.status}`;
    try {
      const data = await res.json();
      if (data.detail) message = data.detail;
    } catch (_) {}
    throw new Error(message);
  }
  return res.json();
}

function qs(name){
  return new URLSearchParams(window.location.search).get(name);
}

function escapeHtml(str = ''){
  return String(str)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}

function formatDate(value){
  if (!value) return 'Время уточняется';
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return value;
  return new Intl.DateTimeFormat('ru-RU', {
    day: '2-digit', month: 'long', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  }).format(d);
}

function statusText(status){
  const map = {
    upcoming: 'Скоро',
    live: 'Live',
    finished: 'Завершен',
    postponed: 'Перенесен',
    canceled: 'Отменен'
  };
  return map[status] || status || 'Неизвестно';
}

function stageText(stage){
  const map = {
    group_stage: 'Групповая стадия',
    playoffs: 'Плей-офф',
    quarterfinal: 'Четвертьфинал',
    semifinal: 'Полуфинал',
    grand_final: 'Гранд-финал',
    final: 'Финал',
    swiss_stage: 'Swiss stage',
    lower_bracket: 'Lower bracket',
    upper_bracket: 'Upper bracket'
  };
  return map[stage] || String(stage || '').replaceAll('_', ' ');
}

function boText(bo){
  const norm = String(bo || '').toUpperCase();
  return norm || 'BO?';
}

function renderNav(active = ''){
  const nav = document.getElementById('site-nav');
  if (!nav) return;
  nav.innerHTML = `
    <div class="inner">
      <a class="brand" href="${routes.home}">
        <span class="brand-mark"></span>
        <span class="brand-text">
          <small>PGL ASTANA 2026</small>
          <strong>CS2 FRONTLINE</strong>
        </span>
      </a>
      <div class="nav-links">
        <a class="${active==='home'?'active':''}" href="${routes.home}">Главная</a>
        <a class="${active==='teams'?'active':''}" href="${routes.teams}">Команды</a>
        <a class="${active==='matches'?'active':''}" href="${routes.matches}">Матчи</a>
      </div>
      <button class="burger" id="burger-btn" aria-label="Открыть меню">
        <span></span><span></span><span></span>
      </button>
    </div>
  `;
  const mobile = document.getElementById('mobile-menu');
  if (mobile) {
    mobile.innerHTML = `
      <a class="${active==='home'?'active':''}" href="${routes.home}">Главная</a>
      <a class="${active==='teams'?'active':''}" href="${routes.teams}">Команды</a>
      <a class="${active==='matches'?'active':''}" href="${routes.matches}">Матчи</a>
    `;
  }
  const burger = document.getElementById('burger-btn');
  burger?.addEventListener('click', () => mobile?.classList.toggle('open'));
}

function renderFooter(){
  const footer = document.getElementById('site-footer');
  if(!footer) return;
  footer.innerHTML = `
    <div class="container">
      <div class="panel footer-panel">
        <div>
          <strong>PGL Astana 2026</strong>
          <span>Championship hub</span>
        </div>
        <div>
          <span>Teams • Players • Matches • Map stats</span>
        </div>
      </div>
    </div>
  `;
}

function initReveal(){
  const items = document.querySelectorAll('.reveal');
  if (!items.length || !window.gsap) return;
  gsap.to(items, {
    opacity: 1,
    y: 0,
    duration: .9,
    ease: 'power3.out',
    stagger: .08,
    scrollTrigger: items.length > 2 ? {
      trigger: items[0].parentElement,
      start: 'top 78%'
    } : undefined
  });
}

function mountCommon(active){
  renderNav(active);
  renderFooter();
}

function getRegion(region){
  const mapping = {
    cis: 'CIS',
    europe: 'Европа',
    north_america: 'Северная Америка',
    south_america: 'Южная Америка',
    asia: 'Азия',
    oceania: 'Океания'
  };
  return mapping[String(region || '').toLowerCase()] || region || 'Регион не указан';
}

function cardTeam(team){
  return `
    <a href="${routes.team(team.slug)}" class="card team-card reveal">
      <div class="team-card-top">
        <img class="team-logo" src="${escapeHtml(team.logo_url || '')}" alt="${escapeHtml(team.name)}">
        <span class="flag-pill">
          ${team.country_code ? `<img src="/static/flags/${team.country_code.toLowerCase()}.svg" alt="${team.country_code}">` : ''}
          ${escapeHtml(team.short_name || team.country_code || 'TEAM')}
        </span>
      </div>
      <div>
        <h3>${escapeHtml(team.name)}</h3>
        <p>${escapeHtml(getRegion(team.region))}</p>
      </div>
      <div class="card-meta">
        <span class="tag">${escapeHtml(team.country_code || 'N/A')}</span>
        <span class="tag">Состав и профиль</span>
      </div>
    </a>
  `;
}

function cardMatch(match){
  return `
    <a href="${routes.match(match.id)}" class="card match-card reveal">
      <div class="match-head">
        <div>
          <div class="match-stage">${escapeHtml(stageText(match.stage))}</div>
          <div class="muted">${escapeHtml(boText(match.bo_type))} • ${escapeHtml(formatDate(match.start_time))}</div>
        </div>
        <span class="match-status">${escapeHtml(statusText(match.status))}</span>
      </div>
      <div class="versus">
        <div class="side">
          <img src="${escapeHtml(match.team1.logo_url || '')}" alt="${escapeHtml(match.team1.name)}">
          <div>
            <strong>${escapeHtml(match.team1.name)}</strong>
          </div>
        </div>
        <div class="vs">vs</div>
        <div class="side right">
          <div>
            <strong>${escapeHtml(match.team2.name)}</strong>
          </div>
          <img src="${escapeHtml(match.team2.logo_url || '')}" alt="${escapeHtml(match.team2.name)}">
        </div>
      </div>
      <div class="score">
        <span>${match.score_team1 ?? 0}</span>
        <span class="muted">:</span>
        <span>${match.score_team2 ?? 0}</span>
      </div>
    </a>
  `;
}

if (window.gsap && window.ScrollTrigger) {
  gsap.registerPlugin(ScrollTrigger);
}