"""
Обработчик запросов от Яндекс Алисы
"""

import json
from typing import Dict, Any

class YandexAliceHandler:
    """Класс для обработки запросов от Яндекс Алисы"""
    
    def __init__(self, godot_controller, ai_processor):
        self.godot_controller = godot_controller
        self.ai_processor = ai_processor
        
        # Приветственное сообщение
        self.welcome_message = (
            "Привет! Я AI агент для управления Godot. "
            "Я могу помогать тебе создавать игры голосом. "
            "Что ты хочешь сделать? Например: создай сцену, добавь игрока, запусти проект."
        )
    
    def handle_request(self, data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Обработка входящего запроса от Алисы
        
        Args:
            data: Данные запроса от Яндекс Диалогов
            
        Returns:
            Ответ в формате Яндекс Диалогов
        """
        try:
            # Извлекаем команду из запроса
            command_text = self._extract_command(data)
            
            if not command_text:
                return self._create_response(
                    text="Я не расслышала команду. Повтори пожалуйста.",
                    end_session=False
                )
            
            # Обрабатываем команду через AI процессор
            processed_command = self.ai_processor.process_natural_language(command_text)
            
            if processed_command:
                # Выполняем команду в Godot
                result = self.godot_controller.execute_command(
                    processed_command['command'],
                    processed_command.get('parameters', {})
                )
                
                # Формируем ответ
                response_text = self._generate_response(processed_command, result)
                return self._create_response(text=response_text, end_session=False)
            else:
                return self._create_response(
                    text="Извините, я не поняла команду. Попробуйте сказать: 'создай сцену' или 'добавь игрока'",
                    end_session=False
                )
                
        except Exception as e:
            print(f"Ошибка при обработке запроса Алисы: {e}")
            return self._create_response(
                text="Произошла ошибка при выполнении команды. Проверьте логи сервера.",
                end_session=False
            )
    
    def _extract_command(self, data: Dict[str, Any]) -> str:
        """Извлечение текста команды из запроса"""
        try:
            request_data = data.get('request', {})
            original_utterance = request_data.get('original_utterance', '')
            return original_utterance.strip()
        except Exception:
            return ""
    
    def _create_response(self, text: str, end_session: bool = False) -> Dict[str, Any]:
        """Создание ответа в формате Яндекс Диалогов"""
        return {
            'response': {
                'text': text,
                'tts': text,  # Text-to-Speech версия
                'end_session': end_session
            },
            'version': '1.0'
        }
    
    def _generate_response(self, command: Dict[str, Any], result: Any) -> str:
        """Генерация понятного ответа для пользователя"""
        cmd_name = command.get('command', 'unknown')
        
        responses = {
            'create_scene': f"✅ Сцена создана! Тип: {command.get('parameters', {}).get('type', 'Node3D')}",
            'add_node': f"✅ Нода добавлена в сцену: {command.get('parameters', {}).get('name', 'NewNode')}",
            'run_project': "🎮 Проект запущен! Удачи в тестировании!",
            'save_scene': "💾 Сцена сохранена",
            'create_script': f"📝 Скрипт создан: {command.get('parameters', {}).get('name', 'script.gd')}"
        }
        
        return responses.get(cmd_name, f"✅ Команда выполнена: {cmd_name}")
