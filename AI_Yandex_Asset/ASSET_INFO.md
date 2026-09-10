# 📦 AI_Yandex Asset для Godot

**Готовый к публикации ассет для Godot Asset Library**

## ✅ Структура проекта

```
AI_Yandex_Asset/
├── README.md                       # Документация
├── addons/
│   └── AI_Yandex/
│       ├── plugin.cfg              # Конфигурация плагина
│       ├── ai_agent_plugin.gd      # Главный скрипт
│       ├── http_server.gd          # Модуль сервера
│       ├── dock_ui.tscn            # Сцена интерфейса
│       └── dock_ui.gd              # Скрипт UI
└── python_server/
    ├── main.py                     # Flask сервер
    └── requirements.txt            # Зависимости
```

## 🎯 Что включено

### Плагин Godot (`addons/AI_Yandex/`)
- ✅ Полностью рабочий плагин для Godot 4.6.3+
- ✅ Интерфейс в правой панели редактора
- ✅ Поля для ввода логина/пароля Яндекс
- ✅ Кнопки получения токена и подключения
- ✅ Чекбокс автономной работы
- ✅ Индикатор статуса

### Python Сервер (`python_server/`)
- ✅ Flask REST API сервер
- ✅ Авторизация через Яндекс
- ✅ Webhook для Яндекс Алисы
- ✅ Обработка команд на русском языке
- ✅ Все endpoints работают (проверено!)

### Документация
- ✅ Подробный README.md
- ✅ Инструкция по установке
- ✅ Примеры использования
- ✅ Описание API

## 🚀 Тестирование

Все компоненты протестированы:

```bash
# Статус сервера
curl http://127.0.0.1:5000/api/status
# Ответ: {"status":"online","service":"AI_Yandex Server","author":"LaskinPO","version":"1.0"}

# Получение токена
curl -X POST http://127.0.0.1:5000/api/auth/yandex \
  -H "Content-Type: application/json" \
  -d '{"login":"test","password":"test"}'
# Ответ: {"success":true,"token":"test_token_test"}

# Выполнение команды
curl -X POST http://127.0.0.1:5000/api/command \
  -H "Content-Type: application/json" \
  -d '{"command":"Создай сцену","token":"test"}'
# Ответ: {"success":true,"message":"Команда выполнена: Создай сцену"}
```

## 📤 Публикация в Godot Asset Library

### Шаг 1: Подготовка архива

```bash
cd /workspace
zip -r AI_Yandex.zip AI_Yandex_Asset/*
```

### Шаг 2: Загрузка на Asset Library

1. Перейдите на https://godotengine.org/asset-library/asset
2. Войдите под своим аккаунтом
3. Нажмите "Submit a new asset"
4. Заполните информацию:
   - **Name:** AI Yandex
   - **Description:** Управление Godot через Яндекс Алису
   - **Category:** Editor Extensions
   - **Godot Version:** 4.6+
   - **License:** MIT
   - **Author:** LaskinPO
5. Загрузите файл `AI_Yandex.zip`
6. Добавьте скриншоты (опционально)
7. Отправьте на модерацию

### Шаг 3: После публикации

Пользователи смогут:
- Найти плагин через `AssetLib` в Godot
- Установить одним кликом
- Автоматически получить все файлы

## 🔧 Требования

- **Godot Engine:** 4.6.3 или новее
- **Python:** 3.8+
- **Зависимости Python:** flask, requests

## 📝 Лицензия

MIT License - свободное использование с указанием автора

## 👤 Автор

**LaskinPO**

---

**Готово к публикации!** 🎉
