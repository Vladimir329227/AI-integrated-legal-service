# UML Диаграммы последовательности - Юридический сервис с ИИ

## 1. Сценарий: Чат с ИИ и запрос проверки юристом

```mermaid
sequenceDiagram
    participant U as Пользователь
    participant F as Frontend
    participant API as API Gateway
    participant CS as ChatService
    participant AI as AIService
    participant AS as AIProvider
    participant DB as Database
    participant LS as LawyerService
    participant L as Lawyer
    participant NS as NotificationService

    U->>F: Отправляет сообщение в чат
    F->>API: POST /api/chats/{chat_id}/messages
    API->>CS: addMessage(chat_id, user_id, content)
    CS->>DB: Сохраняет сообщение пользователя
    CS->>AI: generateResponse(prompt, context)
    AI->>AS: getResponse(prompt)
    AS-->>AI: Возвращает ответ ИИ
    AI->>DB: Сохраняет AIRequest
    AI-->>CS: Возвращает ответ ИИ
    CS->>DB: Сохраняет сообщение ИИ
    CS-->>API: Возвращает ответ
    API-->>F: Возвращает сообщения
    F-->>U: Отображает ответ ИИ

    U->>F: Нажимает "Проверить у юриста"
    F->>API: POST /api/chats/{chat_id}/lawyer-review
    API->>CS: requestLawyerReview(chat_id, message_id)
    CS->>LS: assignLawyerToReview(review_id)
    LS->>DB: Создает LawyerReview
    LS->>NS: notifyLawyer(lawyer_id, review_id)
    NS->>L: Отправляет уведомление юристу
    LS-->>CS: Возвращает статус
    CS-->>API: Возвращает статус
    API-->>F: Возвращает подтверждение
    F-->>U: Показывает "Ожидание ответа юриста"

    L->>API: Просматривает задачу
    API->>LS: getLawyerReviews(lawyer_id)
    LS->>DB: Получает список задач
    LS-->>API: Возвращает задачи
    API-->>L: Показывает задачи

    L->>API: Отправляет ответ юриста
    API->>LS: updateReview(review_id, comment, is_correct)
    LS->>DB: Обновляет LawyerReview
    LS->>NS: notifyUser(user_id, review_id)
    NS->>U: Отправляет уведомление пользователю
    LS-->>API: Возвращает статус
    API-->>L: Подтверждает отправку
    L-->>U: Показывает "Ответ отправлен"
```

## 2. Сценарий: Загрузка и обработка документа

```mermaid
sequenceDiagram
    participant U as Пользователь
    participant F as Frontend
    participant API as API Gateway
    participant DS as DocumentService
    participant AI as AIService
    participant DB as Database
    participant BT as BackgroundTasks

    U->>F: Загружает документ
    F->>API: POST /api/documents/upload
    API->>DS: uploadFile(user_id, file)
    DS->>DB: Создает Document (status: UPLOADING)
    DS->>DB: Сохраняет файл в PostgreSQL
    DS-->>API: Возвращает document_id
    API-->>F: Возвращает document_id
    F-->>U: Показывает "Документ загружается"

    API->>BT: Добавляет задачу на обработку
    BT->>DS: processDocument(document_id)
    DS->>DB: Обновляет статус (PROCESSING)
    DS->>AI: extractText(document_id)
    AI->>DB: Читает файл из PostgreSQL
    AI-->>DS: Возвращает извлеченный текст
    DS->>DB: Сохраняет извлеченный текст
    DS->>AI: maskPersonalData(text)
    AI-->>DS: Возвращает замаскированный текст
    DS->>DB: Создает DocumentAnnotation
    DS->>DB: Обновляет статус (PROCESSED)
    DS->>F: Уведомляет о готовности документа
    F-->>U: Показывает "Документ обработан"
```

## 3. Сценарий: Аутентификация и создание чата

```mermaid
sequenceDiagram
    participant U as Пользователь
    participant F as Frontend
    participant API as API Gateway
    participant AS as AuthService
    participant CS as ChatService
    participant DB as Database
    participant WS as WebSocket

    U->>F: Вводит логин/пароль
    F->>API: POST /api/auth/login
    API->>AS: authenticateUser(credentials)
    AS->>DB: Проверяет пользователя
    DB-->>AS: Возвращает пользователя
    AS->>AS: generateTokens(user)
    AS-->>API: Возвращает access_token, refresh_token
    API-->>F: Возвращает токены
    F->>F: Сохраняет токены
    F-->>U: Перенаправляет в приложение

    U->>F: Создает новый чат
    F->>API: POST /api/chats (с токеном)
    API->>AS: validateToken(token)
    AS-->>API: Возвращает user_id
    API->>CS: createChat(user_id, AI_CHAT)
    CS->>DB: Создает Chat
    CS->>WS: Подключает к WebSocket
    CS-->>API: Возвращает chat_id
    API-->>F: Возвращает chat_id
    F-->>U: Открывает новый чат
```

## 4. Сценарий: Платеж и подписка

```mermaid
sequenceDiagram
    participant U as Пользователь
    participant F as Frontend
    participant API as API Gateway
    participant PS as PaymentService
    participant PP as PaymentProvider
    participant DB as Database
    participant NS as NotificationService

    U->>F: Выбирает услугу (проверка юристом)
    F->>API: POST /api/payments/create
    API->>PS: createPayment(user_id, LAWYER_REVIEW, amount)
    PS->>DB: Создает Payment (PENDING)
    PS->>PP: createPaymentIntent(amount, currency)
    PP-->>PS: Возвращает payment_intent
    PS-->>API: Возвращает payment_data
    API-->>F: Возвращает данные для оплаты
    F-->>U: Показывает форму оплаты

    U->>F: Вводит данные карты
    F->>PP: Подтверждает платеж
    PP-->>F: Возвращает результат
    F->>API: POST /api/payments/{payment_id}/confirm
    API->>PS: processPayment(payment_id)
    PS->>PP: confirmPayment(payment_intent)
    PP-->>PS: Возвращает статус COMPLETED
    PS->>DB: Обновляет статус платежа
    PS->>NS: notifyPaymentSuccess(user_id, payment_id)
    NS->>U: Отправляет уведомление
    PS-->>API: Возвращает статус
    API-->>F: Возвращает подтверждение
    F-->>U: Показывает "Оплата прошла успешно"
```

## 5. Сценарий: Корпоративная работа с документами (Фаза 3)

```mermaid
sequenceDiagram
    participant CA as Corporate Admin
    participant CU as Corporate User
    participant F as Frontend
    participant API as API Gateway
    participant DS as DocumentService
    participant AS as AuthService
    participant DB as Database
    participant NS as NotificationService

    CA->>F: Создает корпоративную учетную запись
    F->>API: POST /api/corporate/accounts
    API->>AS: createCorporateAccount(company_data)
    AS->>DB: Создает CorporateAccount
    AS->>DB: Создает пользователя с ролью CORPORATE_ADMIN
    AS-->>API: Возвращает account_id
    API-->>F: Возвращает account_id
    F-->>CA: Показывает "Аккаунт создан"

    CA->>F: Приглашает пользователей
    F->>API: POST /api/corporate/{account_id}/invite
    API->>AS: inviteUser(account_id, email, role)
    AS->>NS: sendInvitation(email, invitation_link)
    NS->>CU: Отправляет приглашение
    AS-->>API: Возвращает статус
    API-->>F: Возвращает статус
    F-->>CA: Показывает "Приглашение отправлено"

    CU->>F: Принимает приглашение
    F->>API: POST /api/corporate/join
    API->>AS: joinCorporateAccount(invitation_token)
    AS->>DB: Обновляет пользователя (роль: CORPORATE_USER)
    AS->>NS: notifyAdmin(admin_id, user_joined)
    NS->>CA: Уведомляет о новом пользователе
    AS-->>API: Возвращает статус
    API-->>F: Возвращает статус
    F-->>CU: Показывает "Вы присоединились к компании"

    CU->>F: Загружает документ в общее пространство
    F->>API: POST /api/corporate/{account_id}/documents
    API->>DS: uploadCorporateDocument(account_id, user_id, file)
    DS->>DB: Создает Document с доступом для компании
    DS->>NS: notifyTeamMembers(account_id, document_uploaded)
    NS->>CA: Уведомляет о новом документе
    DS-->>API: Возвращает document_id
    API-->>F: Возвращает document_id
    F-->>CU: Показывает "Документ загружен в общее пространство"
```

## 6. Сценарий: Интеграция с гос. услугами (Фаза 2)

```mermaid
sequenceDiagram
    participant U as Пользователь
    participant F as Frontend
    participant API as API Gateway
    participant GS as GovService
    participant AI as AIService
    participant DB as Database
    participant NS as NotificationService

    U->>F: Выбирает гос. услугу
    F->>API: GET /api/gov-services/available
    API->>GS: getAvailableServices()
    GS-->>API: Возвращает список услуг
    API-->>F: Возвращает список
    F-->>U: Показывает доступные услуги

    U->>F: Выбирает "Проверка ИНН"
    F->>API: POST /api/gov-services/check-inn
    API->>GS: checkINN(inn_number)
    GS->>GS: Подключается к API ФНС
    GS-->>API: Возвращает результат проверки
    API->>AI: analyzeGovResponse(result)
    AI-->>API: Возвращает анализ
    API->>DB: Сохраняет результат
    API-->>F: Возвращает результат и анализ
    F-->>U: Показывает результат проверки

    U->>F: Запрашивает помощь с заполнением формы
    F->>API: POST /api/gov-services/help-with-form
    API->>GS: getFormRequirements(service_type)
    GS-->>API: Возвращает требования
    API->>AI: generateFormHelp(requirements, user_data)
    AI-->>API: Возвращает помощь по заполнению
    API-->>F: Возвращает помощь
    F-->>U: Показывает инструкции по заполнению
```

## Приоритеты реализации

### Фаза 1 (MVP) - 6-8 месяцев
- ✅ Сценарий 1: Чат с ИИ и запрос проверки юристом (веб-интерфейс)
- ✅ Сценарий 3: Аутентификация и создание чата (веб-интерфейс)
- ✅ Сценарий 2: Загрузка и обработка документа (базовая версия, веб-интерфейс)

### Фаза 2 - 4-5 месяцев
- 🔄 Десктопное приложение (VS Code Extension)
- 🔄 Сценарий 4: Платеж и подписка
- 🔄 Сценарий 6: Интеграция с гос. услугами
- 🔄 Расширенная обработка документов

### Фаза 3 - 3-4 месяца
- ⏳ Сценарий 5: Корпоративная работа с документами
- ⏳ Расширенная система ролей и доступа
- ⏳ Командная работа с документами
