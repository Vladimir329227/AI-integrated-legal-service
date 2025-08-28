# Архитектура решения (Коммерческая документация)

## 1. Общая схема
- Клиенты: Web (React/TS), Desktop (VS Code Ext).
- API слой: FastAPI (Python 3.11+), JWT/OAuth2, WebSocket.
- Сервисы домена: Чат, Документы, Юристы, Платежи, AI-оркестратор.
- Хранилище: PostgreSQL 15 (OLTP + read replicas), объектное хранилище файлов (на старте — локально).
- Интеграции: ИИ-провайдеры (OpenAI/Claude/Yandex), платежи (Stripe/YooMoney), госуслуги.
- Асинхронность: BackgroundTasks (MVP), далее — очередь (Celery/SQS) и воркеры.

## 2. Компоненты сервера
- API Gateway/Edge: Nginx (+ TLS 1.3, rate limiting, security headers).
- Auth сервис: OAuth2/JWT, refresh-токены, RBAC/ABAC.
- Chat сервис: REST + WebSocket, хранение сообщений, статусы, стриминг.
- AI Orchestrator: выбор провайдера, RAG/кэш, ретраи, бенчмаркинг.
- Document сервис: загрузка, версия, метаданные, PII-маскирование (DLP).
- Lawyer сервис: очереди задач на проверку, SLA, отчётность.
- Payment сервис: биллинг, вебхуки, управление планами/лимитами.
- Admin/Backoffice: аудит, роли, конфигурации, отчеты.

## 3. Данные и БД
- PostgreSQL 15 (RDS):
  - users(id, email, password_hash, role, status, created_at, updated_at)
  - chats(id, user_id, title, type, status, created_at, updated_at)
  - messages(id, chat_id, sender, content, meta, created_at)
  - documents(id, user_id, title, path, status, pii_score, created_at)
  - lawyer_reviews(id, message_id|document_id, lawyer_id, status, notes, created_at)
  - plans(id, code, limits, price, features)
  - subscriptions(id, user_id, plan_id, status, period_start, period_end)
  - payments(id, user_id, amount, currency, provider, status, created_at)
  - ai_cache(id, prompt_hash, response, expires_at)
  - audit_logs(id, actor_id, action, target, meta, created_at)
- Индексы: GIN для полнотекстового поиска, btree по FK, partial для статусов.
- Репликации: 1..N read replicas под чтение/аналитику; PgBouncer для пула.

## 4. Безопасность и комплаенс
- Шифрование: TLS 1.3, AES-256 «в покое», KMS/Secrets Manager.
- DLP: обнаружение/маскирование PII до сохранения и перед вызовом ИИ.
- Доступ: RBAC/ABAC, минимизация прав, журналы аудита ≥ 1 года.
- Соответствие: 152-ФЗ, GDPR; политики инцидентов и уведомления.

## 5. Масштабирование и отказоустойчивость
- Горизонтальное масштабирование API, read replicas БД, LB при росте RPS.
- Очереди для долгих задач, идемпотентность, ретраи, circuit breaker.
- Наблюдаемость: метрики, трейсы, логи; алерты по SLO (латентность, ошибки).

## 6. API (основные ресурсы)

### Аутентификация
- POST /api/auth/register — регистрация
- POST /api/auth/login — логин, выдача JWT
- POST /api/auth/refresh — обновление access токена
- GET  /api/auth/me — профиль текущего пользователя

### Чаты и сообщения
- GET  /api/chats — список чатов
- POST /api/chats — создать чат
- GET  /api/chats/{chat_id} — получить чат
- DELETE /api/chats/{chat_id} — удалить/архивировать чат
- GET  /api/chats/{chat_id}/messages — сообщения чата
- POST /api/chats/{chat_id}/messages — отправить сообщение
- WS   /ws/chat/{chat_id} — WebSocket стриминг ответов

### Документы
- GET  /api/documents — список документов
- POST /api/documents — загрузка документа (multipart)
- GET  /api/documents/{document_id} — метаданные
- GET  /api/documents/{document_id}/download — скачать файл
- POST /api/documents/{document_id}/mask — маскирование PII

### Проверка юристом
- POST /api/reviews/messages/{message_id}/request — запрос проверки
- POST /api/reviews/documents/{document_id}/request — запрос проверки
- GET  /api/reviews/{review_id} — статус/результат

### Платежи и подписки
- GET  /api/plans — тарифы
- POST /api/subscriptions — оформить подписку/тариф
- GET  /api/subscriptions/me — моя подписка/лимиты
- POST /api/payments/webhook — вебхук платежного провайдера

### AI Orchestrator
- POST /api/ai/complete — генерация ответа (маршрутизация провайдера)
- POST /api/ai/search — RAG-поиск (если используется внешнее хранилище)

### Админ/Аудит
- GET  /api/admin/users — поиск пользователей (RBAC)
- GET  /api/admin/audit — логи действий

## 7. Потоки данных (вкратце)
- Сообщение в чат: клиент → API → AI Orchestrator → кэш (hit?) → провайдер ИИ → ответ → сохранение → стрим пользователю.
- Загрузка документа: клиент → API → DLP → хранилище → индексация/RAG → статус пользователю.
- Проверка юристом: запрос → очередь → воркер/юрист → результат → уведомление.

## 8. Эволюция (после MVP)
- Вынос кэша и очередей в Redis/SQS; отдельный векторный стор (pgvector/Qdrant).
- SSO/SAML/SCIM, расширенный аудит, отчётность и SLA.
- Версионирование API, контрактные тесты, ограничения скорости per-plan.
