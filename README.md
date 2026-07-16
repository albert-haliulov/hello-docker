# Hello Docker - Многоконтейнерное приложение с Docker Compose

Этот проект демонстрирует, как Docker Compose упрощает разработку, развертывание и управление многоконтейнерными приложениями.

## Архитектура приложения

Приложение состоит из:

- **3 Node.js бэкенд-сервисов** (`hello1`, `hello2`, `hello3`) - Каждый запускает простой веб-сервер, который отображает:
  - Приветственное сообщение
  - Имя хоста контейнера
  - Платформу и релиз ОС
- **1 HAProxy балансировщик нагрузки** (`balancer1`) - Распределяет входящие HTTP-запросы между 3 бэкенд-сервисами

```
┌─────────────────┐
│   HAProxy       │
│   (Порт 80)     │
└────────┬────────┘
         │
    ┌────┴───┬─────────┐
    │        │         │
┌───▼────┐ ┌─▼─────┐  ┌▼─────┐
│ hello1 │ │ hello2 │ │hello3│
│ 8080   │ │ 8080   │ │8080  │
└────────┘ └────────┘ └──────┘
```

## Предварительные требования

- [Docker Engine](https://docs.docker.com/engine/install/) (v20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2.0+)

## Быстрый старт

### Использование Docker Compose (Рекомендуется)

```bash
# Собрать все сервисы
BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') docker compose build

# Запустить все сервисы в фоновом режиме
docker compose up -d

# Просмотр запущенных контейнеров
docker compose ps

# Просмотр логов
docker compose logs -f

# Доступ к приложению
curl http://localhost

# Доступ к статистике HAProxy
curl http://localhost:9000

# Остановить и удалить все сервисы
docker compose down

# Остановить и удалить тома
docker compose down -v
```

### Использование Docker CLI (Ручной подход)

Для сравнения, вот как можно управлять тем же приложением с помощью команд Docker CLI:

```bash
# 1. Создать пользовательскую сеть
docker network create net

# 2. Собрать образ приложения
docker build -t hello-docker https://github.com/albert-haliulov/hello-docker.git

# 3. Запустить 3 бэкенд-сервиса (требует отдельных команд)
docker run -d --rm --name hello1 --net-alias hello --network net -p 8081:8080 hello-docker
docker run -d --rm --name hello2 --net-alias hello --network net -p 8082:8080 hello-docker
docker run -d --rm --name hello3 --net-alias hello --network net -p 8083:8080 hello-docker

# 4. Запустить балансировщик нагрузки (требует ручного монтирования тома)
docker run -d --rm --name lb --network net \
  -v /home/user1/hello-docker/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg \
  -p 80:80 -p 9000:9000 haproxy:2.5.0

# 5. Тестирование приложения
while true; do curl -s http://localhost; sleep 1; done

# 6. Остановка всех сервисов (требует перечисления каждого контейнера)
docker stop hello1 hello2 hello3 lb
```

## Сравнение Docker Compose и Docker CLI

| Задача | Docker CLI | Docker Compose |
|--------|------------|----------------|
| **Создание сети** | `docker create network net` | Автоматически |
| **Сборка образов** | `docker build` (для каждого образа) | `docker compose build` |
| **Запуск сервисов** | Несколько команд `docker run` | `docker compose up -d` |
| **Зависимости сервисов** | Ручное использование `--link` или псевдонимов сети | `depends_on` в файле compose |
| **Монтирование томов** | Флаг `-v` для каждого контейнера | Декларативно в файле compose |
| **Остановка сервисов** | `docker stop` для каждого контейнера | `docker compose down` |
| **Просмотр логов** | `docker logs` для каждого контейнера | `docker compose logs` |
| **Переменные окружения** | Флаг `-e` для каждого контейнера | `environment` в файле compose |

## Ключевые преимущества Docker Compose

### 1. **Единый файл конфигурации**
Все определения сервисов находятся в [`docker-compose.yml`](docker-compose.yml), что делает всю архитектуру приложения видимой и управляемой через систему контроля версий.

### 2. **Автоматическое управление сетями**
Docker Compose автоматически создает общую сеть, позволяя контейнерам взаимодействовать друг с другом, используя имена сервисов в качестве хостов.

### 3. **Декларативные зависимости**
Директива `depends_on` гарантирует, что сервисы запускаются в правильном порядке:
- `hello2` и `hello3` ждут `hello1`
- `balancer1` ждет все бэкенд-сервисы

### 4. **Упрощенные команды**
- Запустить всё: `docker compose up`
- Остановить всё: `docker compose down`
- Просмотреть все логи: `docker compose logs`
- Масштабировать сервисы: `docker compose up --scale hello1=5`

### 5. **Переменные окружения**
Аргументы сборки и переменные окружения определяются один раз и применяются последовательно ко всем сервисам.

## Структура проекта

```
.
├── app/                    # Исходный код Node.js приложения
│   ├── package.json       # Зависимости
│   ├── package-lock.json  # Файл блокировки
│   └── server.js          # Сервер Express
├── haproxy/
│   └── haproxy.cfg        # Конфигурация HAProxy балансировщика нагрузки
├── Dockerfile             # Определение образа приложения
├── docker-compose.yml     # Оркестрация многоконтейнерных сервисов
└── README.md
```

## Переменные окружения

### Аргументы сборки (Dockerfile)
- `IMAGE_CREATE_DATE` - Временная метка создания образа
- `IMAGE_VERSION` - Версия приложения
- `IMAGE_SOURCE_REVISION` - Хеш коммита Git

### Среда сервиса (docker-compose.yml)
- `SERVICE_NAME` - Уникальный идентификатор каждого сервиса
- `PORT` - Порт, на котором слушает приложение (по умолчанию: 8080)

## Полезные команды Docker Compose

```bash
# Сборка образов
docker compose build
docker compose build --no-cache

# Запуск сервисов
docker compose up
docker compose up -d          # Отдельный режим
docker compose up --build     # Пересобрать перед запуском

# Просмотр логов
docker compose logs
docker compose logs -f        # Следовать за логами
docker compose logs hello1    # Логи для конкретного сервиса

# Управление сервисами
docker compose start
docker compose stop
docker compose restart

# Масштабирование сервисов
docker compose up --scale hello1=3

# Инспекция
docker compose ps
docker compose config         # Валидация и просмотр конфигурации

# Очистка
docker compose down           # Остановить и удалить контейнеры
docker compose down -v        # Также удалить тома
docker compose down --rmi all # Также удалить образы
```

## Точки доступа

- **Приложение**: http://localhost
- **Статистика HAProxy**: http://localhost:9000

## Обучающие цели

Этот проект помогает изучающим Docker понять:

1. **Оркестрация многоконтейнерных приложений** - Как контейнеры работают вместе
2. **Обнаружение сервисов** - Использование имен сервисов для внутренней коммуникации
3. **Изоляция сетей** - Пользовательские сети для безопасности
4. **Управление томами** - Монтирование bind для файлов конфигурации
5. **Управление зависимостями** - Обеспечение правильного порядка запуска
6. **Конфигурация как код** - Версионируемые определения сервисов

## Ссылки

- [Документация Docker Compose](https://docs.docker.com/compose/)
- [Справочник Docker CLI](https://docs.docker.com/engine/reference/run/)
- [Документация HAProxy](http://www.haproxy.org/)
- [Лучшие практики Docker для Node.js](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)
