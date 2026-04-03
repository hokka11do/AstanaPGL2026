mountCommon('matches');

const parts = window.location.pathname.split('/').filter(Boolean);
const matchId = parts[1] || qs('match_id');
const mapId = parts[3] || qs('map_id');
const titleNode = document.getElementById('map-title');
const subtitleNode = document.getElementById('map-subtitle');
const summaryNode = document.getElementById('map-summary');
const tablesNode = document.getElementById('map-tables');

function renderTable(team){
  const rows = (team.players_stats || []).sort((a,b) => (b.rating ?? 0) - (a.rating ?? 0)).map(player => `
    <tr>
      <td>
        <div class="player-stat-cell">
          <img src="${escapeHtml(player.photo_url || '')}" alt="${escapeHtml(player.nickname)}">
          <div>
            <strong>${escapeHtml(player.nickname)}</strong>
            <div class="muted">${escapeHtml(player.real_name || '')}</div>
          </div>
        </div>
      </td>
      <td>${player.kills ?? 0}</td>
      <td>${player.deaths ?? 0}</td>
      <td>${player.assists ?? 0}</td>
      <td>${player.adr ?? 0}</td>
      <td>${player.kast ?? 0}</td>
      <td class="highlight">${player.rating ?? 0}</td>
      <td>${player.hs_percentage ?? 0}</td>
    </tr>
  `).join('');

  return `
    <section class="card panel-card reveal">
      <div style="display:flex;align-items:center;gap:14px;margin-bottom:18px;">
        <img src="${escapeHtml(team.logo_url || '')}" alt="${escapeHtml(team.name)}" style="width:64px;height:64px;object-fit:contain;padding:10px;background:rgba(255,255,255,.04);border-radius:18px;border:1px solid rgba(255,255,255,.07)">
        <div>
          <h2 style="font-size:1.6rem;">${escapeHtml(team.name)}</h2>
          <div class="muted">${escapeHtml(team.short_name || '')} • ${escapeHtml(getRegion(team.region))}</div>
        </div>
      </div>
      <div class="table-wrap">
        <table>
          <thead>
            <tr>
              <th>Игрок</th>
              <th>K</th>
              <th>D</th>
              <th>A</th>
              <th>ADR</th>
              <th>KAST</th>
              <th>Rtg</th>
              <th>HS%</th>
            </tr>
          </thead>
          <tbody>${rows}</tbody>
        </table>
      </div>
    </section>
  `;
}

async function initMap(){
  if(!matchId || !mapId){
    titleNode.textContent = 'Карта не выбрана';
    subtitleNode.textContent = 'Нужен формат map.html?match_id=1&map_id=2';
    return;
  }

  try{
    const data = await fetchJson(`/matches/${encodeURIComponent(matchId)}/maps/${encodeURIComponent(mapId)}`);
    titleNode.textContent = `Map ${data.map_order ?? '?'} • ${data.map_name}`;
    subtitleNode.textContent = `${data.team1.name} vs ${data.team2.name}`;

    summaryNode.innerHTML = `
      <section class="card panel-card reveal">
        <div class="summary-score">
          <div class="side">
            <img src="${escapeHtml(data.team1.logo_url || '')}" alt="${escapeHtml(data.team1.name)}">
            <div><strong>${escapeHtml(data.team1.name)}</strong></div>
          </div>
          <div class="number">${data.score_team1 ?? 0}<span class="muted"> : </span>${data.score_team2 ?? 0}</div>
          <div class="side right">
            <div><strong>${escapeHtml(data.team2.name)}</strong></div>
            <img src="${escapeHtml(data.team2.logo_url || '')}" alt="${escapeHtml(data.team2.name)}">
          </div>
        </div>
        <div class="info-list" style="margin-top:22px;">
          <div class="info-item"><span class="muted">Пик карты</span><strong>${escapeHtml(data.picked_by_team?.name || 'Decider')}</strong></div>
          <div class="info-item"><span class="muted">Победитель</span><strong>${escapeHtml(data.winner?.name || '—')}</strong></div>
          <div class="info-item"><span class="muted">Серия</span><strong><a href="${routes.match(data.match_id)}">Вернуться к матчу</a></strong></div>
        </div>
      </section>
    `;

    tablesNode.innerHTML = `${renderTable(data.team1)}${renderTable(data.team2)}`;
    initReveal();
  }catch(err){
    summaryNode.innerHTML = `<div class="error">Ошибка загрузки карты: ${escapeHtml(err.message)}</div>`;
    tablesNode.innerHTML = '';
  }
}

initMap();
