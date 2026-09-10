from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

# Конфигурация
YANDEX_CLIENT_ID = "YOUR_YANDEX_CLIENT_ID"
YANDEX_CLIENT_SECRET = "YOUR_YANDEX_CLIENT_SECRET"

@app.route('/api/status', methods=['GET'])
def get_status():
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
        return jsonify({"error": "Требуется логин и пароль"}), 400
    
    # Здесь будет логика получения токена через Яндекс OAuth
    # Для безопасности рекомендуется использовать OAuth с кодом подтверждения
    
    return jsonify({
        "success": True,
        "token": "mock_token_12345",
        "message": "Токен получен успешно"
    })

@app.route('/api/command', methods=['POST'])
def execute_command():
    """Выполнение команды в Godot"""
    data = request.json
    command = data.get('command', '')
    
    print(f"AI_Yandex: Получена команда: {command}")
    
    # Обработка команд на русском языке
    response = process_russian_command(command)
    
    return jsonify(response)

def process_russian_command(command: str):
    """Обработка команд на русском языке"""
    command = command.lower().strip()
    
    if "создай сцену" in command or "новая сцена" in command:
        return {"action": "create_scene", "message": "Сцена создана успешно"}
    
    elif "добавь ноду" in command or "создать ноду" in command:
        return {"action": "add_node", "message": "Нода добавлена"}
    
    elif "запусти" in command or "старт" in command:
        return {"action": "run_project", "message": "Проект запущен"}
    
    elif "останови" in command or "стоп" in command:
        return {"action": "stop_project", "message": "Проект остановлен"}
    
    elif "сохрани" in command:
        return {"action": "save_scene", "message": "Сцена сохранена"}
    
    else:
        return {"action": "unknown", "message": "Команда не распознана"}

if __name__ == '__main__':
    print("🤖 AI_Yandex Server by LaskinPO")
    print("📡 Запуск сервера на http://127.0.0.1:5000")
    app.run(host='127.0.0.1', port=5000, debug=False)
