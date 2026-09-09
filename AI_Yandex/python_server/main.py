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

# Глобальная переменная для хранения токена
yandex_oauth_token = None

@app.route('/api/status', methods=['GET'])
def get_status():
    """Проверка статуса сервера"""
    return jsonify({
        'status': 'online',
        'message': 'AI Agent сервер запущен',
        'godot_connected': godot_controller.is_connected()
    })

@app.route('/api/auth/yandex', methods=['POST'])
def yandex_auth():
    """Получение OAuth токена Яндекс по логину и паролю"""
    global yandex_oauth_token
    try:
        data = request.get_json()
        login = data.get('login', '')
        password = data.get('password', '')
        
        if not login or not password:
            return jsonify({'error': 'Логин и пароль обязательны'}), 400
        
        # Запрос к Яндекс API для получения токена
        import requests
        
        # Client ID и Secret нужно зарегистрировать в https://oauth.yandex.ru/client/new
        # Создайте приложение и получите эти данные
        CLIENT_ID = 'your_yandex_client_id'  # Замените на ваш Client ID из https://oauth.yandex.ru/client/new
        CLIENT_SECRET = 'your_yandex_client_secret'  # Замените на ваш Client Secret
        
        # Шаг 1: Получаем код авторизации через запрос к Яндекс
        # ВНИМАНИЕ: Это упрощенная схема. Для продакшена используйте полноценный OAuth 2.0 flow
        auth_response = requests.post(
            'https://oauth.yandex.ru/token',
            data={
                'grant_type': 'password',
                'client_id': CLIENT_ID,
                'client_secret': CLIENT_SECRET,
                'username': login,
                'password': password
            },
            timeout=10
        )
        
        if auth_response.status_code == 200:
            token_data = auth_response.json()
            yandex_oauth_token = token_data.get('access_token', '')
            
            return jsonify({
                'token': yandex_oauth_token,
                'message': 'Токен успешно получен'
            })
        else:
            return jsonify({
                'error': 'Ошибка аутентификации Яндекс',
                'details': auth_response.text
            }), 401
        
    except requests.exceptions.RequestException as e:
        print(f"Ошибка запроса к Яндекс: {e}")
        return jsonify({
            'error': 'Ошибка соединения с Яндекс',
            'details': str(e)
        }), 500
    except Exception as e:
        print(f"Ошибка аутентификации Яндекс: {e}")
        return jsonify({'error': str(e)}), 500

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
