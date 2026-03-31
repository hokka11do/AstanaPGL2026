mountCommon('teams');

const teamsRoot = document.getElementById('teams-root');
const searchInput = document.getElementById('team-search');
const regionSelect = document.getElementById('team-region');

let allTeams = [];

async function initTeams(){
  try{
    teamsRoot.innerHTML = '<div class="loading">Загружаю команды…</div>';
    allTeams = await fetchJson('/teams');
    renderTeamsList(allTeams);
    bindFilters();
    initReveal();
  }catch(err){
    teamsRoot.innerHTML = `<div class="error">Не удалось загрузить команды: ${escapeHtml(err.message)}</div>`;
  }
}

function bindFilters(){
  const apply = () => {
    const q = (searchInput.value || '').trim().toLowerCase();
    const region = regionSelect.value;
    const filtered = allTeams.filter(team => {
      const hitQuery = !q || [team.name, team.short_name, team.country_code, team.region].join(' ').toLowerCase().includes(q);
      const hitRegion = !region || String(team.region).toLowerCase() === region.toLowerCase();
      return hitQuery && hitRegion;
    });
    renderTeamsList(filtered);
    initReveal();
  };
  searchInput.addEventListener('input', apply);
  regionSelect.addEventListener('change', apply);
}

function renderTeamsList(items){
  if (!items.length){
    teamsRoot.innerHTML = '<div class="empty">Ничего не найдено. Попробуй другой фильтр.</div>';
    return;
  }
  teamsRoot.innerHTML = items.map(cardTeam).join('');
}

initTeams();
