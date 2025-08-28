# UML Диаграмма компонентов - Юридический сервис с ИИ

## Диаграмма компонентов системы

```mermaid
graph TB
    subgraph "Frontend Applications"
        WebApp[Веб-приложение<br/>React + TypeScript<br/>Port: 3000]
    end

    subgraph "API Gateway & Load Balancer"
        Nginx[Nginx<br/>Load Balancer<br/>Port: 80/443]
        API[FastAPI Gateway<br/>Port: 8000]
    end

    subgraph "Authentication & Authorization"
        AuthService[Auth Service<br/>JWT + OAuth2<br/>Port: 8001]
        RBACService[RBAC Service<br/>Role Management<br/>Port: 8002]
    end

    subgraph "Core Business Services"
        ChatService[Chat Service<br/>WebSocket<br/>Port: 8003]
        AIService[AI Service<br/>OpenAI/Claude/Yandex<br/>Port: 8004]
        DocumentService[Document Service<br/>File Processing<br/>Port: 8005]
        LawyerService[Lawyer Service<br/>Task Management<br/>Port: 8006]
        PaymentService[Payment Service<br/>Stripe/YooMoney<br/>Port: 8007]
        NotificationService[Notification Service<br/>Email/SMS/Push<br/>Port: 8008]
    end

    subgraph "Data Storage"
        PostgreSQL[(PostgreSQL<br/>Primary Database + Cache<br/>Port: 5432)]
    end

    subgraph "External Services"
        OpenAI[OpenAI API<br/>GPT-4/GPT-3.5]
        Claude[Claude API<br/>Anthropic]
        YandexGPT[Yandex GPT<br/>Yandex Cloud]
        Stripe[Stripe API<br/>Payments]
        YooMoney[YooMoney API<br/>Payments]
        GovAPI[Government APIs<br/>ФНС, ГИБДД, etc.]
    end

    subgraph "Background Processing"
        BackgroundTasks[Background Tasks<br/>FastAPI BackgroundTasks<br/>Port: 8009]
    end

    %% Frontend connections
    WebApp --> Nginx

    %% API Gateway connections
    Nginx --> API
    API --> AuthService
    API --> RBACService

    %% Service connections
    API --> ChatService
    API --> AIService
    API --> DocumentService
    API --> LawyerService
    API --> PaymentService
    API --> NotificationService

    %% Database connections
    AuthService --> PostgreSQL
    RBACService --> PostgreSQL
    ChatService --> PostgreSQL
    AIService --> PostgreSQL
    DocumentService --> PostgreSQL
    LawyerService --> PostgreSQL
    PaymentService --> PostgreSQL
    NotificationService --> PostgreSQL

    %% External service connections
    AIService --> OpenAI
    AIService --> Claude
    AIService --> YandexGPT
    PaymentService --> Stripe
    PaymentService --> YooMoney
    DocumentService --> GovAPI

    %% Background processing
    BackgroundTasks --> PostgreSQL
```

## Детальная диаграмма компонентов (Фаза 1 - MVP)

```mermaid
graph TB
    subgraph "Frontend Layer"
        WebUI[Веб-интерфейс<br/>React + TypeScript]
        ChatUI[Чат компонент<br/>Socket.io client]
        AuthUI[Аутентификация<br/>JWT handling]
        DocumentUI[Документы<br/>File upload/download]
    end

    subgraph "API Layer"
        AuthAPI[Auth API<br/>POST /auth/*]
        ChatAPI[Chat API<br/>GET/POST /chats/*]
        AIAPI[AI API<br/>POST /ai/*]
        DocumentAPI[Document API<br/>POST /documents/*]
    end

    subgraph "Service Layer"
        AuthService[Auth Service<br/>User management]
        ChatService[Chat Service<br/>Message handling]
        AIService[AI Service<br/>LLM integration]
        DocumentService[Document Service<br/>File processing]
    end

    subgraph "Data Layer"
        UserDB[(Users<br/>PostgreSQL)]
        ChatDB[(Chats & Messages<br/>PostgreSQL)]
        FileDB[(Files<br/>PostgreSQL)]
        CacheDB[(Cache<br/>PostgreSQL)]
    end

    subgraph "External APIs"
        LLMProvider[LLM Provider<br/>OpenAI/Claude]
    end

    %% Frontend connections
    WebUI --> AuthUI
    WebUI --> ChatUI
    WebUI --> DocumentUI

    %% API connections
    AuthUI --> AuthAPI
    ChatUI --> ChatAPI
    DocumentUI --> DocumentAPI
    ChatUI --> AIAPI

    %% Service connections
    AuthAPI --> AuthService
    ChatAPI --> ChatService
    AIAPI --> AIService
    DocumentAPI --> DocumentService

    %% Database connections
    AuthService --> UserDB
    ChatService --> ChatDB
    ChatService --> CacheDB
    AIService --> CacheDB
    DocumentService --> FileDB
    DocumentService --> ChatDB

    %% External connections
    AIService --> LLMProvider
```

## Диаграмма компонентов (Фаза 2 - Расширенный функционал)

```mermaid
graph TB
    subgraph "Frontend Layer"
        WebUI[Веб-интерфейс<br/>React + TypeScript]
        DesktopApp[Десктопное приложение<br/>VS Code Extension]
        ChatUI[Чат компонент<br/>Socket.io client]
        DocumentUI[Документы<br/>File upload/download]
        PaymentUI[Платежи<br/>Stripe integration]
        GovUI[Гос. услуги<br/>API integration]
    end

    subgraph "API Layer"
        AuthAPI[Auth API<br/>POST /auth/*]
        ChatAPI[Chat API<br/>GET/POST /chats/*]
        AIAPI[AI API<br/>POST /ai/*]
        DocumentAPI[Document API<br/>POST /documents/*]
        PaymentAPI[Payment API<br/>POST /payments/*]
        GovAPI[Gov API<br/>GET/POST /gov/*]
        LawyerAPI[Lawyer API<br/>GET/POST /lawyers/*]
    end

    subgraph "Service Layer"
        AuthService[Auth Service<br/>User management]
        ChatService[Chat Service<br/>Message handling]
        AIService[AI Service<br/>LLM integration]
        DocumentService[Document Service<br/>File processing]
        PaymentService[Payment Service<br/>Stripe/YooMoney]
        GovService[Gov Service<br/>Government APIs]
        LawyerService[Lawyer Service<br/>Review management]
        NotificationService[Notification Service<br/>Email/SMS]
    end

    subgraph "Data Layer"
        UserDB[(Users<br/>PostgreSQL)]
        ChatDB[(Chats & Messages<br/>PostgreSQL)]
        PaymentDB[(Payments<br/>PostgreSQL)]
        FileDB[(Files<br/>PostgreSQL)]
        CacheDB[(Cache<br/>PostgreSQL)]
        QueueDB[(Task Queue<br/>PostgreSQL)]
    end

    subgraph "External APIs"
        LLMProvider[LLM Provider<br/>OpenAI/Claude]
        PaymentProvider[Payment Provider<br/>Stripe/YooMoney]
        GovProvider[Government APIs<br/>ФНС, ГИБДД]
    end

    %% Frontend connections
    WebUI --> PaymentUI
    WebUI --> GovUI

    %% API connections
    PaymentUI --> PaymentAPI
    GovUI --> GovAPI
    ChatUI --> LawyerAPI

    %% Service connections
    PaymentAPI --> PaymentService
    GovAPI --> GovService
    LawyerAPI --> LawyerService

    %% Database connections
    PaymentService --> PaymentDB
    GovService --> ChatDB
    LawyerService --> ChatDB
    LawyerService --> QueueDB

    %% External connections
    PaymentService --> PaymentProvider
    GovService --> GovProvider
    LawyerService --> NotificationService
```

## Диаграмма компонентов (Фаза 3 - Корпоративные функции)

```mermaid
graph TB
    subgraph "Frontend Layer"
        WebUI[Веб-интерфейс<br/>React + TypeScript]
        CorporateUI[Корпоративный UI<br/>Team management]
        AdminUI[Админ панель<br/>User management]
        DocumentUI[Документы<br/>Collaborative editing]
    end

    subgraph "API Layer"
        AuthAPI[Auth API<br/>POST /auth/*]
        CorporateAPI[Corporate API<br/>POST /corporate/*]
        AdminAPI[Admin API<br/>GET/POST /admin/*]
        DocumentAPI[Document API<br/>POST /documents/*]
        PermissionAPI[Permission API<br/>GET /permissions/*]
    end

    subgraph "Service Layer"
        AuthService[Auth Service<br/>User management]
        CorporateService[Corporate Service<br/>Company management]
        AdminService[Admin Service<br/>System administration]
        DocumentService[Document Service<br/>Collaborative editing]
        PermissionService[Permission Service<br/>RBAC management]
        AuditService[Audit Service<br/>Activity logging]
    end

    subgraph "Data Layer"
        UserDB[(Users<br/>PostgreSQL)]
        CorporateDB[(Companies<br/>PostgreSQL)]
        DocumentDB[(Documents<br/>PostgreSQL)]
        PermissionDB[(Permissions<br/>PostgreSQL)]
        AuditDB[(Audit Logs<br/>PostgreSQL)]
        FileDB[(Files<br/>PostgreSQL)]
        CacheDB[(Cache<br/>PostgreSQL)]
    end

    subgraph "External Services"
        SSOProvider[SSO Provider<br/>OAuth2/SAML]
        EmailProvider[Email Provider<br/>SMTP/SendGrid]
    end

    %% Frontend connections
    WebUI --> CorporateUI
    WebUI --> AdminUI

    %% API connections
    CorporateUI --> CorporateAPI
    AdminUI --> AdminAPI
    DocumentUI --> PermissionAPI

    %% Service connections
    CorporateAPI --> CorporateService
    AdminAPI --> AdminService
    PermissionAPI --> PermissionService

    %% Database connections
    CorporateService --> CorporateDB
    AdminService --> UserDB
    PermissionService --> PermissionDB
    DocumentService --> AuditService
    AuditService --> AuditDB

    %% External connections
    AuthService --> SSOProvider
    CorporateService --> EmailProvider
```

