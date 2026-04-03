# PGL Astana 2026 Website

Полноценный backend + frontend проект для отображения турнира PGL Astana 2026 по CS2.

## 🚀 Возможности

* Просмотр всех команд
* Детальная страница команды
* Составы игроков
* Список матчей
* Детали матча и карты
* Статистика игроков

## 🛠 Стек

* Python 3.12+
* FastAPI
* SQLAlchemy (async)
* Alembic (миграции)
* PostgreSQL (Docker)
* HTML / CSS / JS (vanilla)

---

## ⚙️ Запуск проекта

### 1. Клонировать репозиторий

```bash
git clone https://github.com/hokka11do/AstanaPGL2026.git
cd AstanaPGL2026
```

---

### 2. Создать env-файлы

#### `.env`

```env
DB_USER=postgres
DB_PASSWORD=your_password
DB_HOST=localhost
DB_PORT=5433
DB_NAME=PGLAstana
```

#### `.env.app.docker`

```env
DB_USER=postgres
DB_PASSWORD=your_password
DB_HOST=db
DB_PORT=5432
DB_NAME=PGLAstana
```

#### `.env.docker`

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_password
POSTGRES_DB=PGLAstana
```

---

### 3. Запуск Docker

```bash
docker compose up -d --build
```

---

### 4. Применить миграции

```bash
alembic upgrade head
```

---

### 5. Открыть приложение

```text
http://localhost:8000
```

---

## 📂 Структура проекта

```
src/
 ├── api/
 ├── database/
 ├── models/
 ├── services/

static/
 ├── js/
 ├── css/

alembic/
 ├── versions/
```

---

## 🧠 Особенности

* Разделение env для Docker и локальной разработки
* Async работа с БД
* Использование Alembic для управления схемой
* Чистая архитектура API

---

## 📌 TODO

* Добавить пагинацию
* Кэширование
* Авторизацию
* Улучшить UI/UX

---

## 👤 Автор

Deni Bisultanov
