Куда класть:
- распакуй архив
- все эти файлы положи внутрь папки static

Структура:
static/
  index.html
  teams.html
  team.html
  player.html
  matches.html
  match.html
  map.html
  css/styles.css
  js/app.js

Важно:
1) Фронт ожидает, что сайт открыт на том же домене, где работает FastAPI.
2) API маршруты используются такие:
   /teams
   /teams/{team_slug}
   /teams/{team_slug}/players
   /teams/{team_slug}/players/{nickname}
   /matches
   /matches/{match_id}
   /matches/{match_id}/maps/{map_id}

3) Флаги берутся из:
   /static/flags/{country_code}.svg

4) Если открываешь просто file://... локально, fetch к API работать не будет.
   Открывай через запущенный FastAPI, например:
   http://127.0.0.1:8000/static/index.html

Что улучшено:
- отдельные html для каждой страницы
- более BLAST-подобный dark/glass/neon стиль
- больше анимаций
- больше меток, флагов и инфо
- карты на странице матча сортируются по map_order
