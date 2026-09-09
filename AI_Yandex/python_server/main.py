from flask import Flask, request, jsonify
import requests
import threading
import time

app = Flask(__name__)

# Store for auth tokens
user_tokens = {}
server_running = False

@app.route('/api/auth/yandex', methods=['POST'])
def auth_yandex():
    """Authenticate with Yandex using login/password"""
    data = request.json
    login = data.get('login')
    password = data.get('password')
    
    if not login or not password:
        return jsonify({'error': 'Login and password required'}), 400
    
    try:
        # Yandex OAuth token request
        token_url = 'https://oauth.yandex.ru/token'
        payload = {
            'grant_type': 'password',
            'client_id': '23cabbbdc6cd418abb4b39eb33ef1687',
            'client_secret': '350bc83bd02bc2a48f042bae9e71f8f8',
            'username': login,
            'password': password
        }
        
        response = requests.post(token_url, data=payload)
        result = response.json()
        
        if 'access_token' in result:
            user_tokens[login] = result['access_token']
            return jsonify({
                'success': True,
                'token': result['access_token'],
                'message': 'Authentication successful'
            })
        else:
            return jsonify({
                'success': False,
                'error': result.get('error', 'Unknown error'),
                'message': result.get('error_description', 'Authentication failed')
            }), 401
            
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/status', methods=['GET'])
def get_status():
    """Get server status"""
    return jsonify({
        'running': server_running,
        'active_users': len(user_tokens),
        'message': 'AI_Yandex server is running' if server_running else 'Server stopped'
    })

@app.route('/api/alice/webhook', methods=['POST'])
def alice_webhook():
    """Webhook for Yandex Alice"""
    data = request.json
    command = data.get('request', {}).get('command', '')
    return jsonify({
        'response': {
            'text': f'Command received: {command}',
            'end_session': False
        },
        'version': '1.0'
    })

@app.route('/api/command', methods=['POST'])
def execute_command():
    """Execute Godot command from AI"""
    data = request.json
    command = data.get('command', '')
    print(f"Executing command: {command}")
    return jsonify({'success': True, 'message': f'Command executed: {command}'})

def run_server():
    global server_running
    server_running = True
    app.run(host='127.0.0.1', port=8080, debug=False)

if __name__ == '__main__':
    print("Starting AI_Yandex Python Server...")
    print("Author: LaskinPO")
    run_server()
