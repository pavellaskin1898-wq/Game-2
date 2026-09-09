# AI_Yandex - AI Agent для Godot с интеграцией Яндекс Алисы

**Автор:** LaskinPO  
**Версия:** 1.0  
**Godot Version:** 4.6.3+

## Описание

Плагин для полного управления движком Godot через текстовые команды с интеграцией Яндекс Алисы.  
Удобный интерфейс в правой панели редактора позволяет ввести логин и пароль от Яндекс для автономной работы.

## Структура проекта

```
AI_Yandex/
├── addons/
│   └── AI_Yandex/
│       ├── plugin.cfg          # Конфигурация плагина
│       ├── ai_agent_plugin.gd  # Основной скрипт плагина
│       ├── http_server.gd      # HTTP сервер для связи
│       ├── dock_ui.tscn        # Сцена интерфейса
│       └── dock_ui.gd          # Скрипт интерфейса
├── python_server/
│   ├── main.py                 # Python Flask сервер
│   └── requirements.txt        # Зависимости Python
└── README.md                   # Этот файл
```

## Установка

### 1. Установка плагина в Godot

1. Скопируйте папку `addons/AI_Yandex` в ваш проект Godot
2. Откройте проект в Godot 4.6.3+
3. Перейдите в `Project Settings → Plugins`
4. Включите плагин **AI_Yandex**

### 2. Запуск Python сервера

```bash
cd AI_Yandex/python_server
pip install -r requirements.txt
python main.py
```

Сервер запустится на `http://127.0.0.1:8080`

## Использование

### Интерфейс (правая панель Godot)

1. **Yandex Login** - введите ваш логин от Яндекс
2. **Yandex Password** - введите ваш пароль от Яндекс
3. **🔑 Get Token** - получить OAuth токен
4. **📡 Connect to Server** - подключиться к Python серверу
5. **🔄 Autonomous Mode** - включить автономную работу

### Примеры команд

- "Создай новую сцену"
- "Добавь игрока"
- "Запусти проект"
- "Сохранить сцену"
- "Создай скрипт"

## API Endpoints

- `POST /api/auth/yandex` - Аутентификация Яндекс
- `GET /api/status` - Статус сервера
- `POST /api/alice/webhook` - Webhook для Алисы
- `POST /api/command` - Выполнение команд

## Лицензия

MIT License  
Author: LaskinPO
