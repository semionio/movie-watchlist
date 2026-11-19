# Материалы для подтверждения работы

Перед сдачей проекта добавьте сюда собственные скриншоты или текстовый вывод команд. Не используйте вымышленные результаты: преподаватель должен видеть фактический запуск на вашем компьютере.

Рекомендуемый комплект:

1. `docker compose up --build -d` — успешная сборка и запуск.
2. `docker compose ps` — видны четыре контейнера: три сервиса и PostgreSQL.
3. `powershell-demo.txt` — вывод `scripts/demo.ps1`.
4. `docker-compose-ps.txt` — вывод `docker compose ps`.
5. `persistence-check.txt` — результат проверки сохранения данных после перезапуска.

Сохранить вывод команд в PowerShell можно так:

```powershell
docker compose ps | Out-File -Encoding utf8 docs/evidence/docker-compose-ps.txt
.\scripts\demo.ps1 2>&1 | Tee-Object -FilePath docs/evidence/powershell-demo.txt
```

Для проверки сохранения данных:

```powershell
# Получите список пользователей и запомните id одного пользователя
Invoke-RestMethod http://localhost:8081/users | ConvertTo-Json -Depth 5

# Перезапустите контейнеры, НЕ удаляя volume
docker compose down
docker compose up -d

# Через несколько секунд запросите список снова
Invoke-RestMethod http://localhost:8081/users | ConvertTo-Json -Depth 5
```

Данные должны остаться. Команда `docker compose down -v` удалит volume `db_data` и все данные, поэтому для проверки сохранности её не используйте.
