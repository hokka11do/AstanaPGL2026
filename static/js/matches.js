mountCommon('matches');

const root = document.getElementById('matches-root');
const searchInput = document.getElementById('match-search');
const statusSelect = document.getElementById('match-status');

let allMatches = [];

async function initMatches(){
  try{
    root.innerHTML = '<div class="loading">Загружаю матчи…</div>';
    allMatches = await fetchJson('/matches');
    renderMatches(allMatches);
    bindFilters();
    initReveal();
  }catch(err){
    root.innerHTML = `<div class="error">Не удалось загрузить матчи: ${escapeHtml(err.message)}</div>`;
  }
}

function bindFilters(){
  const apply = () => {
    const q = (searchInput.value || '').toLowerCase().trim();
    const status = statusSelect.value;
    const filtered = allMatches.filter(match => {
      const text = [match.team1.name, match.team2.name, match.stage, match.bo_type].join(' ').toLowerCase();
      const qOk = !q || text.includes(q);
      const sOk = !status || match.status === status;
      return qOk && sOk;
    });
    renderMatches(filtered);
    initReveal();
  };
  searchInput.addEventListener('input', apply);
  statusSelect.addEventListener('change', apply);
}

function renderMatches(items){
  if(!items.length){
    root.innerHTML = '<div class="empty">Матчи не найдены.</div>';
    return;
  }
  const sorted = [...items].sort((a,b) => new Date(a.start_time) - new Date(b.start_time));
  root.innerHTML = sorted.map(cardMatch).join('');
}

initMatches();
