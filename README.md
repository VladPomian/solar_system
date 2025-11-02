# **Solar System**  
**Кроссплатформенное мобильное приложение для исследования Солнечной системы и предсказания солнечных явлений**

## **О проекте**

**Solar System** — это кроссплатформенное мобильное приложение на **Flutter**, разработанное для изучения Солнечной системы, симуляции космических объектов и анализа предсказаний солнечных явлений (CME, FLR, GST) на основе данных NASA.

Приложение взаимодействует с серверной частью через **RabbitMQ**, получает предсказания, сгенерированные Python-скриптом с использованием **Prophet**, и отображает их в интерактивных графиках.

Связанные проекты:
- Сервер: [Python Interpretation Server](https://github.com/VladPomian/ServerPythonInterpretation)
- Python-скрипт для прогнозов: [Solar Activity Forecasting](https://github.com/VladPomian/prediction_script)

---

## Скриншоты

<table>
  <tr>
    <td><img src="assets/demo/home_light_theme.jfif" width="300" alt="Home Light"/></td>
    <td><img src="assets/demo/home_dark_theme.jfif" width="300" alt="Home Dark"/></td>
    <td><img src="assets/demo/simulation.jfif" width="300" alt="Simulation"/></td>
  </tr>
  <tr>
    <td><img src="assets/demo/planets_page.jfif" width="300" alt="Planets Page"/></td>
    <td><img src="assets/demo/planets_detail.jfif" width="300" alt="Planet Detail"/></td>
    <td><img src="assets/demo/planets_AR.jfif" width="300" alt="Planet AR"/></td>
  </tr>
  <tr>
    <td><img src="assets/demo/prediction_page.jfif" width="300" alt="Prediction Page"/></td>
    <td><img src="assets/demo/prediction_graph_first.jfif" width="300" alt="Graph 1"/></td>
    <td><img src="assets/demo/prediction_graph_second.jfif" width="300" alt="Graph 2"/></td>
  </tr>
  <tr>
    <td><img src="assets/demo/prediction_diagram.jfif" width="300" alt="Diagram"/></td>
    <td><img src="assets/demo/prediction_table.jfif" width="300" alt="Table"/></td>
    <td><img src="assets/demo/request_dialog.jfif" width="300" alt="AI Request"/></td>
  </tr>
  <tr>
    <td><img src="assets/demo/answer_nav_dialog.jfif" width="300" alt="AI Navigation"/></td>
    <td><img src="assets/demo/answer_dialog.jfif" width="300" alt="AI Answer"/></td>
    <td><img src="assets/demo/settings_general.jfif" width="300" alt="Settings"/></td>
  </tr>
  <tr>
    <td><img src="assets/demo/settings_general_type2.jfif" width="300" alt="Settings Type"/></td>
    <td><img src="assets/demo/settings_voice_assist.jfif" width="300" alt="Voice Settings"/></td>
    <td><img src="assets/demo/settings_about_app.jfif" width="300" alt="About App"/></td>
  </tr>
  <tr>
    <td><img src="assets/demo/settings_version_dialog.jfif" width="300" alt="Version"/></td>
    <td><img src="assets/demo/settings_developer_dialog.jfif" width="300" alt="Dev Dialog"/></td>
    <td><img src="assets/demo/settings_help_card.jfif" width="300" alt="Help Card"/></td>
  </tr>
  <tr>
    <td colspan="3" style="text-align:center;"><img src="assets/demo/settings_help_answer.jfif" width="300" alt="Help Answer"/></td>
  </tr>
</table>

---

## **Основные функции**

### **Главная и навигация**
- Домашний экран с фоновым изображением и надписью **"Исследуйте Солнечную систему"**
- Свайп вверх / тап → переход к экрану с **вертикальной каруселью из 3 карточек**
- Свайп / тап по неактивной карточке → смена активной
- Тап по активной → переход в соответствующий раздел

### **1. Симуляция Солнечной системы**
- 3D-модель с **Солнце + 8 планет + Луна + орбиты**
- Реалистичная физика вращения:
  - Планеты вращаются вокруг Солнца
  - Луна вращается вокруг Земли
  - Все объекты вращаются вокруг своей оси
- Основано на **`flutter_cube`**

### **2. Исследование планет**
- Анимированная карточка планеты через **Lottie**
- Свайп влево/вправо → смена планеты
- Кнопка **"Узнать больше"** → детальный экран:
  - 3D-модель планеты
  - Кнопка AR-режима
  - Текстовое описание
  - Кнопка **"Все планеты"** → возврат

### **3. Предсказания солнечных явлений**
- Данные: **CME, FLR, GST** (предсказания на год вперёд)
- 3 выпадающих списка → выбор типа графика:
  - Линейный
  - Столбчатый
  - Круговая диаграмма
  - Таблица
- Интерактивные графики (масштаб по месяцам)
- Круговая диаграмма: соотношение **превышений / нормы**
- Таблица: фильтр **"все данные" / "только превышения"**
- Подвал:
  - Дата последнего обновления + статус
  - Кнопка **"Обновить данные"**
  - **Оффлайн-режим** с кэшем

### **4. ИИ-помощник**
- Доступен с любого экрана (оверлей, правый верхний угол)
- Ввод текста или голосовая запись
- Запросы отправляются в **Cerebras.ai API**
- Ответ в карточке:
  - Текст + TTS-озвучка
  - Кнопка **"Ресурс"** или **навигация в приложение**
- Логика:
  - Если запрос по теме приложения → **навигация + ответ**
  - Иначе → **ссылка на ресурс**
- Кнопка скрытия → сворачивается в иконку

### **5. Настройки**
#### Общие
- **Тема**: Светлая (white/black/cyan) / Тёмная (black/white/amber)
- **Размер шрифта**: Маленький / Средний / Большой
- **Анимации**: Вкл/Выкл (все эффекты)

#### Голосовой помощник
- **Автопроизношение** ответа ИИ
- **Скорость речи**: слайдер 0.1–1.0
- **Модель ИИ**:
  - Llama Scout
  - Llama 8B / 70B
  - GPT OSS
  - Qwen 32B / 235B Instruct / 235B Thinking / 480B Coder

#### О приложении
- Версия: **0.9.0** + инфо (сборка, дата, changelog)
- Разработчик: ссылки на **Telegram** и **GitHub**
- **Очистить кэш** + диалог подтверждения

#### Поддержка
- Экран помощи: 9 больших карточек (3×3)
- 5 строк быстрого доступа
- Развёртка → списки FAQ → детальные ответы
- Оценка статьи: **"Полезна?" → Да/Нет**

---

## Требования

- Flutter 3.19+
- Dart 3.3+
- Android/iOS эмулятор или устройство

---

## **Установка и запуск**

# Клонировать репозиторий
git clone https://github.com/VladPomian/solar_system.git
cd solar_system

# Установить зависимости
flutter pub get

# Запустить
flutter run

---

# Ссылки

- [NASA API](https://api.nasa.gov/)
- [Cerebras.ai API](https://cerebras.ai/)
- [Flutter Cube](https://pub.dev/packages/flutter_cube)
- [Lottie for Flutter](https://pub.dev/packages/lottie)

## Контакты

Если у вас есть вопросы или предложения, создайте issue в репозитории или свяжитесь с автором: VladPomian.
