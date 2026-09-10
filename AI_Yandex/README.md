# AI_Yandex - AI Agent для Godot с интеграцией Яндекс Алисы

**Автор:** LaskinPO  
**Версия:** 1.0  
**Godot версия:** 4.6.3+

## 📦 Описание

Плагин для полного управления движком Godot через текстовые команды с интеграцией Яндекс Алисы.

### Возможности:
- ✅ Текстовое управление Godot (без голосового управления)
- ✅ Интеграция с Яндекс Алисой
- ✅ Удобный интерфейс в правой панели Godot
- ✅ Ввод логина и пароля для аутентификации
- ✅ Автономный режим работы
- ✅ Создание сцен, нод, скриптов по команде

## 🚀 Установка

### 1. Скопируйте плагин в проект
```bash
# Скопируйте папку addons в ваш проект Godot
cp -r /workspace/AI_Yandex/addons /path/to/your/godot/project/
```

### 2. Включите плагин в Godot
1. Откройте проект в Godot
2. Перейдите в `Project` → `Project Settings` → `Plugins`
3. Найдите "AI_Yandex" и включите его
4. Панель появится **справа** в редакторе

### 3. Запустите Python сервер
```bash
cd /workspace/AI_Yandex/python_server
pip install -r requirements.txt
python main.py
```

## 🎯 Использование

### В панели AI_Yandex (справа в Godot):

1. **Настройка сервера:**
   - Host: `http://localhost`
   - Port: `5000`

2. **Аутентификация Яндекс:**
   - Введите логин Яндекс
   - Введите пароль Яндекс
   - Нажмите кнопку "🔑 Get Token"

3. **Подключение:**
   - Нажмите "📡 Connect to Server"

4. **Автономная работа:**
   - Включите чекбокс "🔄 Autonomous Mode"

5. **Отправка команд:**
   - Введите команду в поле ввода
   - Нажмите "🚀 Send Command" или Enter

### Примеры команд:
- "Создай новую сцену"
- "Добавь игрока"
- "Запусти проект"
- "Сохранить сцену"
- "Создай скрипт"

## 📁 Структура проекта

```
AI_Yandex/
├── addons/AI_Yandex/           # Плагин для Godot
│   ├── plugin.cfg              # Конфигурация плагина
│   ├── ai_agent_plugin.gd      # Основной скрипт плагина
│   ├── http_server.gd          # HTTP клиент для связи
│   ├── dock_ui.tscn            # Сцена интерфейса
│   └── dock_ui.gd              # Скрипт интерфейса
├── python_server/              # Python сервер
│   ├── main.py                 # Flask сервер
│   └── requirements.txt        # Зависимости
└── README.md                   # Документация
```

## ⚙️ Настройка Яндекс Алисы

Для полноценной интеграции с Яндекс Алисой:

1. Зарегистрируйте навык в [Yandex Dialogs](https://dialogs.yandex.ru/)
2. Получите Client ID и Client Secret
3. Обновите `python_server/main.py`:
   ```python
   'client_id': 'YOUR_YANDEX_CLIENT_ID',
   'client_secret': 'YOUR_YANDEX_CLIENT_SECRET',
   ```

## 🔧 Требования

- Godot 4.6.3+
- Python 3.8+
- Flask
- Flask-CORS
- Requests

## 📝 Лицензия

MIT License

**Автор:** LaskinPO
