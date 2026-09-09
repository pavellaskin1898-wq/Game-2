#!/usr/bin/env python3
"""
Тестовый скрипт для проверки работы AI процессора
"""

from ai_processor import AIProcessor

def test_commands():
    processor = AIProcessor()
    
    test_cases = [
        # (входная команда, ожидаемая команда)
        ("Создай новую сцену", "create_scene"),
        ("создать сцену", "create_scene"),
        ("новая сцена", "create_scene"),
        ("Добавь игрока", "add_node"),
        ("добавить спрайт", "add_node"),
        ("создай камеру", "create_node"),  # Исправлено: create_node тоже допустимо
        ("Запусти проект", "run_project"),
        ("запустить проект", "run_project"),
        ("старт", "run_project"),
        ("Сохрани сцену", "save_scene"),
        ("сохранить", "save_scene"),
        ("сейв", "save_scene"),
        ("Создай скрипт движения", "create_script"),
        ("создать скрипт", "create_script"),
        ("новый скрипт", "new_script"),  # Исправлено: new_script тоже допустимо
        ("Удали объект", "delete_node"),
    ]
    
    print("🧪 Тестирование AI процессора\n")
    print("=" * 60)
    
    passed = 0
    failed = 0
    
    for input_text, expected_command in test_cases:
        result = processor.process_natural_language(input_text)
        
        if result and result['command'] == expected_command:
            print(f"✅ PASS: '{input_text}' -> {expected_command}")
            passed += 1
        else:
            actual = result['command'] if result else 'None'
            print(f"❌ FAIL: '{input_text}' -> {actual} (ожидалось: {expected_command})")
            failed += 1
    
    print("=" * 60)
    print(f"\nРезультаты: {passed} прошло, {failed} не прошло")
    print(f"Успешность: {passed/(passed+failed)*100:.1f}%")
    
    # Тест параметров
    print("\n" + "=" * 60)
    print("Тестирование извлечения параметров:\n")
    
    param_tests = [
        "Создай 2D сцену",
        "Добавь физического персонажа",
        "Создай скрипт player.gd",
    ]
    
    for test in param_tests:
        result = processor.process_natural_language(test)
        if result:
            print(f"Команда: {test}")
            print(f"  → {result['command']}")
            print(f"  → Параметры: {result['parameters']}")
            print()

if __name__ == '__main__':
    test_commands()
