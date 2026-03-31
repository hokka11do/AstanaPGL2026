mountCommon('home');

const heroContainer = document.getElementById('hero-slides');
const topTeamsEl = document.getElementById('top-teams');
const recentMatchesEl = document.getElementById('recent-matches');

const FEATURED_CONFIG = [
  { slug: 'team-falcons', aliases: ['team falcons', 'falcons'], captain: 'kyxsan', verb: 'Command', accent: 'falcons' },
  { slug: 'parivision', aliases: ['parivision', 'pari vision'], captain: 'Jame', verb: 'Control', accent: 'parivision' },
  { slug: 'furia', aliases: ['furia'], captain: 'FalleN', verb: 'Legacy', accent: 'furia' },
  { slug: 'mouz', aliases: ['mouz', 'mousesports'], captain: 'Brollan', verb: 'Pressure', accent: 'mouz' },
  { slug: 'g2', aliases: ['g2', 'g2 esports'], captain: 'huNter-', verb: 'Chaos', accent: 'g2' }
];

async function initHome(){
  try{
    heroContainer.innerHTML = '<div class="loading container">Загружаю сцену турнира…</div>';
    const [teams, matches] = await Promise.all([
      fetchJson('/teams'),
      fetchJson('/matches')
    ]);

    const featuredTeams = resolveFeaturedTeams(teams);
    const captainData = await loadCaptains(featuredTeams);

    renderHero(featuredTeams, matches, captainData);
    renderTeams(featuredTeams);
    renderMatches(matches);
    initReveal();
  }catch(err){
    heroContainer.innerHTML = `<div class="container"><div class="error">Не получилось загрузить главную сцену: ${escapeHtml(err.message)}</div></div>`;
  }
}

function resolveFeaturedTeams(teams){
  const used = new Set();
  const selected = [];

  for (const cfg of FEATURED_CONFIG){
    const match = teams.find(team => {
      const name = String(team.name || '').toLowerCase();
      const slug = String(team.slug || '').toLowerCase();
      return !used.has(team.slug) && (slug === cfg.slug || cfg.aliases.some(alias => name.includes(alias) || slug.includes(alias.replaceAll(' ', '-'))));
    });
    if (match){
      used.add(match.slug);
      selected.push({...match, feature: cfg});
    }
  }

  return selected.length ? selected : teams.slice(0, 5).map((team, idx) => ({...team, feature: FEATURED_CONFIG[idx] || { captain: '', verb: 'Clutch', accent: 'default' }}));
}

async function loadCaptains(featuredTeams){
  const entries = await Promise.all(featuredTeams.map(async (team) => {
    try{
      const players = await fetchJson(`/teams/${team.slug}/players`);
      const captainNick = String(team.feature?.captain || '').toLowerCase();
      const captain = players.find(player => String(player.nickname || '').toLowerCase() === captainNick)
        || players.find(player => /igl|captain|in-game leader/i.test(String(player.role || '')))
        || players[0];
      return [team.slug, captain || null];
    }catch(_){
      return [team.slug, null];
    }
  }));
  return Object.fromEntries(entries);
}

function renderHero(teams, matches, captainData){
  const featured = teams.slice(0, 5);
  if(!featured.length){
    heroContainer.innerHTML = '<div class="container"><div class="empty">Пока нет команд для hero-слайдера.</div></div>';
    return;
  }

  heroContainer.innerHTML = featured.map((team, idx) => {
    const linkedMatch = matches.find(m => m.team1.name === team.name || m.team2.name === team.name);
    const captain = captainData[team.slug];
    const desc = linkedMatch
      ? `${team.name} уже в сетке. Следующий акцент — ${stageText(linkedMatch.stage)}, формат ${boText(linkedMatch.bo_type)}.`
      : `${team.name} заезжает на главную как один из главных хедлайнеров турнира: ритм, дисциплина и холодное давление большой сцены CS2.`;

    return `
      <article class="hero-slide hero-${escapeHtml(team.feature?.accent || 'default')} ${idx === 0 ? 'active' : ''}" data-slide="${idx}">
        <div class="hero-bg"></div>
        <div class="hero-noise"></div>
        <div class="hero-rings"></div>
        <div class="hero-content">
          <div>
            <span class="kicker">PGL Astana 2026 • CS2</span>
            <h1><span class="stroke">${escapeHtml(team.feature?.verb || 'Steel')}</span><br>${escapeHtml(team.short_name || team.name)}</h1>
            <p>${escapeHtml(desc)}</p>
            <div class="hero-actions">
              <a class="btn btn-primary" href="${routes.team(team.slug)}">Открыть профиль команды</a>
              <a class="btn" href="${routes.teams}">Все команды</a>
            </div>
          </div>
          <div class="hero-side">
            <div class="stat-card stat-card-lg">
              <strong>${escapeHtml(team.name)}</strong>
              <span>${escapeHtml(getRegion(team.region))} • ${escapeHtml(team.country_code || 'N/A')}</span>
            </div>
            <div class="hero-captain glass ${captain?.photo_url ? 'has-photo' : 'no-photo'}">
              <div class="hero-captain-copy">
                <span class="eyebrow">Капитан</span>
                <strong>${escapeHtml(captain?.nickname || team.feature?.captain || 'TBA')}</strong>
                <span>${escapeHtml(captain?.real_name || 'Игровой лидер состава')}</span>
                <span class="captain-role">${escapeHtml(captain?.role || 'In-game leader')}</span>
              </div>
              ${captain?.photo_url
                ? `<img class="hero-captain-photo" src="${escapeHtml(captain.photo_url)}" alt="${escapeHtml(captain.nickname || 'captain')}">`
                : `<div class="hero-captain-fallback">${escapeHtml((captain?.nickname || team.short_name || team.name).slice(0, 2).toUpperCase())}</div>`}
            </div>
            <div class="stat-grid">
              <div class="stat-card">
                <strong>${idx + 1}</strong>
                <span>Главный слот сцены</span>
              </div>
              <div class="stat-card">
                <strong>${linkedMatch ? boText(linkedMatch.bo_type) : 'CS2'}</strong>
                <span>${linkedMatch ? stageText(linkedMatch.stage) : 'Tournament mode'}</span>
              </div>
            </div>
          </div>
        </div>
        <img class="hero-logo" src="${escapeHtml(team.logo_url || '')}" alt="${escapeHtml(team.name)}">
      </article>
    `;
  }).join('');

  startHeroAnimation();
}

function startHeroAnimation(){
  if(!window.gsap) return;
  const slides = Array.from(document.querySelectorAll('.hero-slide'));
  if(!slides.length) return;
  gsap.killTweensOf('*');
  gsap.set(slides, {opacity:0, visibility:'hidden'});
  gsap.set(slides[0], {opacity:1, visibility:'visible'});
  let current = 0;

  const intro = (slide) => {
    const items = slide.querySelectorAll('h1, p, .kicker, .btn, .stat-card, .hero-captain-copy, .hero-captain-photo, .hero-captain-fallback');
    gsap.set(items, {opacity:1});
    gsap.fromTo(items, {y:26, opacity:0}, {y:0, opacity:1, duration:.85, stagger:.06, ease:'power3.out'});
    const logo = slide.querySelector('.hero-logo');
    if (logo) {
      gsap.fromTo(logo, {scale:.9, opacity:0, rotate:-8, filter:'drop-shadow(0 0 0 rgba(0,0,0,0))'}, {scale:1, opacity:1, rotate:0, duration:1.1, ease:'expo.out'});
    }
  };

  intro(slides[0]);
  setInterval(() => {
    const prev = slides[current];
    current = (current + 1) % slides.length;
    const next = slides[current];

    gsap.to(prev, {opacity:0, visibility:'hidden', duration:.55, ease:'power2.inOut'});
    gsap.set(next, {visibility:'visible'});
    gsap.fromTo(next, {opacity:0}, {opacity:1, duration:.75, ease:'power2.out'});
    intro(next);
  }, 4800);
}

function renderTeams(teams){
  topTeamsEl.innerHTML = teams.map(cardTeam).join('') || '<div class="empty">Команды не найдены.</div>';
}

function renderMatches(matches){
  const sorted = [...matches].sort((a,b) => new Date(a.start_time) - new Date(b.start_time));
  recentMatchesEl.innerHTML = sorted.slice(0, 6).map(cardMatch).join('') || '<div class="empty">Матчей пока нет.</div>';
}

initHome();
