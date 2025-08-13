# dnsmasq (локальний DNS-кеш для CI/Dev)

Кешуючий DNS-сервер для локальної розробки, тестування CI/CD або ізоляції DNS-запитів у Docker-мережах.

---

## Призначення

- **Прискорення DNS-запитів** (зменшення часу відгуку під час тестів або розробки)
- **Зменшення навантаження на публічні DNS**
- **Прозорий лог усіх DNS-запитів**
- **Можливість налаштувати власні upstream DNS або корпоративні resolver-и**

---

## Основний конфіг (`dnsmasq.conf`):

```ini
no-resolv
server=1.1.1.1
server=8.8.8.8
cache-size=1000
log-queries
log-facility=/var/log/dnsmasq.log
```

Пояснення опцій:

    no-resolv
    Не використовувати системний /etc/resolv.conf, лише явно задані DNS у цьому конфігу.

    server=1.1.1.1 / server=8.8.8.8
    Список upstream DNS-серверів (Cloudflare, Google DNS).

    cache-size=1000
    Максимум 1000 записів у кеші DNS-відповідей (значно прискорює повторні запити).

    log-queries
    Вести журнал усіх DNS-запитів (зручно для дебагу/аудиту).

    log-facility=/var/log/dnsmasq.log
    Виводити логи у файл /var/log/dnsmasq.log (усередині контейнера).

Запуск через Docker Compose

    docker-compose.yml має містити сервіс із цим образом, порт 53 (UDP), volume для логів за потреби.
```yaml
services:
  dnsmasq:
    image: custom/dnsmasq
    build: .
    ports:
      - "1053:53/udp"
    volumes:
      - ./dnsmasq.conf:/etc/dnsmasq.conf
      - ./dnsmasq.log:/var/log/dnsmasq.log
    restart: unless-stopped
```
Як скористатися:

    Запустити контейнер:
```bash
docker-compose up -d
```
Вказати у своїй системі/CI runner-і DNS-сервер:
127.0.0.1:1053 (або IP docker bridge, якщо треба з інших контейнерів)

Для перевірки:
```bash
dig @127.0.0.1 -p 1053 google.com
```
Для аналізу логів:
```bash
tail -f dnsmasq.log
```
## Рекомендації щодо використання

- Список upstream DNS-серверів можна змінити відповідно до корпоративної політики або власних вподобань (наприклад, використовувати корпоративні чи інші публічні DNS).
- Значення `cache-size` доцільно збільшувати у разі високого навантаження на DNS (велика кількість запитів).
- Параметр `log-queries` рекомендовано використовувати лише під час налагодження, оскільки у production-середовищі це може призводити до надмірної кількості логів.

Автор

mexxo-dvp / IT DevOps
GitHub: @mexxo-dvp
