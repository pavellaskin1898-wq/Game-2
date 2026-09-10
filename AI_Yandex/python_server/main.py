from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import json

app = Flask(__name__)
CORS(app)

# Store tokens and session data
yandex_tokens = {}
alice_sessions = {}

@app.route('/api/auth/yandex', methods=['POST'])
def auth_yandex():
    """Authenticate with Yandex using login and password"""
    data = request.json
    login = data.get('login')
    password = data.get('password')
    
    if not login or not password:
        return jsonify({'error': 'Login and password required'}), 400
    
    try:
        # Exchange login/password for OAuth token
        # Note: This is a simplified example. In production, use proper OAuth flow
        oauth_url = "https://oauth.yandex.ru/token"
        payload = {
            'grant_type': 'password',
            'client_id': 'YOUR_YANDEX_CLIENT_ID',  # Replace with your client ID
            'client_secret': 'YOUR_YANDEX_CLIENT_SECRET',  # Replace with your client secret
            'username': login,
            'password': password
        }
        
        # For demo purposes, generate a mock token
        # In production, make the actual request to Yandex OAuth
        mock_token = f"yandex_token_{login}_{hash(password)}"
        yandex_tokens[login] = mock_token
        
        return jsonify({
            'success': True,
            'token': mock_token,
            'message': 'Authentication successful'
        })
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/alice/webhook', methods=['POST'])
def alice_webhook():
    """Webhook for Yandex Alice skills"""
    data = request.json
    command = data.get('request', {}).get('command', '')
    session_id = data.get('session', {}).get('session_id', '')
    
    # Process command
    response_text = process_command(command)
    
    return jsonify({
        'response': {
            'text': response_text,
            'end_session': False
        },
        'session': {
            'session_id': session_id
        }
    })

@app.route('/api/command', methods=['POST'])
def execute_command():
    """Execute a command in Godot"""
    data = request.json
    command = data.get('command', '')
    token = request.headers.get('Authorization', '').replace('Bearer ', '')
    
    if not command:
        return jsonify({'error': 'Command required'}), 400
    
    # Process the command
    result = process_godot_command(command)
    
    return jsonify({
        'success': True,
        'result': result,
        'command': command
    })

@app.route('/api/status', methods=['GET'])
def get_status():
    """Get server status"""
    return jsonify({
        'status': 'online',
        'active_sessions': len(alice_sessions),
        'authenticated_users': len(yandex_tokens)
    })

def process_command(command: str) -> str:
    """Process natural language command"""
    command_lower = command.lower()
    
    if 'создай сцену' in command_lower or 'create scene' in command_lower:
        return "Создаю новую сцену..."
    elif 'добавь игрока' in command_lower or 'add player' in command_lower:
        return "Добавляю игрока..."
    elif 'запусти проект' in command_lower or 'run project' in command_lower:
        return "Запускаю проект..."
    elif 'сохрани' in command_lower or 'save' in command_lower:
        return "Сохраняю текущую сцену..."
    else:
        return f"Получена команда: {command}. Обрабатываю..."

def process_godot_command(command: str) -> str:
    """Process command for Godot engine"""
    # Here you would integrate with Godot's API
    # For now, return a mock response
    return f"Command '{command}' executed successfully"

if __name__ == '__main__':
    print("AI_Yandex Server starting...")
    print("Author: LaskinPO")
    print("Server running on http://localhost:5000")
    app.run(host='0.0.0.0', port=5000, debug=True)
