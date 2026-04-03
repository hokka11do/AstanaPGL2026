mountCommon('matches');

const id =
  window.location.pathname.split('/').filter(Boolean).pop() || qs('id');
const titleNode = document.getElementById('match-title');
const subtitleNode = document.getElementById('match-subtitle');
const summaryNode = document.getElementById('match-summary');
const detailsNode = document.getElementById('match-details');
const mapsNode = document.getElementById('maps-root');

async function initMatch(){
  if(!id){
    titleNode.textContent = 'Матч не выбран';
    subtitleNode.textContent = 'Нужен формат match.html?id=1';
    return;
  }

  try{
    const match = await fetchJson(`/matches/${encodeURIComponent(id)}`);
    titleNode.textContent = `${match.team1.name} vs ${match.team2.name}`;
    subtitleNode.textContent = `${stageText(match.stage)} • ${boText(match.bo_type)} • ${statusText(match.status)}`;

    summaryNode.innerHTML = `
      <section class="card panel-card reveal">
        <div class="summary-score">
          <div class="side">
            <img src="${escapeHtml(match.team1.logo_url || '')}" alt="${escapeHtml(match.team1.name)}">
            <div>
              <div class="muted">${escapeHtml(match.team1.short_name || '')}</div>
              <strong>${escapeHtml(match.team1.name)}</strong>
            </div>
          </div>
          <div class="number">${match.score_team1 ?? 0}<span class="muted"> : </span>${match.score_team2 ?? 0}</div>
          <div class="side right">
            <div>
              <div class="muted">${escapeHtml(match.team2.short_name || '')}</div>
              <strong>${escapeHtml(match.team2.name)}</strong>
            </div>
            <img src="${escapeHtml(match.team2.logo_url || '')}" alt="${escapeHtml(match.team2.name)}">
          </div>
        </div>
      </section>
    `;

    detailsNode.innerHTML = `
      <section class="card panel-card reveal">
        <h2 style="font-size:1.6rem;">Детали серии</h2>
        <div class="info-list">
          <div class="info-item"><span class="muted">Время</span><strong>${escapeHtml(formatDate(match.start_time))}</strong></div>
          <div class="info-item"><span class="muted">Стадия</span><strong>${escapeHtml(stageText(match.stage))}</strong></div>
          <div class="info-item"><span class="muted">Формат</span><strong>${escapeHtml(boText(match.bo_type))}</strong></div>
          <div class="info-item"><span class="muted">Статус</span><strong>${escapeHtml(statusText(match.status))}</strong></div>
          <div class="info-item"><span class="muted">Победитель</span><strong>${escapeHtml(match.winner?.name || 'Пока нет')}</strong></div>
        </div>
      </section>
    `;

    const maps = [...(match.maps || [])].sort((a,b) => (a.map_order ?? 999) - (b.map_order ?? 999));
    mapsNode.innerHTML = maps.length ? maps.map(map => `
      <a href="${routes.map(match.id, map.id)}" class="card map-card reveal">
        <div class="order">M${map.map_order ?? '?'}</div>
        <div>
          <h3>${escapeHtml(map.map_name || 'Map')}</h3>
          <div class="muted">${escapeHtml(map.team1.name)} ${map.score_team1 ?? 0} : ${map.score_team2 ?? 0} ${escapeHtml(map.team2.name)}</div>
          <div class="muted">Пик: ${escapeHtml(map.picked_by?.name || 'Decider')} • Победитель: ${escapeHtml(map.winner?.name || '—')}</div>
        </div>
        <span class="btn">Открыть карту</span>
      </a>
    `).join('') : '<div class="empty">Карты для этого матча пока не добавлены.</div>';

    initReveal();
  }catch(err){
    summaryNode.innerHTML = `<div class="error">Ошибка загрузки матча: ${escapeHtml(err.message)}</div>`;
    detailsNode.innerHTML = '';
    mapsNode.innerHTML = '';
  }
}

initMatch();
