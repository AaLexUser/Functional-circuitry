# Функциональная схемотехника
Дисциплина направлена на приобретение компетенций проектирования цифровых вычислительных устройств на уровне базовых элементов (логики, триггеров и т.п.), а также на уровне регистровых передач (RTL) и микроархитектуры (структурно-функциональный уровень) с использованием языков описания аппаратуры (Verilog HDL, System Verilog). Развиваются такие компетенции, как проектирование, разработка, верификация, реализация на ПЛИС аппаратных цифровых вычислительных элементов, блоков и ядер.
### Содержание дисциплины
1.  Основы функциональной схемотехники, сигналы и элементы цифровых схем

    1.1  Определение предметной области. Определение основных понятий в области цифровой схемотехники: цифровые сигналы, цепи, способы кодирования цифровых данных, функциональные элементы и блоки, компоненты цифровых схем. Позитивная и негативная логика. Основные параметры цифровых сигналов. Типы цифровых ИМС (ТТЛ, КМОП), их параметры и схемотехника. Синхронные и асинхронные функциональные блоки. Комбинационные и последовательностные схемы.

    1.2 Определение цифрового порта. Входные, выходные, двунаправленные порты. Порты с высокоомным состоянием. Схемотехника, электрические и динамические параметры портов различных типов. Совместимость портов КМОП и ТТЛ. Организация шин.

    1.3 Принцип функционального проектирования цифровых схем. Блочное и крупноблочное проектирование. Специализированные микросхемы и системы на кристалле.

    1.4 Функциональные элементы КМОП вентильного уровня, устройство и функционирование элементов И, ИЛИ, НЕ, И-НЕ, ИЛИ-НЕ.

    1.5 Триггеры. Назначение и варианты применения триггеров. Типы триггеров. Синхронные и асинхронные триггеры. Условное обозначение, схема и функционирование синхронного и асинхронного RS-триггера, синхронного D-триггера. Обозначение и функционирование T-триггеров, JK-триггеров. MS-триггеры.

2. Базовые операционные элементы

    2.1 Логический (вентильный) и операционный (функциональный) уровни описания цифровых устройств. Элементы операционного уровня (слова данных, операционные элементы и блоки). Базовые (основные) операционные элементы комбинационного типа: шифраторы/дешифраторы, мультиплексоры/демультиплексоры, сумматоры/вычитатели, блоки свертки, схемы кодирования. Примеры проектирования специализированных операционных элементов.

    2.2 Основные типы и классификация операционных элементов последовательностного типа. Регистры: накопительные, накопительные регистры-защелки, сдвиговые – условные обозначения, схема и функционирование. Счетчики: асинхронные/синхронные, двоичные/двоично-десятичные, с произвольным модулем счета, реверсивные, с последовательным/параллельным переносом. Схемы на базе счетчиков: делители частоты, таймеры, генераторы сигналов ШИМ

3. Основы проектирования цифровых ИМС

    3.1. Основные стадии и технологии проектирования ИМС. Методы верификации и тестирования ИМС. Основы современной технологии производства ИМС

    3.2. Основы технологии проектирования схем на ПЛИС. Применение ПЛИС при разработке ИСМ. Основные типы ПЛИС. Структура, функциональные блоки, параметры ПЛИС типа FPGA. Технология разработки цифровых схем на ПЛИС. Инструментальные средства разработки на ПЛИС

    3.3. Структура описания цифровой схемы на языках HDL. Базовые элементы HDL-описаний: модули, интерфейсы, элементы, процессы, цепи/сигналы, регистры. Функциональные и структурные языковые описания. Модель симуляции HDL-описаний. Модель тестирования HDL-описаний. Синтез схем из HDL-описаний. Инструментальные средства HDL-проектирования. Сравнение схемных и языковых методов описания и проектирования цифровых систем

    3.4. Основы проектирования на языке Veriliog HDL. Основные языковые конструкции Veriliog HDL. Методы формальной и функциональной верификации в Veriliog HDL. Применение языка System Verilog для описания схем на системном уровне.
### Лабораторные работы охватывают следующие темы:
    Лабораторная работа №1 «Введение в проектирование цифровых интегральных схем».

    Лабораторная работа №2 «Разработка аппаратных ускорителей математических вычислений».

    Лабораторная работа №3 «Проектирование цифровых схем с использованием ПЛИС».

    Лабораторная работа №4 «Проектирование встроенных схем самотестирования».

    