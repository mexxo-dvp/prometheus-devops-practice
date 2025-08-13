# Monitoring Stack (Prometheus + Grafana + Node Exporter + Alertmanager)

Комплексний стек моніторингу для DevOps-проєктів: збирання метрик, дашборди, алерти, інтеграція зі Slack/Telegram.

---

## Структура

```text
monitoring/
├── docker-compose.yml
├── grafana/
│   ├── Dockerfile
│   └── provisioning/
│       ├── dashboards/
│       │   ├── dashboards.yaml
│       │   └── node_exporter_full.json
        └── datasources/
│           └── prometheus.yaml
├── prometheus/
│   ├── alerts.yml
│   ├── alertmanager.yml
│   └── prometheus.yml
├── node_exporter/
│   ├── alerts.yml
│   ├── alertmanager.yml
│   ├── node_exporter         # Бінарник
└──README.md
```

Швидкий старт (Docker Compose)

    Потрібен встановлений Docker та docker-compose
```bash
cd monitoring
docker-compose up -d
```
Сервіси та доступ

    Grafana: http://localhost:3000

        Login: admin

        Password: admin (змініть при першому вході!)

    Prometheus: http://localhost:9090

    Node Exporter: http://localhost:9100/metrics

    Alertmanager: http://localhost:9093

Компоненти
Grafana

    Базується на grafana/grafana-oss:latest.

    Автоматичне завантаження дашбордів із provisioning/dashboards/ (зокрема, node_exporter_full.json — детальний дашборд системних метрик).

    Джерело даних Prometheus налаштовується через provisioning/prometheus.yaml.

    Всі дані Grafana (dashboard, users) зберігаються у volume grafana-data.

Оновлення або додавання дашбордів:

    Додайте JSON-файл у provisioning/dashboards/.

    Оновіть dashboards.yaml (або просто розмістіть файл у папці — Grafana підхопить новий dashboard).

Prometheus

    Основна конфігурація: prometheus/prometheus.yml.

    Метрики збираються із:

        Node Exporter (node_exporter:9100)

        Prometheus (prometheus:9090)

    Алерти визначаються у prometheus/alerts.yml.

    Alertmanager підключається через секцію alerting:.

Node Exporter

    Збір системних метрик із хоста (CPU, RAM, IO, Filesystem...).

    Налаштувань не потребує, працює “з коробки”.

Alertmanager

    Конфіг: prometheus/alertmanager.yml

    Відправка сповіщень у Slack, Telegram (налаштувати свої токени та webhook!).

    Див. секцію receivers в alertmanager.yml.

Основні Docker-команди

## Запуск:

```bash
docker-compose up -d
```

## Перегляд логів:
```bash
docker-compose logs -f grafana
docker-compose logs -f prometheus
```

## Зупинка та видалення:
```bash
docker-compose down -v
```
## Поширені питання та усунення несправностей

- Якщо Grafana не відображає метрики, рекомендується перевірити доступність Prometheus за URL, вказаним у файлі `provisioning/prometheus.yaml`.
- Якщо Alertmanager не надсилає алерти, необхідно перевірити налаштування токенів та webhook-адрес у файлі `prometheus/alertmanager.yml`.
- У разі проблем із відображенням дашбордів в Grafana, доцільно перезапустити сервіс командою `docker-compose restart grafana` та перевірити правильність шляхів у файлі `dashboards.yaml`.

---

## Кастомізація

- Нові правила для алертів можна додавати у файл `prometheus/alerts.yml`. Для застосування змін потрібно перезапустити контейнер Prometheus.
- Для налаштування сповіщень у Telegram або Slack слід вказати актуальні значення `bot_token`, `chat_id` або `slack_api_url` у файлі `prometheus/alertmanager.yml`.
- Додати власні дашборди можна через веб-інтерфейс Grafana або шляхом копіювання відповідних JSON-файлів у папку `provisioning/dashboards/`.

---

## Додаткова інформація

- Для використання у production-середовищі рекомендовано змінити стандартні паролі, налаштувати volumes та обмежити доступ до сервісів за допомогою фаєрволу.
- Додаткові відомості:
    - [Grafana Dashboards Documentation](https://grafana.com/dashboards/)
    - [Prometheus Documentation](https://prometheus.io/docs/)

Автор

mexxo-dvp
GitHub: @mexxo-dvp