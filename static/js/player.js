mountCommon('');

const teamSlug = qs('team');
const nickname =
  window.location.pathname.split('/').filter(Boolean).pop() || qs('nickname');

const titleNode = document.getElementById('player-title');
const subtitleNode = document.getElementById('player-subtitle');
const crumbNode = document.getElementById('player-crumb');
const bgWordNode = document.getElementById('player-bg-word');

const leftNode = document.getElementById('player-left');
const rightNode = document.getElementById('player-right');

const hudRoleNode = document.getElementById('hud-role');
const hudRegionNode = document.getElementById('hud-region');
const hudTeamNode = document.getElementById('hud-team');
const sideTeamNode = document.getElementById('player-side-team');
const heroTagsNode = document.getElementById('player-hero-tags');

function playerSubtitle(player) {
  const realName = player.real_name || 'Без real name';
  const teamName = player.team?.name || 'Unknown team';
  return `${realName} • ${teamName}`;
}

function playerDescriptionFallback(player) {
  return `${player.nickname} — игрок состава ${player.team?.name || 'команды'} на PGL Astana 2026. Профиль объединяет командную принадлежность, роль и быстрый доступ к внешним источникам.`;
}

async function initPlayer() {
  if (!teamSlug || !nickname) {
    titleNode.textContent = 'Игрок не выбран';
    subtitleNode.textContent = 'Нужен формат player.html?team=slug&nickname=player';
    if (leftNode) leftNode.innerHTML = `<div class="error">Не переданы team и nickname.</div>`;
    return;
  }

  try {
    const player = await fetchJson(
      `/teams/${encodeURIComponent(teamSlug)}/players/${encodeURIComponent(nickname)}`
    );

    const regionLabel = getRegion(player.team?.region || '');
    const safeSubtitle = playerSubtitle(player);
    const safeDescription = player.description || playerDescriptionFallback(player);
    const bgWord = (player.nickname || 'PLAYER').toUpperCase();

    if (titleNode) titleNode.textContent = player.nickname;
    if (subtitleNode) subtitleNode.textContent = safeSubtitle;
    if (crumbNode) crumbNode.textContent = player.nickname;
    if (bgWordNode) bgWordNode.textContent = bgWord;

    if (hudRoleNode) hudRoleNode.textContent = player.role || '—';
    if (hudRegionNode) hudRegionNode.textContent = regionLabel || '—';
    if (hudTeamNode) hudTeamNode.textContent = player.team?.name || '—';
    if (sideTeamNode) sideTeamNode.textContent = player.team?.short_name || player.team?.name || 'TEAM';

    if (heroTagsNode) {
      heroTagsNode.innerHTML = `
        <span class="badge">${escapeHtml(player.role || 'Role')}</span>
        <span class="badge">${escapeHtml(regionLabel || 'Region')}</span>
        <span class="badge">${escapeHtml(player.team?.short_name || player.team?.name || 'Team')}</span>
      `;
    }

    leftNode.innerHTML = `
      <section class="card panel-card player-overview reveal">
        <img
          class="player-photo"
          src="${escapeHtml(player.photo_url || '')}"
          alt="${escapeHtml(player.nickname)}"
        >

        <h2>${escapeHtml(player.nickname)}</h2>

        <div class="badges" style="margin-top:14px;">
          <span class="badge">${escapeHtml(player.country_code || '—')}</span>
          <span class="badge">${escapeHtml(player.role || '—')}</span>
          <span class="badge">${escapeHtml(player.team?.name || '—')}</span>
        </div>
      </section>
    `;

    rightNode.innerHTML = `
      <section class="card panel-card reveal">
        <div class="mini-kicker">Profile</div>
        <h3 style="font-size:1.7rem;margin-top:10px;">Игрок внутри системы</h3>

        <p class="desc">${escapeHtml(safeDescription)}</p>

        <div class="info-list">
          <div class="info-item">
            <span class="muted">Роль</span>
            <strong>${escapeHtml(player.role || '—')}</strong>
          </div>
          <div class="info-item">
            <span class="muted">Страна</span>
            <strong>${escapeHtml(player.country_code || '—')}</strong>
          </div>
          <div class="info-item">
            <span class="muted">Команда</span>
            <strong>${escapeHtml(player.team?.name || '—')}</strong>
          </div>
          <div class="info-item">
            <span class="muted">Регион</span>
            <strong>${escapeHtml(regionLabel || '—')}</strong>
          </div>
          <div class="info-item">
            <span class="muted">HLTV</span>
            <strong>${
              player.hltv_url
                ? `<a href="${escapeHtml(player.hltv_url)}" target="_blank" rel="noopener noreferrer">Открыть</a>`
                : '—'
            }</strong>
          </div>
        </div>

        <div class="badges" style="margin-top:18px;">
          <span class="badge">${escapeHtml(player.team?.short_name || player.team?.name || '—')}</span>
          <span class="badge">${escapeHtml(regionLabel || '—')}</span>
          <span class="badge">${escapeHtml(player.team?.country_code || '')}</span>
        </div>

        <div style="margin-top:22px;display:flex;gap:12px;flex-wrap:wrap;">
          <a class="btn btn-primary" href="${routes.team(teamSlug)}">К составу команды</a>
          <a class="btn" href="${routes.matches}">К матчам</a>
        </div>
      </section>
    `;

    initReveal();
  } catch (err) {
    if (leftNode) {
      leftNode.innerHTML = `<div class="error">Ошибка загрузки игрока: ${escapeHtml(err.message)}</div>`;
    }
    if (rightNode) {
      rightNode.innerHTML = '';
    }
  }
}

initPlayer();