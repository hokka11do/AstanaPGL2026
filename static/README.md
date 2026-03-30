# PGL Astana 2026 — Frontend

Cyberpunk-style multi-page frontend for the PGL Astana 2026 CS2 Major tracker.

## File Structure

```
pgl_frontend/
├── index.html      ← Home page (hero + recent matches)
├── teams.html      ← All teams grid with region filter
├── team.html       ← Single team detail + roster  (?slug=...)
├── matches.html    ← Match schedule (status + stage filters)
├── match.html      ← Single match detail + map cards  (?id=...)
├── map.html        ← Map player stats table  (?matchId=...&mapId=...)
├── css/
│   └── styles.css  ← All shared styles
└── js/
    └── app.js      ← Shared utilities, helpers, particles, cursor
```

## Setup

1. Place the `pgl_frontend/` folder inside your project's `static/` directory:
   ```
   static/
   └── pgl_frontend/
       ├── index.html
       └── ...
   ```

2. Make sure your FastAPI backend is running on `http://localhost:8000`

3. Open `http://localhost:8000/static/pgl_frontend/index.html` in your browser

   Or if you're serving static files via FastAPI:
   ```python
   from fastapi.staticfiles import StaticFiles
   app.mount("/static", StaticFiles(directory="static"), name="static")
   ```

## API Endpoints Used

| Endpoint | Used On |
|---|---|
| `GET /teams` | teams.html, index.html |
| `GET /teams/{slug}` | team.html |
| `GET /teams/{slug}/players` | team.html |
| `GET /matches` | matches.html, index.html |
| `GET /matches/{id}` | match.html |
| `GET /matches/{id}/maps/{mapId}` | map.html |

## Changing API URL

Edit the first line of `js/app.js`:
```js
const API = 'http://localhost:8000';
```
