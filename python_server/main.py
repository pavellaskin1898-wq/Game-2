from flask import Flask, request, jsonify
import requests
import threading

app = Flask(__name__)

# Хранилище токенов (в памяти)
yandex_tokens = {}

@app.route('/api/status', methods=['GET'])
def get_status():
    """Проверка статуса сервера"""
    return jsonify({
        "status": "online",
        "service": "AI_Yandex Server",
        "author": "LaskinPO",
        "version": "1.0"
    })

@app.route('/api/auth/yandex', methods=['POST'])
def auth_yandex():
    """Получение OAuth токена Яндекс по логину и паролю"""
    data = request.json
    login = data.get('login')
    password = data.get('password')
    
    if not login or not password:
        return jsonify({"error": "Login and password required"}), 400
    
    # Используем Яндекс OAuth для получения токена
    # Примечание: В реальном проекте нужно использовать OAuth flow с redirect
    # Это упрощенная версия для демонстрации
    try:
        # Запрос на получение токена через Яндекс API
        oauth_url = "https://oauth.yandex.ru/token"
        payload = {
            "grant_type": "password",
            "client_id": "your_client_id",  # Нужно зарегистрировать приложение в Яндексе
            "client_secret": "your_client_secret",
            "username": login,
            "password": password
        }
        
        # Для демонстрации возвращаем mock токен
        # В реальности нужно настроить OAuth приложение в Яндексе
        token = f"mock_token_{login}"
        yandex_tokens[login] = token
        
        return jsonify({
            "token": token,
            "login": login
        })
        
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/api/command', methods=['POST'])
def execute_command():
    """Выполнение команды от пользователя"""
    data = request.json
    command = data.get('command', '')
    language = data.get('language', 'ru')
    auth_header = request.headers.get('Authorization', '')
    
    if not command:
        return jsonify({"error": "Command is required"}), 400
    
    # Извлекаем токен из заголовка
    token = auth_header.replace('Bearer ', '') if auth_header else ''
    
    # Обработка команд на русском языке
    result = process_command(command, language, token)
    
    return jsonify({
        "result": result,
        "command": command
    })

@app.route('/api/alice/webhook', methods=['POST'])
def alice_webhook():
    """Webhook для Яндекс Алисы"""
    data = request.json
    
    # Получаем текст от Алисы
    user_request = data.get('request', {}).get('original_utterance', '')
    
    # Обрабатываем запрос
    response_text = process_alice_request(user_request)
    
    return jsonify({
        "response": {
            "text": response_text,
            "tts": response_text,
            "end_session": False
        },
        "version": "1.0"
    })

def process_command(command: str, language: str, token: str) -> str:
    """Обработка команд управления Godot"""
    command_lower = command.lower()
    
    # Примеры команд на русском
    if "создай сцену" in command_lower or "новая сцена" in command_lower:
        return "Сцена создана успешно"
    
    elif "добавь ноду" in command_lower or "создай ноду" in command_lower:
        return "Нода добавлена"
    
    elif "запусти проект" in command_lower or "старт" in command_lower:
        return "Проект запущен"
    
    elif "останови" in command_lower or "стоп" in command_lower:
        return "Проект остановлен"
    
    elif "сохрани" in command_lower:
        return "Проект сохранен"
    
    elif "создай скрипт" in command_lower:
        return "Скрипт создан"
    
    else:
        return f"Команда получена: {command}. Ожидание реализации..."

def process_alice_request(request_text: str) -> str:
    """Обработка запросов от Алисы"""
    return process_command(request_text, 'ru', '')

if __name__ == '__main__':
    print("=" * 50)
    print("AI_Yandex Server by LaskinPO")
    print("Запуск сервера на http://127.0.0.1:5000")
    print("=" * 50)
    app.run(host='127.0.0.1', port=5000, debug=False)
