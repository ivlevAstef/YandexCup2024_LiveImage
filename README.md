# YandexCup 2024 Live Image

Данная задача делалась для Yandex Cup 2024 года в направлении iOS в полуфинале.

На написание задачи давалась одна неделя. Сколько ушло в часах на данный код написан в конце.

## Условие
Разработать мобильное приложение, в котором можно нарисовать и воспроизвести покадровую анимацию на экране смартфона.
Дизайн нарисован в Figma, но по желанию можно было реализовать свой - если он будет удобней, дадут доп. баллы.

## Основные механики
Функционал можно разделить на три части:
* Панель управления - состоит из 7 действий: 
    - 1-2. undo/redo для отмены и возврата действия.
    - 3-5. Работа с кадрами - для добавления/удаления и просмотра всех кадров.
    - 6-7. Работа с проигрыванием - начать и поставить на паузу проигрывание получившегося видео.
    
* Холст - на нем можно рисовать с использованием инструментов для рисования, в рамках текущего кадра. Помимо этого на холсте отображается полупрозрачным предыдущий кадр.

* Панель рисования - на ней расположены элементы для рисования: карандаш, кисточка, ластик, фигура, и выбранный цвет рисования. По умолчанию можно выбрать из трех цветов. 

Это короткое описание, из чего состояло задание. Помимо основного функционала есть еще дополнительный, за который добавляли доп. балы. 

## Дополнительный функционал
- [ ] Генерация и добавление N случайных кадров. Содержание холстов отдаётся на усмотрение участников — к примеру, это может быть генерация различных геометрических фигур или перемещение одной готовой фигуры. Изображения на сгенерированных кадрах должны явно отличаться друг от друга. Количество кадров должно задаваться вводом числа N с размерностью Integer в интерфейсе приложения непосредственно перед генерацией. Сгенерированные кадры добавляются за последним кадром и ведут себя идентично кадрам, добавленным вручную: допускается удаление кадров, изменение последнего кадра и т. д.
- [x] Панель либо экран с раскадровкой для переключения между добавленными кадрами. Также допускается реализовать переключение кадров свайпами влево и вправо от края экрана.
- [x] Кнопка дублирования кадра — создаёт новый кадр и копирует на него всё содержимое текущего кадра.
- [ ] Возможность удаления всех кадров сразу.
- [ ] Настройка скорости воспроизведения анимации.
- [ ] Экспорт анимации в GIF с возможностью поделиться файлом.
- [ ] Выбор кастомного любого цвета рисования из RGB-палитры.
- [ ] Инструмент рисования геометрических фигур, прямых линий или кривых Безье (минимум 3 разных фигур), а также взаимодействие с фигурами: увеличение растягиванием или pinch to zoom, перемещение, поворот.
- [ ] Изменение толщины карандаша и ластика.
- [x] Реализация стека действий для многократной отмены или возврата.
- [ ] Увеличение холста при помощи жеста pinch-to-zoom для точной прорисовки деталей изображения.
Иконка приложения.
- [ ] Полноценная поддержка светлой и тёмной тем.


## Мои комментарии
В целом задача не сложная. При реализации старался отбросить все лишние конструкции и усложнения в архитектуре, дабы не заграмождать код лишним - расширять, и поддерживать данный код в любом случае не планируется.
Так-как по условию задачи нельзя использовать сторонние библиотеки (за некоторым исключением), то и свои библиотеки, и наработки, я не использовал в коде - ни сложных логгеров, ни DI контейнеров, ни других внутренних наработок.  

## Время
* 1.5 часа - подготовка. Написание README, создание базового проекта, репозитория на GitHub, ознакомление с условиями, скачивание всех необходимых ресурсов.
* 1 час - создание панельки которая рисуется сверху.
* 2 часа - создание панельки которая рисуется снизу. ну и некоторый рефакторинг слегка старого кода.
* 2.5 часа - создание canvas - найти подходящий себе алгоритм для сглаживания линии, сделать pencil и brush разными. 
* 1 час - добавление erase на canvas и небольшой рефакторинг по обновлению инструментов/цветов.
* 1 час - (даже меньше часа, ну ладно) добавление play и pause функций
* 2.5 часа - панель с показом текущих фреймов, с возможность изменить текущий фрейм и удалить/дублировать некий фрейм.
* 1 час - занимался какой-то ерундой - blur менял, и следил за памятью - сделал чистку фреймов которые сейчас не показываются.
