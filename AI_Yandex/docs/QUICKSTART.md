# Быстрый старт - AI_Yandex

**Автор:** LaskinPO

## 1. Установка зависимостей

```bash
cd AI_Yandex/python_server
pip install -r requirements.txt
```

## 2. Настройка Яндекс OAuth

1. Перейдите на https://oauth.yandex.ru/client/new
2. Создайте новое приложение
3. Получите `Client ID` и `Client Secret`
4. Откройте `main.py` и замените:
   ```python
   CLIENT_ID = 'ваш_client_id'
   CLIENT_SECRET = 'ваш_client_secret'
   ```

## 3. Запуск сервера

```bash
python main.py
```

Сервер запустится на `http://localhost:5000`

## 4. Проверка работы

Откройте другой терминал и проверьте статус:

```bash
curl http://localhost:5000/api/status
```

Или протестируйте AI процессор:

```bash
python test_ai.py
```

## 5. Тестирование команд

Отправьте команду через curl:

```bash
curl -X POST http://localhost:5000/api/command \
  -H "Content-Type: application/json" \
  -d '{"command": "create_scene", "parameters": {"type": "Node3D", "name": "TestScene"}}'
```

## 6. Установка плагина в Godot

1. Скопируйте папку `godot_plugin` в ваш проект Godot (в папку `addons/`)
2. Откройте Godot → Проект → Настройки → Плагины
3. Найдите "AI_Yandex" и включите его
4. Панель управления появится справа в редакторе

## 7. Настройка плагина в Godot

В панели AI_Yandex (справа):

1. Введите **логин Яндекс**
2. Введите **пароль Яндекс**
3. Нажмите **"🔑 Получить токен"**
4. Нажмите **"📡 Подключиться"**
5. Включите **"🔄 Автономная работа"**

## Примеры команд для тестирования

```bash
# Создать сцену
curl -X POST http://localhost:5000/api/command \
  -H "Content-Type: application/json" \
  -d '{"command": "create_scene"}'

# Добавить ноду
curl -X POST http://localhost:5000/api/command \
  -H "Content-Type: application/json" \
  -d '{"command": "add_node", "parameters": {"type": "Sprite2D", "name": "Player"}}'

# Запустить проект
curl -X POST http://localhost:5000/api/command \
  -H "Content-Type: application/json" \
  -d '{"command": "run_project"}'

# Сохранить сцену
curl -X POST http://localhost:5000/api/command \
  -H "Content-Type: application/json" \
  -d '{"command": "save_scene"}'
```

## Список API эндпоинтов

- `GET /api/status` - Проверка статуса сервера
- `POST /api/auth/yandex` - Получение OAuth токена Яндекс
- `POST /api/alice/webhook` - Webhook для Яндекс Алисы
- `POST /api/command` - Выполнение команды
- `GET /api/commands/list` - Список доступных команд

## Настройка навыка Алисы

1. Перейдите в [Яндекс Диалоги](https://dialogs.yandex.ru/)
2. Создайте новый навык
3. Укажите Webhook URL:
   - Для локальной разработки: используйте ngrok (`ngrok http 5000`)
   - Для продакшена: ваш публичный URL + `/api/alice/webhook`
4. Опубликуйте навык

Теперь вы можете говорить команды Алисе, и они будут выполняться в Godot!
