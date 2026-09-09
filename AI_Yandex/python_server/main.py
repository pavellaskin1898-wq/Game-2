#!/usr/bin/env python3
"""
AI_Yandex Server - Python сервер для интеграции с Яндекс Алисой
Автор: LaskinPO
"""

from flask import Flask, request, jsonify
import requests
import json
import os

app = Flask(__name__)

# Глобальные переменные для хранения токена и сессии
yandex_token = None
session_data = {}

@app.route('/api/auth/yandex', methods=['POST'])
def auth_yandex():
    """Получение OAuth токена Яндекса по логину и паролю"""
    data = request.json
    login = data.get('login')
    password = data.get('password')
    
    if not login or not password:
        return jsonify({'error': 'Требуется логин и пароль'}), 400
    
    try:
        # Запрос токена через OAuth Яндекс
        # Примечание: Для продакшена нужно использовать proper OAuth flow
        oauth_url = "https://oauth.yandex.ru/token"
        payload = {
            'grant_type': 'password',
            'client_id': 'your_client_id',  # Нужно зарегистрировать приложение в Яндекс OAuth
            'client_secret': 'your_client_secret',
            'username': login,
            'password': password
        }
        
        # В реальном проекте здесь будет правильный OAuth запрос
        # Для демонстрации возвращаем mock токен
        global yandex_token
        yandex_token = f"mock_token_{login}"
        
        return jsonify({
            'success': True,
            'token': yandex_token,
            'message': 'Токен получен успешно'
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/status', methods=['GET'])
def get_status():
    """Проверка статуса сервера"""
    return jsonify({
        'status': 'online',
        'connected': yandex_token is not None,
        'author': 'LaskinPO'
    })

@app.route('/api/alice/webhook', methods=['POST'])
def alice_webhook():
    """Webhook для Яндекс Алисы"""
    data = request.json
    
    if not data:
        return jsonify({'error': 'Нет данных'}), 400
    
    # Обработка запроса от Алисы
    command = data.get('request', {}).get('original_utterance', '')
    
    response = process_command(command)
    
    return jsonify({
        'response': {
            'text': response['message'],
            'end_session': False
        },
        'version': '1.0'
    })

@app.route('/api/command', methods=['POST'])
def execute_command():
    """Выполнение команды от пользователя"""
    data = request.json
    command = data.get('command', '')
    
    if not command:
        return jsonify({'error': 'Команда не указана'}), 400
    
    result = process_command(command)
    return jsonify(result)

def process_command(command: str) -> dict:
    """Обработка текстовой команды и генерация действий для Godot"""
    command_lower = command.lower()
    
    actions = []
    message = "Команда распознана"
    
    if 'создай сцену' in command_lower or 'новая сцена' in command_lower:
        actions.append({'action': 'create_scene', 'type': 'Node3D'})
        message = "Создаю новую сцену..."
    
    elif 'добавь ноду' in command_lower or 'создай объект' in command_lower:
        actions.append({'action': 'add_node', 'type': 'Node3D'})
        message = "Добавляю ноду в сцену..."
    
    elif 'запусти' in command_lower or 'старт' in command_lower:
        actions.append({'action': 'run_project'})
        message = "Запускаю проект..."
    
    elif 'сохрани' in command_lower:
        actions.append({'action': 'save_scene'})
        message = "Сохраняю сцену..."
    
    elif 'скрипт' in command_lower:
        actions.append({'action': 'create_script'})
        message = "Создаю новый скрипт..."
    
    else:
        message = f"Команда '{command}' требует уточнения"
    
    return {
        'success': True,
        'message': message,
        'actions': actions
    }

if __name__ == '__main__':
    print("🤖 AI_Yandex Server запущен (Автор: LaskinPO)")
    print("📡 Слушаю http://localhost:5000")
    app.run(host='0.0.0.0', port=5000, debug=True)
