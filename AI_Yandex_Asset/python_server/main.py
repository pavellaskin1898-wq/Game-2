#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
AI_Yandex Server - Python backend для управления Godot через Яндекс Алису
Автор: LaskinPO
Версия: 1.0.0
"""

from flask import Flask, request, jsonify
import requests
import json
import os

app = Flask(__name__)

# Глобальные переменные
yandex_tokens = {}
server_status = "online"

@app.route('/api/status', methods=['GET'])
def get_status():
    """Проверка статуса сервера"""
    return jsonify({
        "status": server_status,
        "service": "AI_Yandex Server",
        "author": "LaskinPO",
        "version": "1.0.0"
    })

@app.route('/api/auth/yandex', methods=['POST'])
def auth_yandex():
    """Получение OAuth токена Яндекс по логину и паролю"""
    data = request.json
    login = data.get('login')
    password = data.get('password')
    
    if not login or not password:
        return jsonify({"error": "Логин и пароль обязательны"}), 400
    
    # Здесь будет реальная логика получения токена от Яндекс
    # Для демонстрации возвращаем тестовый токен
    token = f"test_token_{login}"
    yandex_tokens[login] = token
    
    return jsonify({
        "success": True,
        "token": token,
        "message": "Токен получен успешно"
    })

@app.route('/api/alice/webhook', methods=['POST'])
def alice_webhook():
    """Webhook для Яндекс Алисы"""
    data = request.json
    
    # Обработка команды от Алисы
    command = data.get('command', '')
    
    # Пример обработки команд
    response_text = ""
    if "создай сцену" in command.lower():
        response_text = "Сцена создана успешно"
    elif "запусти проект" in command.lower():
        response_text = "Проект запущен"
    elif "останови проект" in command.lower():
        response_text = "Проект остановлен"
    elif "сохрани" in command.lower():
        response_text = "Проект сохранён"
    else:
        response_text = f"Команда получена: {command}"
    
    return jsonify({
        "response": {
            "text": response_text,
            "end_session": False
        },
        "session": data.get('session', {})
    })

@app.route('/api/command', methods=['POST'])
def execute_command():
    """Выполнение команды в Godot"""
    data = request.json
    command = data.get('command', '')
    token = data.get('token', '')
    
    if not token:
        return jsonify({"error": "Требуется токен авторизации"}), 401
    
    # Здесь будет логика выполнения команд в Godot
    return jsonify({
        "success": True,
        "message": f"Команда выполнена: {command}",
        "result": "Успешно"
    })

if __name__ == '__main__':
    print("🤖 AI_Yandex Server запущен (Автор: LaskinPO)")
    print("📡 Адрес: http://127.0.0.1:5000")
    print("✅ Статус: Online")
    app.run(host='127.0.0.1', port=5000, debug=False)
