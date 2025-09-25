# Додаток "Студент" / "Student" application
## English
A Master's thesis by a Computer Science student of Kamianets-Podіlskyi Ivan Ohiienko National University.
The "Student" software suite is a mobile application for the Android platform, created to digitize and simplify access to key academic documents. It answers to the challenge of managing paper-based records in education, a particularly relevant issue in the age of remote and hybrid learning.

This application provides the user (a student) with access to three services: an electronic individual studying schedule, an electronic student record book, and an electronic academic schedule.

### Technologies
Flutter (3.13.4) - A cross-platform application development framework by Google.
Dart (3.1.2) - An object-oriented programming language used in Flutter.
Firebase Cloud Firestore - A NoSQL, document-oriented cloud database. It provides a flexible data structure, real-time synchronization, and offline support.
Firebase Authentication - An authentication service from Firebase that ensures each user has access only to their own data.
Material Design - A design system by Google.
Android Studio - The integrated development environment (IDE).
**Libraries**
- "firebase_core" (2.16.0)
- "table_calendar" (3.0.9) - A calendar widget required for the "Academic Schedule" service.
- "intl" (0.18.1) - A library necessary for using the Ukrainian language in the application.

### Features
The application provides the user with access to three services within a single platform.

#### Electronic Individual Studying Schedule
This service allows students to create, edit, and manage their list of academic disciplines.
-   Ability to add new educational components (disciplines, internships, coursework) via a dialog box.
-   Automatic calculation of total hours, classroom hours, and ECTS credits.
-   Ability to sort disciplines alphabetically or by the number of hours (classroom, individual, total) for quick access.
-   Information about disciplines is presented in the form of interactive expandable tiles.

#### Electronic Record Book
A service for recording a student's academic achievements, serving as a digital analog to the traditional record book.
-   Centralized grade storage. All educational components created in the learning plan automatically appear here for further completion.
-   Discipline containers are color-coded based on the assessment type (red for exam, yellow for credit, green for other) for a better user experience.
-   Ability to group subjects by assessment type and sort them by date, name, or teacher.
-   When adding an exam or credit date, it can be automatically added as an event in the "Academic Schedule".

#### Electronic Academic Schedule
An interactive calendar for visualizing key dates and deadlines in the academic process.
-   All important dates (exams, credits, holidays, sessions (exam periods)) are displayed directly on the calendar.
-   Events are color-coded according to their type, allowing for quick navigation of the schedule.
-   Ability to create two types of entries: an "educational element" (a single-day event) and an "event" (a long-term event, such as a exam period or holiday).
-   Tapping on a specific date displays a list of all events scheduled for that day.

## Українська
Магістерстка дипломна робота студента спеціальності Комп'ютерні науки Кам'янець-Подільського національного університету імені Івана Огієнка. 
Програмний комплекс "Студент" - це повноцінний мобільний додаток для платформи Android, створений з метою цифровізації та спрощення доступу до ключових навчальних документів. Розробка є відповіддю на актуальну проблему обмеженого доступу до паперової документації в закладах вищої освіти, особливо в умовах дистанційного та змішаного навчання.

Цей додаток надає користувачу (студенту) доступ до трьох сервісів: електронного індивідуального навчального плану, електронної залікової книжки студента та електронного графіка освітнього процесу. 

### Технології
Flutter (3.13.4) - фреймворк від Google для свторення крос-платформених додатків.
Dart (3.1.2) - об'єктно-орієнтована мова програмування, що використовується у Flutter.
Firebase Cloud Firestore - NoSQL, документо-орієнтована хмарна база даних. Надає гнучку структуру даних, синхронізацію в реальному часі та офлайн-підтримку.
Firebase Authentication - Сервіс аутентифікації від Firebase, гарантує що кожен користувач має доступ лише до своїх даних. 
Material Design - система дизайну від Google.
Android Studio - середовище розробки.

**Бібліотеки**
- "firebase_core" (2.16.0)
- "table_calendar" (3.0.9) - Віджет-календар, необхідний для сервісу "Графік освітнього процесу".
- "intl" (0.18.1) - Бібліотека, необхідна для використання української мови в додатку.

### Функціонал
Застосунок надає користувачу доступ до трьох сервісів в рамках єдиної платформи.

#### Електронний Індивідуальний навчальний план
Цей сервіс дозволяє студентам створювати, редагувати та керувати переліком своїх навчальних дисциплін.
-   Додавання нових освітніх компонентів (дисципліни, практики, курсові роботи) через діалогове вікно.
-   Автоматичний підрахунок загальної кількості годин, аудиторних годин та кредитів ЄКТС.
-   Можливість сортувати дисципліни за алфавітом, кількістю годин (аудиторних, індивідуальних, загальних) для швидкого доступу.
-   Інформація про дисципліни представлена у вигляді інтерактивних згортаних плиток (tiles).

#### Електронна Залікова книжка
Сервіс для фіксації академічних досягнень студента, що є цифровим аналогом традиційної залікової книжки.
-   Централізоване зберігання оцінок. Усі освітні компоненти, створені в навчальному плані, автоматично з'являються тут для подальшого заповнення.
-  Контейнери з дисциплінами мають різний колір рамки залежно від форми контролю (червоний — екзамен, жовтий — залік, зелений — інше) для кращого користувацького досвіду.
-   Можливість групувати предмети за формою контролю та сортувати за датою, назвою або викладачем.
-   При додаванні дати складання іспиту чи заліку, її можна автоматично додати як подію в "Графік освітнього процесу".

#### Електронний Графік освітнього процесу
Інтерактивний календар для візуалізації ключових дат та термінів навчального процесу.
-   Усі важливі дати (екзамени, заліки, канікули, сесії) відображаються безпосередньо на календарі.
-   Події маркуються різними кольорами залежно від їх типу, що дозволяє швидко орієнтуватися в графіку.
-   Можливість створювати два типи записів: "освітній елемент" (одноденна подія) та "подія" (тривала в часі, наприклад, сесія або канікули).
-   При натисканні на конкретну дату відображається список усіх подій, запланованих на цей день.
