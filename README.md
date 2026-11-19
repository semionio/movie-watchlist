# Movie Watchlist — микросервисная система

Учебный проект: REST API для ведения списка фильмов пользователя (watchlist).

## 1. Идея и минимальный пользовательский сценарий

Пользователь создаёт свой профиль, затем в каталоге фильмов выбирает фильм и добавляет его в личный вотчлист с одним из статусов:

- `planned` — планирует посмотреть;
- `watching` — смотрит;
- `watched` — посмотрел;
- `dropped` — решил не продолжать просмотр.

**Минимальный сценарий демонстрации:** создать пользователя → добавить фильм в каталог → добавить этот фильм в вотчлист пользователя → получить вотчлист. При добавлении Watchlist Service сам проверяет пользователя и фильм через два других сервиса.

## 2. Архитектура и сервисы

| Сервис | Порт хоста | Ответственность | Основные маршруты |
|---|---:|---|---|
| User Service | 8081 | Создание и получение пользователей | `GET /users`, `GET /users/{id}`, `POST /users` |
| Movie Service | 8082 | Каталог фильмов и поиск | `GET /movies`, `GET /movies/{id}`, `POST /movies` |
| Watchlist Service | 8083 | Добавление, получение и удаление записей вотчлиста | `POST /watchlists/{userId}/items`, `GET /watchlists/{userId}`, `DELETE /watchlists/{userId}/items/{movieId}` |
| PostgreSQL | 5432 | Хранение данных сервисов | PostgreSQL protocol |

У каждого микросервиса отдельная папка, API, проект .NET и Dockerfile. Для учебной работы используется один экземпляр PostgreSQL и одна база `watchlist`, но каждый сервис владеет своими таблицами: `users`, `movies`, `watchlist_items`.

### Взаимодействие сервисов

1. Клиент отправляет `POST /watchlists/{userId}/items` в Watchlist Service.
2. Watchlist Service запрашивает `GET /users/{userId}` у User Service.
3. Затем Watchlist Service запрашивает `GET /movies/{movieId}` у Movie Service.
4. Если обе проверки успешны, Watchlist Service сохраняет запись в `watchlist_items`.
5. При запросе `GET /watchlists/{userId}` сервис дополнительно проверяет пользователя через User Service и возвращает его список.

## 3. Технологии

- .NET 10 / ASP.NET Core Minimal API;
- Npgsql для доступа к PostgreSQL;
- Docker и Docker Compose;
- PostgreSQL 16;
- именованный Docker volume `db_data`;
- REST/HTTP между сервисами.

## 4. Требования перед запуском

Установите:

1. Docker Desktop для Windows/macOS или Docker Engine + Docker Compose для Linux.
2. Git — для отправки проекта в GitHub.
3. PowerShell 7 или Windows PowerShell (для готового демонстрационного сценария). Для ручных запросов также подойдут curl и Postman.

.NET SDK для запуска через Docker не обязателен: образы собираются внутри Docker. Для локальной сборки вне Docker понадобится .NET 10 SDK.

## 5. Запуск с нуля

Откройте терминал в корневой папке проекта, где лежит `docker-compose.yml`.

Соберите образы и запустите всю систему:

```bash
docker compose up --build -d
```

Посмотрите состояние контейнеров:

```bash
docker compose ps
```

Должны быть запущены четыре контейнера:

- `watchlist-db`;
- `watchlist-user-service`;
- `watchlist-movie-service`;
- `watchlist-watchlist-service`.

Проверьте API:

```bash
curl http://localhost:8081/health
curl http://localhost:8082/health
curl http://localhost:8083/health
```

Ожидается JSON со статусом `healthy` и подключённой базой данных.

Если сервис не стартовал, посмотрите логи:

```bash
docker compose logs user-service
docker compose logs movie-service
docker compose logs watchlist-service
docker compose logs db
```

## 6. Демонстрация минимального сценария

### Вариант A — одна команда в PowerShell

Из корневой папки проекта выполните:

```powershell
.\scripts\demo.ps1
```

Скрипт создаст нового тестового пользователя и фильм, добавит фильм в вотчлист и напечатает полученный список. Он использует уникальный email и название фильма, поэтому его можно запускать повторно.

### Вариант B — вручную через curl

Полные запросы и примеры ответов находятся в [`docs/api-examples.md`](docs/api-examples.md).

Порядок действий:

1. `POST http://localhost:8081/users` — создать пользователя.
2. `POST http://localhost:8082/movies` — создать фильм.
3. `POST http://localhost:8083/watchlists/{userId}/items` — добавить фильм в вотчлист.
4. `GET http://localhost:8083/watchlists/{userId}` — получить вотчлист.

Используйте значения `id`, которые вернулись в ответах первых двух запросов.

## 7. Проверка сохранения данных

1. Создайте пользователя и запись в вотчлисте.
2. Выполните `docker compose down`.
3. Запустите систему снова: `docker compose up -d`.
4. Повторите `GET http://localhost:8081/users` и `GET http://localhost:8083/watchlists/{userId}`.

Данные должны сохраниться, потому что PostgreSQL использует volume `db_data`.

**Важно:** `docker compose down -v` удаляет volume и данные. Не используйте `-v`, когда демонстрируете сохранение.

## 8. Архитектура C4

Редактируемая схема с тремя страницами (Context, Container, Component): [`docs/architecture.drawio`](docs/architecture.drawio).

Экспорт для просмотра: [`docs/architecture.png`](docs/architecture.png).

Файл можно открыть и редактировать на https://app.diagrams.net/.

## 9. Структура репозитория

```text
movie-watchlist/
├── src/
│   ├── UserService/
│   │   ├── Program.cs
│   │   ├── UserService.csproj
│   │   └── Dockerfile
│   ├── MovieService/
│   │   ├── Program.cs
│   │   ├── MovieService.csproj
│   │   └── Dockerfile
│   └── WatchlistService/
│       ├── Program.cs
│       ├── WatchlistService.csproj
│       └── Dockerfile
├── docs/
│   ├── architecture.drawio
│   ├── architecture.png
│   ├── api-examples.md
│   └── evidence/
│       └── README.md
├── scripts/
│   └── demo.ps1
├── docker-compose.yml
├── .gitignore
└── README.md
```

## 10. Остановка системы

```bash
docker compose down
```

Данные в `db_data` останутся. Чтобы полностью удалить контейнеры и данные учебной БД:

```bash
docker compose down -v
```

## 11. Ограничения учебной версии

- Нет регистрации с паролем и авторизации — User Service хранит базовые профили.
- Все сервисы используют одну PostgreSQL базу, но управляют отдельными таблицами.
- Нет внешнего API с постерами и рейтингами; каталог заполняется через API.
- Пароль базы в Compose задан для локальной демонстрации. Для реального развёртывания его следует вынести в секреты/переменные окружения.

## 12. Что приложить к сдаче

- GitHub-ссылка на репозиторий;
- исходники и Dockerfile всех трёх сервисов;
- `docker-compose.yml`;
- `README.md`;
- редактируемая C4-схема и PNG-экспорт;
- `docs/api-examples.md`;
- собственные скриншоты или текстовый вывод запуска и API в `docs/evidence/`.

Инструкция по сбору подтверждений находится в [`docs/evidence/README.md`](docs/evidence/README.md).
