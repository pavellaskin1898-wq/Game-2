# Быстрый старт

## 1. Установка зависимостей

```bash
cd python_server
pip install -r requirements.txt
```

## 2. Запуск сервера

```bash
python main.py
```

Сервер запустится на `http://localhost:5000`

## 3. Проверка работы

Откройте другой терминал и проверьте статус:

```bash
curl http://localhost:5000/api/status
```

Или протестируйте AI процессор:

```bash
python test_ai.py
```

## 4. Тестирование команд

Отправьте команду через curl:

```bash
curl -X POST http://localhost:5000/api/command \
  -H "Content-Type: application/json" \
  -d '{"command": "create_scene", "parameters": {"type": "Node3D", "name": "TestScene"}}'
```

## 5. Настройка Яндекс Алисы

Следуйте инструкции в [docs/alice_setup.md](docs/alice_setup.md)

## 6. Установка плагина в Godot

1. Скопируйте папку `godot_plugin` в ваш проект Godot
2. Включите плагин в Project Settings → Plugins
3. Настройте подключение к серверу

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
- `POST /api/alice/webhook` - Webhook для Яндекс Алисы
- `POST /api/command` - Выполнение команды
- `GET /api/commands/list` - Список доступных команд
