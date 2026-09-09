"""
Flask сервер для обработки запросов от Яндекс Алисы и управления Godot
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import json
import threading
from godot_controller import GodotController
from ai_processor import AIProcessor
from yandex_alice import YandexAliceHandler

app = Flask(__name__)
CORS(app)

# Инициализация компонентов
godot_controller = GodotController()
ai_processor = AIProcessor()
alice_handler = YandexAliceHandler(godot_controller, ai_processor)

@app.route('/api/status', methods=['GET'])
def get_status():
    """Проверка статуса сервера"""
    return jsonify({
        'status': 'online',
        'message': 'AI Agent сервер запущен',
        'godot_connected': godot_controller.is_connected()
    })

@app.route('/api/alice/webhook', methods=['POST'])
def alice_webhook():
    """Webhook для Яндекс Алисы"""
    try:
        data = request.get_json()
        response = alice_handler.handle_request(data)
        return jsonify(response)
    except Exception as e:
        print(f"Ошибка обработки запроса Алисы: {e}")
        return jsonify({
            'response': {
                'text': 'Извините, произошла ошибка при обработке команды.',
                'end_session': False
            }
        }), 500

@app.route('/api/command', methods=['POST'])
def execute_command():
    """Прямое выполнение команды (для тестирования)"""
    try:
        data = request.get_json()
        command = data.get('command', '')
        parameters = data.get('parameters', {})
        
        result = godot_controller.execute_command(command, parameters)
        
        return jsonify({
            'success': True,
            'result': result
        })
    except Exception as e:
        return jsonify({
            'success': False,
            'error': str(e)
        }), 500

@app.route('/api/commands/list', methods=['GET'])
def list_commands():
    """Список доступных команд"""
    return jsonify({
        'commands': [
            {
                'name': 'create_scene',
                'description': 'Создать новую сцену',
                'parameters': ['type', 'name']
            },
            {
                'name': 'add_node',
                'description': 'Добавить ноду в сцену',
                'parameters': ['type', 'name', 'parent']
            },
            {
                'name': 'run_project',
                'description': 'Запустить проект',
                'parameters': []
            },
            {
                'name': 'save_scene',
                'description': 'Сохранить текущую сцену',
                'parameters': []
            },
            {
                'name': 'create_script',
                'description': 'Создать скрипт',
                'parameters': ['name', 'node']
            }
        ]
    })

if __name__ == '__main__':
    print("🚀 Запуск AI Agent сервера для Godot...")
    print("📡 Webhook URL для Яндекс Алисы: http://localhost:5000/api/alice/webhook")
    print("🎮 Godot контроллер инициализирован")
    
    # Запуск сервера
    app.run(host='0.0.0.0', port=5000, debug=True, threaded=True)
