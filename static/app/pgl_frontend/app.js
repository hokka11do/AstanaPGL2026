const API = {
  teams: "/teams",
  team: (slug) => `/teams/${slug}`,
  player: (nickname) => `/players/${encodeURIComponent(nickname)}`,
};

const state = {
  teams: [],
  selectedTeam: null,
};

const els = {
  heroTeamCount: document.getElementById("heroTeamCount"),
  teamsView: document.getElementById("teamsView"),
  teamView: document.getElementById("teamView"),
  teamsGrid: document.getElementById("teamsGrid"),
  backBtn: document.getElementById("backBtn"),
  homeBtn: document.getElementById("homeBtn"),
  teamName: document.getElementById("teamName"),
  teamSlug: document.getElementById("teamSlug"),
  teamLogo: document.getElementById("teamLogo"),
  teamFlag: document.getElementById("teamFlag"),
  teamRegion: document.getElementById("teamRegion"),
  teamDescription: document.getElementById("teamDescription"),
  teamBackdropLogo: document.getElementById("teamBackdropLogo"),
  playersGrid: document.getElementById("playersGrid"),
  playerModal: document.getElementById("playerModal"),
  modalLoading: document.getElementById("modalLoading"),
  modalContent: document.getElementById("modalContent"),
  modalError: document.getElementById("modalError"),
  closeModalBtn: document.getElementById("closeModalBtn"),
  modalPlayerPhoto: document.getElementById("modalPlayerPhoto"),
  modalPlayerNickname: document.getElementById("modalPlayerNickname"),
  modalPlayerName: document.getElementById("modalPlayerName"),
  modalPlayerFlag: document.getElementById("modalPlayerFlag"),
  modalPlayerRole: document.getElementById("modalPlayerRole"),
  modalPlayerCountry: document.getElementById("modalPlayerCountry"),
  modalPlayerTeam: document.getElementById("modalPlayerTeam"),
};

const roleMap = {
  entry: "Entry",
  rifler: "Rifler",
  support: "Support",
  sniper: "Sniper",
  igl: "IGL",
};

const darkLogoTeams = new Set([
  "team-spirit",
  "g2-esports",
  "fut-esports",
  "gentle-mates",
]);

async function fetchJSON(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

function getFlagUrl(code) {
  return `/static/flags/${String(code).toLowerCase()}.svg`;
}

function getPlayerPhoto(slug, nickname) {
  return `/static/photos/${slug}/${nickname}.png`;
}

function titleRole(role) {
  if (!role) return "Unknown";
  const normalized = String(role).toLowerCase();
  return roleMap[normalized] ?? normalized.charAt(0).toUpperCase() + normalized.slice(1);
}

function getTeamLogoClass(slug) {
  return darkLogoTeams.has(slug)
    ? "team-card-logo team-card-logo--dark"
    : "team-card-logo";
}

function showHome() {
  state.selectedTeam = null;
  els.teamView.classList.add("hidden");
  els.teamsView.classList.remove("hidden");
  window.location.hash = "#teams";
}

function renderTeams() {
  if (!state.teams.length) {
    els.teamsGrid.innerHTML = `<div class="empty-box">Пока пусто. Проверь, что backend отдаёт <code>/teams</code>.</div>`;
    return;
  }

  els.heroTeamCount.textContent = state.teams.length;
  els.teamsGrid.innerHTML = state.teams.map((team) => `
    <article class="team-card" data-team-slug="${team.slug}">
      <div class="team-card-header">
        <div class="team-card-logo-wrap">
          <img class="${getTeamLogoClass(team.slug)}" src="${team.logo_url}" alt="${team.name}" />
        </div>
        <img class="team-card-flag team-card-flag--large" src="${getFlagUrl(team.country_code)}" alt="${team.country_code}" />
      </div>
      <div>
        <h3>${team.name}</h3>
        <p>${team.short_name ?? team.slug}</p>
      </div>
      <div class="team-card-foot">
        <span class="team-card-tag">${team.region}</span>
        <span>→</span>
      </div>
    </article>
  `).join("");

  els.teamsGrid.querySelectorAll("[data-team-slug]").forEach((card) => {
    card.addEventListener("click", () => openTeam(card.dataset.teamSlug));
  });
}

async function openTeam(slug) {
  try {
    els.teamsView.classList.add("hidden");
    els.teamView.classList.remove("hidden");
    els.playersGrid.innerHTML = `<div class="loading">Собираю страницу команды...</div>`;

    const team = await fetchJSON(API.team(slug));
    state.selectedTeam = team;
    window.location.hash = `#team/${slug}`;

    els.teamName.textContent = team.name;
    els.teamSlug.textContent = `/${team.slug}`;
    els.teamLogo.src = team.logo_url;
    els.teamLogo.alt = team.name;
    els.teamBackdropLogo.src = team.logo_url;
    els.teamBackdropLogo.alt = `${team.name} backdrop`;
    els.teamFlag.src = getFlagUrl(team.country_code);
    els.teamFlag.alt = team.country_code;
    els.teamRegion.textContent = team.region;
    els.teamDescription.textContent = team.description || "Описание пока не добавлено.";

    if (darkLogoTeams.has(team.slug)) {
      els.teamLogo.classList.add("team-page-logo--dark");
      els.teamBackdropLogo.classList.add("team-page-backdrop-logo--dark");
    } else {
      els.teamLogo.classList.remove("team-page-logo--dark");
      els.teamBackdropLogo.classList.remove("team-page-backdrop-logo--dark");
    }

    const roster = window.ROSTERS?.[slug] ?? [];
    if (!roster.length) {
      els.playersGrid.innerHTML = `<div class="empty-box">Для ${team.name} пока не найден состав. Если хочешь убрать этот костыль, добавь endpoint <code>/teams/{slug}/players</code>.</div>`;
      return;
    }

    els.playersGrid.innerHTML = roster.map((nickname) => `
      <article class="player-card" data-player-nickname="${nickname}">
        <img class="player-card-photo" src="${getPlayerPhoto(slug, nickname)}" alt="${nickname}" loading="lazy" />
        <div class="player-card-top">
          <div>
            <h4>${nickname}</h4>
            <small>${team.name}</small>
          </div>
          <img class="player-card-flag player-card-flag--large" src="${getFlagUrl(team.country_code)}" alt="${team.country_code}" />
        </div>
        <div class="player-card-footer">
          <span class="player-card-role">Нажми для деталей</span>
          <span class="player-card-action">Open</span>
        </div>
      </article>
    `).join("");

    els.playersGrid.querySelectorAll("[data-player-nickname]").forEach((card) => {
      card.addEventListener("click", () => openPlayer(card.dataset.playerNickname));
    });
  } catch (error) {
    els.playersGrid.innerHTML = `<div class="error-box">Не удалось открыть страницу команды. Проверь backend и пути к static.</div>`;
    console.error(error);
  }
}

async function openPlayer(nickname) {
  els.playerModal.classList.remove("hidden");
  els.playerModal.setAttribute("aria-hidden", "false");
  els.modalLoading.classList.remove("hidden");
  els.modalContent.classList.add("hidden");
  els.modalError.classList.add("hidden");

  try {
    const player = await fetchJSON(API.player(nickname));

    els.modalPlayerPhoto.src = player.photo_url;
    els.modalPlayerPhoto.alt = player.nickname;
    els.modalPlayerNickname.textContent = player.nickname;
    els.modalPlayerName.textContent = player.real_name;
    els.modalPlayerFlag.src = player.flag_url || getFlagUrl(player.country_code);
    els.modalPlayerFlag.alt = player.country_code;
    els.modalPlayerRole.textContent = titleRole(player.role);
    els.modalPlayerCountry.textContent = player.country_code;
    els.modalPlayerTeam.textContent = `${player.team.name} · ${player.team.region}`;

    els.modalLoading.classList.add("hidden");
    els.modalContent.classList.remove("hidden");
  } catch (error) {
    console.error(error);
    els.modalLoading.classList.add("hidden");
    els.modalError.classList.remove("hidden");
  }
}

function closeModal() {
  els.playerModal.classList.add("hidden");
  els.playerModal.setAttribute("aria-hidden", "true");
}

async function loadTeams() {
  els.teamsGrid.innerHTML = `<div class="loading">Поднимаю команды с backend...</div>`;
  try {
    state.teams = await fetchJSON(API.teams);
    renderTeams();
    handleHash();
  } catch (error) {
    console.error(error);
    els.teamsGrid.innerHTML = `<div class="error-box">Не получилось загрузить команды. Проверь, что сервер запущен и endpoint <code>/teams</code> отвечает.</div>`;
  }
}

function handleHash() {
  const hash = window.location.hash;
  if (!hash || hash === "#" || hash === "#teams") {
    showHome();
    return;
  }

  const match = hash.match(/^#team\/(.+)$/);
  if (match) {
    openTeam(match[1]);
  }
}

els.homeBtn.addEventListener("click", showHome);
els.backBtn.addEventListener("click", showHome);
els.closeModalBtn.addEventListener("click", closeModal);
els.playerModal.addEventListener("click", (event) => {
  if (event.target.dataset.closeModal === "true") closeModal();
});
window.addEventListener("keydown", (event) => {
  if (event.key === "Escape") closeModal();
});
window.addEventListener("hashchange", handleHash);

loadTeams();