# YandexCup 2024 Live Image

Данная задача делалась для Yandex Cup 2024 года в направлении iOS в полуфинале.

На написание задачи давалась одна неделя. Сколько ушло в часах на данный код написан в конце.
Также в конце написано, где, что находиться, так-как для доп. функционала не было нарисовано расположение.

## Демо


![<img src="https://github.com/user-attachments/assets/828a52fb-7840-460b-8615-4b61e933bb38" width="300"/>](https://youtu.be/8fm-itiAQJM)

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
- [x] Генерация и добавление N случайных кадров. Содержание холстов отдаётся на усмотрение участников — к примеру, это может быть генерация различных геометрических фигур или перемещение одной готовой фигуры. Изображения на сгенерированных кадрах должны явно отличаться друг от друга. Количество кадров должно задаваться вводом числа N с размерностью Integer в интерфейсе приложения непосредственно перед генерацией. Сгенерированные кадры добавляются за последним кадром и ведут себя идентично кадрам, добавленным вручную: допускается удаление кадров, изменение последнего кадра и т. д.
- [x] Панель либо экран с раскадровкой для переключения между добавленными кадрами. Также допускается реализовать переключение кадров свайпами влево и вправо от края экрана.
- [x] Кнопка дублирования кадра — создаёт новый кадр и копирует на него всё содержимое текущего кадра.
- [x] Возможность удаления всех кадров сразу.
- [x] Настройка скорости воспроизведения анимации.
- [x] Экспорт анимации в GIF с возможностью поделиться файлом.
- [x] Выбор кастомного любого цвета рисования из RGB-палитры.
- [x] Инструмент рисования геометрических фигур, прямых линий или кривых Безье (минимум 3 разных фигур)
- [ ] Взаимодействие с фигурами: увеличение растягиванием или pinch to zoom, перемещение, поворот.
- [x] Изменение толщины карандаша и ластика.
- [x] Реализация стека действий для многократной отмены или возврата.
- [ ] Увеличение холста при помощи жеста pinch-to-zoom для точной прорисовки деталей изображения.
- [x] Иконка приложения.
- [ ] Полноценная поддержка светлой и тёмной тем.


## Мои комментарии
В целом задача не сложная. При реализации старался отбросить все лишние конструкции и усложнения в архитектуре, дабы не заграмождать код лишним - расширять, и поддерживать данный код в любом случае не планируется.

Так-как по условию задачи нельзя использовать сторонние библиотеки (за некоторым исключением), то и свои библиотеки, и наработки, я не использовал в коде - ни сложных логгеров, ни DI контейнеров, ни других внутренних наработок.

## Расположение и возможности фич
### Верхняя панель
* undo (по дизайну) - для текущего кадра поддерживает стек до 32 операций. Для всех остальных кадров остаеться в памяти только 2 операции.
* redo (по дизайну) - работает как и у всех приложений.
* remove (по дизайну + long touch) - можно удалить как текущий кадр, так и все кадры. Кнопка активно если кадров больше 1.
* add (по дизайну + long touch) - можно добавить пустой фрейм, можно задублировать текущий фрейм, можно начать генерацию кадров.
   При дублировании у нового кадра сохраняется история текущего.
* layers (по дизайну) - показывает/скрывает панель с кадрами.
* pause (по дизайну) - активна, только если нажали play.
* play (по зиайну + long touch) - по нажатию начинает анимацию с обычной скорость. По long touch можно выбрать с какой скоростью начать анимацию.

### Canvas
Можно на нем рисовать/стирать. Кисточка от карандаша отличаются тем, что у кисточки есть размытие.
Рисование фигур есть, но в простом виде - да их можно нарисовать любого размера, но сделать после какое-либо действие с фигурой нельзя.

#### А где изменение фигур?
В целом при текущей реализации, последнюю нарисованную фигуру я всегда знаю, и могу с ней делать все что угодно. Даже в целом так-как есть генерация картинок, все эти возможности вытащены - бери и меняй.
Но тут уже сыграла лень, и то что этот пункт находиться в конце списка.

### Нижняя панель
* share (левый угол) - по нажатию создается gif файл, и предлагается стандартная панель для его шаринга.
* pencil (по дизайну) - выбрать карандаш.
* brush (по дизайну) - выбрать кисть.
* erase (по дизайну) - выбрать ластик. Размер ластика по умолчанию в два раза больше чем кисти и карандаша.
* instruments (по дизайну) - пока не поддержано.
* color (по дизайну) - по нажатию предлагаю панель с выбором цвета. Внутри себя показывает текущий выбранный цвет.

### Выбор цвета
Вначале появляется панель с дефолтными цвета, позже цвета меняются на последние используемые.
По нажатию на палитру, показывается стандартные системный выбор цветов.

### Панель кадров
Открываеться по нажатию на кнопку layers.

На панели вначале идут все текущие кадры. У каждого кадра есть кнопка удалить и дублировать, что позволяет удалять и дублировать не только текущий кадр, но и любой в списке.

Потом идет кнопка добавления нового кадра.

После идет кнопка генерации кадров - с анимированным кубиком :)

### Изменение толщины
Изменение толщины линии можно сделать с помощью ползунка расположенного слева, ближе к низу. Размер меняеться от 1 до 20.
Из важного - размер сохраняется по инструментам: у карандаша, кисточки, ластика, и фигур(объединены в один) размер сохраняется последний установленный для этого инструмента.

### Генерация кадров
Вначале предлагается выбрать сколько кадров сгенерировать.

После выбора количества кадров, происходит сама генерация. На 1_000_000 кадрах около секунды/двух.
А вот 10_000_000 кадров уже не сгенерируется - памяти не хватит... Вроде и храниться на каждый кадр только параметры фигуры 113байт... Но по итогу это 1гиг

Генерация может в теории происходить по разным алгоритмам, но пока поддержан только один:
Cоздаеться случайная фигура (ага какже - или круг или квадрат или треугольник случайного размера :D), и потом случайным образом перемещается, поворачивается, изменяет размер по всему экрану. Чтобы при генерации большого количества кадров было не скучно, то раз в некоторое количество кадров, параметры обновляются, и фигура продолжает движение, но уже по другому.

## Время
* 1.5 часа - подготовка. Написание README, создание базового проекта, репозитория на GitHub, ознакомление с условиями, скачивание всех необходимых ресурсов.
* 1 час - создание панельки которая рисуется сверху.
* 2 часа - создание панельки которая рисуется снизу. ну и некоторый рефакторинг слегка старого кода.
* 2.5 часа - создание canvas - найти подходящий себе алгоритм для сглаживания линии, сделать pencil и brush разными. 
* 1 час - добавление erase на canvas и небольшой рефакторинг по обновлению инструментов/цветов.
* 1 час - (даже меньше часа, ну ладно) добавление play и pause функций
* 2.5 часа - панель с показом текущих фреймов, с возможность изменить текущий фрейм и удалить/дублировать некий фрейм.
* 1 час - занимался какой-то ерундой - blur менял, и следил за памятью - сделал чистку фреймов которые сейчас не показываются.
* 0.5 часа - добавил кнопку Add и Generate в список фреймов. Ну и небольшой рефакторинг в этом месте.
* 1.5 часа - написал первый алгоритм генерации случайных кадров.
* 2 часа - улучшение алгоритма генерации. Оптимизация хранения для того чтобы выдерживать 100000 кадров на телефоне. 
* 0.5 часа - поддержка мини фишек - удаление всех кадров, или изменение скорости воспроизведения.
* 2 часа - добавил кнопку share и сделал сохранение в gif файл. Также обновил README - добавил описание.
* 1 часа - добавление возможности выбора любого цвета. И выбор цветов теперь показывает последние выбираемые цвета.
* 1 час - добавление в простом виде фигур - прямоугольник, круг(не овал), треугольник, стрелочка, без возможности изменять, после окончания отрисовки.

Итого: 21 часов

И тут Остапа понесло :D я вдруг понял, что я сделал сильно наивное решение - да оно работает, и скорей пройдет в финал (если судить по квалификации), но можно сделать же оптимальнее - так, как я хотел изначально, но решил, что зачем усложнять?
сейчас понял, что наверное стоит усложнить, и переделать хранение кадра.
* 2 часа - добавление Painter-ов и завязка его пока на старый рекорд. Да и сам он не оптимизирован.
* 2 часа - перевести весь код (Record-ы) на новую модель, чтобы она занимала меньше памяти.
* 1.5 час - просто тестировал, и исправлял мини косяки которые в ходе рефакторинга возникли. А также у фигур изменил фреймы - теперь фигура всегда вписано в свой фрейм, а не просто он на весь экран.
* 1.5 час - думал уже не найду время, но нет. Добавил изменение толщины, с сохранением по разным инструментам своего значения.

Итого: 21 + 7 = 28 часов
