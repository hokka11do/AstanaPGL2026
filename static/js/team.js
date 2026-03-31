mountCommon('');

const slug = qs('slug');

const titleEl = document.getElementById('team-title');
const crumbEl = document.getElementById('team-crumb');
const descEl = document.getElementById('team-desc');
const bgWordEl = document.getElementById('team-bg-word');

const overviewEl = document.getElementById('team-overview');
const rosterEl = document.getElementById('team-roster');
const metaListEl = document.getElementById('team-meta-list');

function teamDescriptionFallback(team) {
  const region = getRegion(team.region || '');
  return `${team.name} — участник PGL Astana 2026. Состав команды, регион ${region || 'международная сцена'}, турнирный профиль и ключевые игроки собраны на этой странице.`;
}

function buildFlag(url, alt) {
  if (!url) return '—';
  return `<img src="${escapeHtml(url)}" alt="${escapeHtml(alt || '')}" style="width:22px;height:22px;border-radius:999px;display:inline-block;vertical-align:middle">`;
}

async function initTeam() {
  if (!slug) {
    titleEl.textContent = 'Команда не выбрана';
    descEl.textContent = 'В ссылке нет slug. Нужен формат team.html?slug=team-spirit';
    if (overviewEl) {
      overviewEl.innerHTML = `<div class="error">Не передан slug команды.</div>`;
    }
    return;
  }

  try {
    const [team, players] = await Promise.all([
      fetchJson(`/teams/${encodeURIComponent(slug)}`),
      fetchJson(`/teams/${encodeURIComponent(slug)}/players`)
    ]);

    const regionLabel = getRegion(team.region || '');
    const safeDesc = team.description || teamDescriptionFallback(team);
    const bgWord = (team.short_name || team.name || 'TEAM').toUpperCase();

    titleEl.textContent = team.name;
    if (crumbEl) crumbEl.textContent = team.name;
    if (descEl) descEl.textContent = safeDesc;
    if (bgWordEl) bgWordEl.textContent = bgWord;

    overviewEl.innerHTML = `
      <section class="card panel-card team-overview team-overview-card reveal">
        <img
          class="team-logo-large"
          src="${escapeHtml(team.logo_url || '')}"
          alt="${escapeHtml(team.name)}"
        >
        <h2>${escapeHtml(team.name)}</h2>

        <div class="badges" style="margin-top:14px;">
          <span class="badge">${escapeHtml(team.short_name || team.name)}</span>
          <span class="badge">${escapeHtml(regionLabel || 'Region')}</span>
          <span class="badge">${escapeHtml(team.country_code || 'N/A')}</span>
        </div>

        <div class="info-list">
          <div class="info-item">
            <span class="muted">Регион</span>
            <strong>${escapeHtml(regionLabel || '—')}</strong>
          </div>
          <div class="info-item">
            <span class="muted">Код страны</span>
            <strong>${escapeHtml(team.country_code || 'N/A')}</strong>
          </div>
          <div class="info-item">
            <span class="muted">Флаг</span>
            <strong>${buildFlag(team.flag_url, team.country_code || '')}</strong>
          </div>
          <div class="info-item">
            <span class="muted">Статус</span>
            <strong>Active</strong>
          </div>
        </div>
      </section>
    `;

    if (metaListEl) {
      metaListEl.innerHTML = `
        <div class="info-item"><span>Регион</span><strong>${escapeHtml(regionLabel || '—')}</strong></div>
        <div class="info-item"><span>Тег</span><strong>${escapeHtml(team.short_name || team.name || '—')}</strong></div>
        <div class="info-item"><span>Страна</span><strong>${escapeHtml(team.country_code || '—')}</strong></div>
        <div class="info-item"><span>Ростер</span><strong>${Array.isArray(players) ? players.length : 0} игроков</strong></div>
      `;
    }

    rosterEl.innerHTML = (players || []).map(player => `
      <a href="${routes.player(team.slug, player.nickname)}" class="card player-card reveal">
        <div class="player-card-top">
          <img
            class="player-card-photo"
            src="${escapeHtml(player.photo_url || '')}"
            alt="${escapeHtml(player.nickname)}"
          >
          <div>
            <h3>${escapeHtml(player.nickname)}</h3>
            <div class="muted">${escapeHtml(player.real_name || 'Имя не указано')}</div>
          </div>
        </div>

        <div class="badges">
          <span class="badge">${escapeHtml(player.role || 'Role')}</span>
          <span class="badge">${escapeHtml(player.country_code || 'N/A')}</span>
          <span class="badge">${escapeHtml(getRegion(player.team?.region || '') || '')}</span>
        </div>
      </a>
    `).join('');

    if (!players || !players.length) {
      rosterEl.innerHTML = `<div class="empty">Активный состав пока не найден.</div>`;
    }

    initReveal();
  } catch (err) {
    if (overviewEl) {
      overviewEl.innerHTML = `<div class="error">Ошибка загрузки команды: ${escapeHtml(err.message)}</div>`;
    }
    if (rosterEl) {
      rosterEl.innerHTML = '';
    }
  }
}

initTeam();