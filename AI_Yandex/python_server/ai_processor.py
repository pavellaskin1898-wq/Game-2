"""
AI процессор для обработки естественного языка
Преобразует русскоязычные команды в структурированные команды для Godot
"""

import re
from typing import Dict, Any, Optional, List

class AIProcessor:
    """Класс для обработки естественного языка и извлечения команд"""
    
    def __init__(self):
        # Паттерны для распознавания команд (порядок важен!)
        self.command_patterns = {
            'create_scene': [
                r'создай\s+(новую\s+)?сцену?\s*(.*)',
                r'создать\s+(новую\s+)?сцену?\s*(.*)',
                r'новая\s+сцена\s*(.*)',
            ],
            'create_script': [
                r'создай\s+скрипт\s*(.*)',
                r'создать\s+скрипт\s*(.*)',
            ],
            'add_node': [
                r'добавь\s+(\w+)\s*(.*)',
                r'добавить\s+(\w+)\s*(.*)',
            ],
            'create_node': [
                r'создай\s+(\w+)\s*(.*)',
                r'создать\s+(\w+)\s*(.*)',
            ],
            'run_project': [
                r'запусти\s+проект\s*(.*)',
                r'запустить\s+проект\s*(.*)',
                r'старт\s*(.*)',
                r'играть\s*(.*)',
            ],
            'save_scene': [
                r'сохрани\s+(сцену?)?\s*(.*)',
                r'сохранить\s+(сцену?)?\s*(.*)',
                r'сейв\s*(.*)',
            ],
            'new_script': [
                r'новый\s+скрипт\s*(.*)',
            ],
            'delete_node': [
                r'удали\s+(\w*)\s*(.*)',
                r'удалить\s+(\w*)\s*(.*)',
            ],
        }
        
        # Словарь типов нод Godot
        self.node_types = {
            'игрок': 'CharacterBody2D',
            'персонаж': 'CharacterBody2D',
            'спрайт': 'Sprite2D',
            'камера': 'Camera2D',
            'свет': 'DirectionalLight3D',
            'лампа': 'PointLight2D',
            'коллизия': 'CollisionShape2D',
            'физика': 'RigidBody2D',
            'статик': 'StaticBody2D',
            'ui': 'Control',
            'кнопка': 'Button',
            'надпись': 'Label',
            'текст': 'RichTextLabel',
            'узл': 'Node',  # узел
            'нода': 'Node',
            'объект': 'Node3D',
            'меш': 'MeshInstance3D',
            'анимация': 'AnimatedSprite2D',
            'тайлмап': 'TileMap',
            'партиклы': 'GPUParticles2D',
        }
    
    def process_natural_language(self, text: str) -> Optional[Dict[str, Any]]:
        """
        Обработка естественного языка и извлечение команды
        
        Args:
            text: Текст команды на русском языке
            
        Returns:
            Структурированная команда или None
        """
        text = text.lower().strip()
        
        # Проходим по всем паттернам команд
        for command_name, patterns in self.command_patterns.items():
            for pattern in patterns:
                match = re.search(pattern, text)
                if match:
                    return self._build_command(command_name, match, text)
        
        # Если команда не распознана, пробуем использовать простой анализ
        return self._fallback_processing(text)
    
    def _build_command(self, command_name: str, match: re.Match, full_text: str) -> Dict[str, Any]:
        """Построение структурированной команды на основе совпадения"""
        
        parameters = {}
        
        if command_name == 'create_scene':
            parameters['type'] = 'Node3D'
            parameters['name'] = 'MainScene'
            
            # Пытаемся извлечь тип сцены
            extra = match.group(2) if len(match.groups()) > 1 else ''
            if '2d' in extra or 'два д' in extra:
                parameters['type'] = 'Node2D'
            if 'игрок' in extra or 'персонаж' in extra:
                parameters['name'] = 'PlayerScene'
        
        elif command_name in ['add_node', 'create_node']:
            node_word = match.group(1) if match.lastindex >= 1 else 'нода'
            
            # Определяем тип ноды
            node_type = 'Node'
            for keyword, godot_type in self.node_types.items():
                if keyword in node_word:
                    node_type = godot_type
                    break
            
            parameters['type'] = node_type
            parameters['name'] = node_word.capitalize()
        
        elif command_name == 'run_project':
            pass  # Нет параметров
        
        elif command_name == 'save_scene':
            pass  # Нет параметров
        
        elif command_name == 'create_script':
            extra = match.group(1) if match.lastindex >= 1 else ''
            parameters['name'] = 'script.gd'
            if extra:
                # Пытаемся извлечь имя скрипта
                name_match = re.search(r'(\w+)\.?gd?', extra)
                if name_match:
                    parameters['name'] = f"{name_match.group(1)}.gd"
        
        elif command_name == 'delete_node':
            node_word = match.group(1) if match.lastindex >= 1 else ''
            parameters['name'] = node_word if node_word else 'SelectedNode'
        
        return {
            'command': command_name,
            'parameters': parameters,
            'original_text': full_text
        }
    
    def _fallback_processing(self, text: str) -> Optional[Dict[str, Any]]:
        """Резервная обработка для нераспознанных команд"""
        
        # Простой поиск ключевых слов
        if any(word in text for word in ['сцен', 'уровень', 'карт']):
            return {
                'command': 'create_scene',
                'parameters': {'type': 'Node3D', 'name': 'NewScene'},
                'original_text': text
            }
        
        if any(word in text for word in ['запуск', 'старт', 'играть', 'тест']):
            return {
                'command': 'run_project',
                'parameters': {},
                'original_text': text
            }
        
        if any(word in text for word in ['сохран', 'сейв']):
            return {
                'command': 'save_scene',
                'parameters': {},
                'original_text': text
            }
        
        return None
    
    def get_supported_commands(self) -> List[str]:
        """Возвращает список поддерживаемых команд"""
        return list(self.command_patterns.keys())
    
    def add_custom_pattern(self, command_name: str, pattern: str):
        """Добавление пользовательского паттерна"""
        if command_name not in self.command_patterns:
            self.command_patterns[command_name] = []
        self.command_patterns[command_name].append(pattern)
