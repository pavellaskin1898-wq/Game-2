"""
Контроллер для взаимодействия с Godot Editor
Отправляет команды в плагин Godot через HTTP/GDScript
"""

import requests
import json
from typing import Dict, Any, Optional

class GodotController:
    """Класс для управления Godot из Python"""
    
    def __init__(self, godot_url: str = "http://localhost:6000"):
        self.godot_url = godot_url
        self.connected = False
    
    def is_connected(self) -> bool:
        """Проверка подключения к Godot"""
        try:
            response = requests.get(f"{self.godot_url}/ping", timeout=2)
            self.connected = response.status_code == 200
            return self.connected
        except Exception:
            self.connected = False
            return False
    
    def execute_command(self, command: str, parameters: Dict[str, Any] = {}) -> Dict[str, Any]:
        """
        Выполнение команды в Godot
        
        Args:
            command: Название команды (create_scene, add_node, и т.д.)
            parameters: Параметры команды
            
        Returns:
            Результат выполнения
        """
        payload = {
            'command': command,
            'parameters': parameters
        }
        
        try:
            # Отправляем команду в Godot плагин
            response = requests.post(
                f"{self.godot_url}/api/execute",
                json=payload,
                headers={'Content-Type': 'application/json'},
                timeout=10
            )
            
            if response.status_code == 200:
                result = response.json()
                print(f"✅ Команда '{command}' выполнена успешно")
                return result
            else:
                print(f"❌ Ошибка выполнения команды: {response.status_code}")
                return {'success': False, 'error': f'HTTP {response.status_code}'}
                
        except requests.exceptions.ConnectionError:
            # Если Godot не подключен, эмулируем выполнение (для демонстрации)
            print(f"⚠️ Godot не подключен, эмуляция команды: {command}")
            return self._emulate_command(command, parameters)
        except Exception as e:
            print(f"❌ Исключение при выполнении команды: {e}")
            return {'success': False, 'error': str(e)}
    
    def _emulate_command(self, command: str, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Эмуляция выполнения команды (когда Godot не подключен)"""
        emulation_responses = {
            'create_scene': {
                'success': True,
                'message': f"[ЭМУЛЯЦИЯ] Сцена создана: {parameters.get('name', 'Main')}",
                'scene_path': 'res://scenes/main.tscn'
            },
            'add_node': {
                'success': True,
                'message': f"[ЭМУЛЯЦИЯ] Нода добавлена: {parameters.get('type', 'Node')}",
                'node_name': parameters.get('name', 'NewNode')
            },
            'run_project': {
                'success': True,
                'message': '[ЭМУЛЯЦИЯ] Проект запущен'
            },
            'save_scene': {
                'success': True,
                'message': '[ЭМУЛЯЦИЯ] Сцена сохранена'
            },
            'create_script': {
                'success': True,
                'message': f"[ЭМУЛЯЦИЯ] Скрипт создан: {parameters.get('name', 'script.gd')}"
            }
        }
        
        return emulation_responses.get(command, {
            'success': True,
            'message': f'[ЭМУЛЯЦИЯ] Команда выполнена: {command}'
        })
    
    def set_server_url(self, url: str):
        """Установка URL для подключения к Godot"""
        self.godot_url = url
        print(f"🔗 URL Godot установлен: {url}")
