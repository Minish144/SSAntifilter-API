# Basic Auth Support

Endpoints `/api/retrieve` и `/api/save` теперь поддерживают HTTP Basic Authentication в дополнение к session-based auth.

## Использование

### Получение содержимого файла с Basic Auth

```bash
# Синтаксис: curl -u [username]:[password] ...
# Username может быть любым (игнорируется), пароль ОБЯЗАТЕЛЕН
# Пароль = тот же, что выводится при первом запуске приложения

curl -u admin:YOUR_PASSWORD \
  -X POST \
  -F "fileName=proxy-domain" \
  http://localhost:8080/api/retrieve
```

**Где найти пароль?**
- При первом запуске контейнера ищите в логах строку: `Your login password: ...`
- Или в переменной окружения `SESSION_SECRET_KEY` (если явно задана)
- Username при Basic Auth может быть любым (даже пустым)

### Сохранение файла с Basic Auth

```bash
curl -u admin:YOUR_PASSWORD \
  -X POST \
  -F "fileName=proxy-domain" \
  -F "content=example.com" \
  http://localhost:8080/api/save
```

## Примеры

### Python
```python
import requests

# Username может быть любым (или пустой строкой '')
# Password = пароль из логов при первом запуске
auth = ('admin', 'YOUR_PASSWORD')

response = requests.post(
    'http://localhost:8080/api/retrieve',
    files={'fileName': 'proxy-domain'},
    auth=auth
)
print(response.text)
```

### JavaScript/Fetch API
```javascript
const password = 'YOUR_PASSWORD';  // password = из логов
const credentials = btoa(`admin:${password}`);  // base64

fetch('http://localhost:8080/api/retrieve', {
  method: 'POST',
  headers: {
    'Authorization': `Basic ${credentials}`
  },
  body: new FormData(/* ... */)
});
```

### curl с переменной пароля
```bash
# Сохраняем пароль из логов в переменную
PASSWORD="abc123xyz456"

curl -u "admin:$PASSWORD" \
  -X POST \
  -F "fileName=proxy-domain" \
  http://localhost:8080/api/retrieve
```

### Даже простые варианты работают (username не важен)
```bash
curl -u :YOUR_PASSWORD \
  -X POST \
  -F "fileName=proxy-domain" \
  http://localhost:8080/api/retrieve
```

## Безопасность

- ⚠️ **Один пароль на всё**: Basic Auth использует тот же пароль, что и web-интерфейс
- ⚠️ Всегда используйте **HTTPS** в production (`USE_HTTPS=1`)
- ⚠️ Basic Auth отправляет credentials в base64 в каждом запросе (не зашифровано, только кодировка)
- ⚠️ Base64 легко декодировать, поэтому без HTTPS это небезопасно
- 🔐 Пароль хранится хешированным (bcrypt) в `config.json`
- 🔐 Видеть оригинальный пароль можно только в логах при первом запуске

## Обратная совместимость

- Session-based auth (через web-интерфейс) продолжает работать
- Оба метода аутентификации поддерживаются одновременно
- Приоритет: сначала проверяется сессия, если её нет - проверяется Basic Auth

## Статус кода ответа

- `200 OK` - успешная аутентификация
- `401 Unauthorized` - неправильный пароль или отсутствуют credentials
  - Response включает `WWW-Authenticate: Basic realm="SSAntifilter API"` header
- `405 Method Not Allowed` - неправильный HTTP метод (используйте POST)

## Получение пароля (если забыли)

Пароль хранится хешированным в `config.json`, восстановить оригинальный текст невозможно.

**Решение:** удалить `config.json` и перезапустить приложение:

```bash
# Если запущено в контейнере:
docker exec ssantifilter rm -f config.json
docker restart ssantifilter

# Затем посмотрите логи для нового пароля:
docker logs ssantifilter | grep "Your login password"
```

Будет сгенерирован новый пароль.
