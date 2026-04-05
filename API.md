# API Documentation

## Authentication

Все endpoint'ы (кроме `/login`) требуют аутентификации. Поддерживаются два способа:

1. **Session Auth** (через web-интерфейс)
2. **Basic Auth** (для скриптов/API)

```bash
curl -u admin:YOUR_PASSWORD http://localhost:8080/api/add ...
```

Подробнее в [BASIC_AUTH.md](BASIC_AUTH.md)

---

## Endpoints

### `/api/retrieve` - Получить содержимое файла

**Method:** `POST`

**Parameters:**
- `fileName` (required) - имя файла (proxy-domain, direct-domain, proxy-ip, direct-ip)

**Response:**
```
Content содержимого файла в виде plain text
```

**Example:**
```bash
curl -u admin:PASSWORD \
  -X POST \
  -F "fileName=proxy-domain" \
  http://localhost:8080/api/retrieve
```

---

### `/api/save` - Сохранить содержимое файла

**Method:** `POST`

**Parameters:**
- `fileName` (required) - имя файла
- `content` (required) - содержимое файла

**Response:**
```json
{
  "desc": "Saved successfully",
  "level": "success",
  "new_logs": [...]
}
```

**Example:**
```bash
curl -u admin:PASSWORD \
  -X POST \
  -F "fileName=proxy-domain" \
  -F "content=example.com" \
  http://localhost:8080/api/save
```

---

### `/api/add` - Добавить строку в файл

**Method:** `POST`

**Parameters:**
- `fileName` (required) - имя файла
- `line` (required) - строка для добавления

**Behavior:**
- Добавляет строку в конец файла с новой строкой
- Если строка уже существует → возвращает успех (дублей не будет)
- Если файл не существует → создает новый файл

**Response:**
```json
{
  "desc": "Line added successfully",
  "level": "success"
}
```

**Status Codes:**
- `200 OK` - успешно добавлена или уже существует
- `400 Bad Request` - отсутствуют параметры
- `401 Unauthorized` - неверная аутентификация

**Example:**
```bash
# Добавить домен
curl -u admin:PASSWORD \
  -X POST \
  -F "fileName=proxy-domain" \
  -F "line=youtube.com" \
  http://localhost:8080/api/add

# Добавить IP
curl -u admin:PASSWORD \
  -X POST \
  -F "fileName=proxy-ip" \
  -F "line=8.8.8.8" \
  http://localhost:8080/api/add
```

---

### `/api/remove` - Удалить строку из файла

**Method:** `POST`

**Parameters:**
- `fileName` (required) - имя файла
- `line` (required) - строка для удаления

**Behavior:**
- Удаляет строку из файла
- Игнорирует пробелы при сравнении
- Если строка не найдена → возвращает 404

**Response:**
```json
{
  "desc": "Line removed successfully",
  "level": "success"
}
```

**Status Codes:**
- `200 OK` - успешно удалена
- `400 Bad Request` - отсутствуют параметры
- `401 Unauthorized` - неверная аутентификация
- `404 Not Found` - строка не найдена в файле

**Example:**
```bash
# Удалить домен
curl -u admin:PASSWORD \
  -X POST \
  -F "fileName=proxy-domain" \
  -F "line=youtube.com" \
  http://localhost:8080/api/remove

# Удалить IP
curl -u admin:PASSWORD \
  -X POST \
  -F "fileName=proxy-ip" \
  -F "line=8.8.8.8" \
  http://localhost:8080/api/remove
```

---

### `/api/update-antifilter` - Запустить обновление Antifilter

**Method:** `POST`

**Response:**
```json
{
  "desc": "Antifilter update started",
  "level": "success"
}
```

---

### `/api/status` - Получить статус и логи

**Method:** `GET`

**Response:**
```json
{
  "last_update": "2026-04-05T22:30:00Z",
  "logs": [...],
  "dark_theme": false
}
```

---

### `/api/theme` - Переключить тему

**Method:** `POST`

**Response:**
```json
{
  "dark_theme": true
}
```

---

## Examples

### Python

```python
import requests

auth = ('admin', 'YOUR_PASSWORD')

# Добавить домен
response = requests.post(
    'http://localhost:8080/api/add',
    data={'fileName': 'proxy-domain', 'line': 'example.com'},
    auth=auth
)
print(response.json())

# Удалить домен
response = requests.post(
    'http://localhost:8080/api/remove',
    data={'fileName': 'proxy-domain', 'line': 'example.com'},
    auth=auth
)
print(response.json())
```

### Bash Script

```bash
#!/bin/bash

PASSWORD="YOUR_PASSWORD"
HOST="http://localhost:8080"

# Добавить несколько доменов
for domain in youtube.com google.com github.com; do
    curl -u "admin:$PASSWORD" \
      -X POST \
      -F "fileName=proxy-domain" \
      -F "line=$domain" \
      "$HOST/api/add"
done

# Получить содержимое
curl -u "admin:$PASSWORD" \
  -X POST \
  -F "fileName=proxy-domain" \
  "$HOST/api/retrieve"
```

---

## Error Handling

### 401 Unauthorized
```json
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Basic realm="SSAntifilter API"

Unauthorized
```

### 404 Not Found (для /remove)
```
HTTP/1.1 404 Not Found

Line not found
```

### 400 Bad Request
```json
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "desc": "fileName and line are required",
  "level": "fatal"
}
```

---

## Supported Files

Для endpoint'ов работают следующие файлы:
- `proxy-domain` - домены для прокси
- `direct-domain` - домены для прямого доступа
- `proxy-ip` - IP адреса для прокси (поддерживает CIDR)
- `direct-ip` - IP адреса для прямого доступа (поддерживает CIDR)
