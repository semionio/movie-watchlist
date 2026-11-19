# Примеры запросов API

Все примеры рассчитаны на локальный запуск Docker Compose.

## 1. Проверка сервисов

```bash
curl http://localhost:8081/health
curl http://localhost:8082/health
curl http://localhost:8083/health
```

## 2. Создать пользователя

```bash
curl -X POST http://localhost:8081/users \
  -H "Content-Type: application/json" \
  -d '{"name":"Alex","email":"alex@example.com"}'
```

Пример ответа (id будет назначен базой данных):

```json
{
  "id": 1,
  "name": "Alex",
  "email": "alex@example.com"
}
```

Запомните `id` из ответа — он понадобится в следующих запросах.

## 3. Добавить фильм в каталог

```bash
curl -X POST http://localhost:8082/movies \
  -H "Content-Type: application/json" \
  -d '{"title":"The Matrix","year":1999,"genre":"Science Fiction"}'
```

Пример ответа:

```json
{
  "id": 1,
  "title": "The Matrix",
  "year": 1999,
  "genre": "Science Fiction"
}
```

Запомните `id` фильма.

## 4. Добавить фильм в вотчлист

Подставьте реальные `userId` и `movieId`, которые вернули два предыдущих запроса.

```bash
curl -X POST http://localhost:8083/watchlists/1/items \
  -H "Content-Type: application/json" \
  -d '{"movieId":1,"status":"planned","notes":"Посмотреть на выходных"}'
```

Этот запрос демонстрирует взаимодействие микросервисов: Watchlist Service обращается к User Service и Movie Service, проверяет существование объектов и затем сохраняет запись.

Допустимые статусы: `planned`, `watching`, `watched`, `dropped`.

## 5. Получить вотчлист пользователя

```bash
curl http://localhost:8083/watchlists/1
```

## 6. Поиск фильмов в каталоге

```bash
curl "http://localhost:8082/movies?search=matrix"
```

## 7. Удалить фильм из вотчлиста

```bash
curl -X DELETE http://localhost:8083/watchlists/1/items/1
```

## PowerShell

В Windows PowerShell удобнее использовать `Invoke-RestMethod`. Готовый полный сценарий находится в `scripts/demo.ps1`:

```powershell
.\scripts\demo.ps1
```
