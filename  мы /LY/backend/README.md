# LY Backend API

REST API backend для iOS приложения LY - системы управления программами лояльности с интеграцией Apple Wallet.

## 🚀 Быстрый старт

### Установка зависимостей
```bash
cd backend
npm install
```

### Настройка окружения
```bash
cp .env.example .env
# Отредактируйте .env файл с вашими настройками
```

### Настройка базы данных PostgreSQL
```bash
# Создайте базу данных
createdb ly_loyalty

# Выполните миграции
npm run db:migrate
```

### Запуск сервера
```bash
# Development режим
npm run dev

# Production режим
npm start
```

Сервер будет доступен по адресу: `http://localhost:3000`

## 📚 API Документация

### Base URL
```
http://localhost:3000/api/v1
```

### Эндпоинты

#### Компании
- `GET /companies` - Получить все компании
- `GET /companies/:id` - Получить компанию по ID
- `POST /companies` - Создать новую компанию
- `PUT /companies/:id` - Обновить компанию
- `DELETE /companies/:id` - Удалить компанию

#### Программы лояльности
- `GET /loyalty-programs` - Получить все программы
- `GET /loyalty-programs/:id` - Получить программу по ID
- `POST /loyalty-programs` - Создать новую программу
- `PUT /loyalty-programs/:id` - Обновить программу
- `DELETE /loyalty-programs/:id` - Удалить программу

#### Пользователи
- `GET /users` - Получить всех пользователей
- `GET /users/:id` - Получить пользователя по ID
- `POST /users` - Создать нового пользователя
- `PUT /users/:id` - Обновить пользователя
- `GET /users/:id/points` - Получить баланс баллов
- `POST /users/:id/points/add` - Начислить баллы
- `POST /users/:id/points/redeem` - Списать баллы
- `DELETE /users/:id` - Удалить пользователя

#### Apple Wallet пассы
- `GET /passes` - Получить все пассы
- `GET /passes/:id` - Получить пасс по ID
- `POST /passes` - Создать новый пасс
- `PUT /passes/:id` - Обновить пасс
- `GET /passes/:id/download` - Скачать .pkpass файл
- `DELETE /passes/:id` - Удалить пасс

#### Аналитика
- `GET /analytics/dashboard` - Общая аналитика
- `GET /analytics/company/:id` - Аналитика компании
- `GET /analytics/loyalty-program/:id` - Аналитика программы лояльности

## 📋 Примеры использования

### Создание компании
```bash
curl -X POST http://localhost:3000/api/v1/companies \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Coffee Shop",
    "adminEmail": "admin@coffeeshop.com",
    "logo": "https://example.com/logo.png"
  }'
```

### Создание пользователя
```bash
curl -X POST http://localhost:3000/api/v1/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Иван Иванов",
    "email": "ivan@example.com",
    "phone": "+7123456789",
    "birthday": "1990-01-01",
    "loyaltyProgramId": "program-uuid"
  }'
```

### Начисление баллов
```bash
curl -X POST http://localhost:3000/api/v1/users/{user-id}/points/add \
  -H "Content-Type: application/json" \
  -d '{
    "points": 100,
    "description": "Покупка кофе"
  }'
```

## 🗄️ Структура базы данных

### Основные таблицы:
- **companies** - Компании
- **loyalty_programs** - Программы лояльности
- **users** - Пользователи
- **loyalty_program_users** - Связь пользователей с программами
- **wallet_passes** - Apple Wallet пассы

## ⚙️ Переменные окружения

```env
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ly_loyalty
DB_USER=postgres
DB_PASSWORD=password

# Server
PORT=3000
NODE_ENV=development

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d

# API
API_BASE_URL=http://localhost:3000
MAX_FILE_SIZE=5242880
UPLOAD_DIR=uploads

# PassKit
PASS_TYPE_IDENTIFIER=pass.com.ly.loyalty
TEAM_IDENTIFIER=your-team-id
CERTIFICATE_PATH=./certificates/
```

## 🔒 Безопасность

- Rate limiting (100 запросов в 15 минут)
- Helmet.js для безопасности заголовков
- Валидация данных с помощью Joi
- CORS защита
- Защита от SQL инъекций через параметризованные запросы

## 🧪 Тестирование

```bash
npm test
```

## 📦 Технологический стек

- **Node.js** - Runtime
- **Express.js** - Web framework
- **PostgreSQL** - База данных
- **Knex.js** - Query builder
- **Joi** - Валидация данных
- **Multer** - Загрузка файлов
- **Helmet** - Безопасность
- **Morgan** - Логирование

## 🔄 Интеграция с iOS приложением

Backend полностью совместим с существующим iOS приложением LY. Основные возможности:

1. **Синхронизация данных** между устройствами
2. **Облачное хранение** компаний и программ лояльности
3. **Централизованное управление** пользователями и баллами
4. **API для генерации** Apple Wallet пассов
5. **Аналитика и отчеты** в реальном времени

## 📈 Следующие шаги

1. Настройка Apple PassKit сертификатов
2. Реализация генерации .pkpass файлов
3. Добавление push-уведомлений
4. Интеграция с платежными системами
5. Добавление аутентификации и авторизации