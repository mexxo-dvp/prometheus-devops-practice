# demo-project

## Опис

**Навчальний DevOps-проєкт у рамках курсу Prometheus.**  
Вебзастосунок на Go з веб-інтерфейсом, контейнеризований Docker і розгорнутий у Kubernetes (GKE/локально).  
Проєкт також містить повний стек моніторингу (Prometheus, Grafana, Node Exporter, Alertmanager) та кешуючий DNS-сервер dnsmasq для оптимізації локальної розробки.

---

## Зміст

- [Передумови](#передумови)
- [Структура проєкту](#структура-проєкту)
- [Запуск у різних середовищах](#запуск-у-різних-середовищах)
  - [Локально через Docker Compose](#локально-через-docker-compose)
  - [Локально через Kubernetes (kind)](#локально-через-kubernetes-kind)
  - [Хмара Google GKE](#хмара-google-gke)
- [Оновлення застосунку (zero downtime)](#оновлення-застосунку-zero-downtime)
- [Моніторинг та алертинг](#моніторинг-та-алертинг)
- [Прискорення DNS-запитів (dnsmasq)](#прискорення-dns-запитів-dnsmasq)
- [Корисні команди](#корисні-команди)
- [changelog](#хронологія-змін)
- [Автор](#автор)

---

## Передумови

**Рекомендоване середовище:** Ubuntu 22.04  
> *Для роботи з Docker без sudo необхідно перелогінитися після додавання у групу!*

### Встановлення базових компонентів


# Git
```bash
sudo apt-get update
sudo apt-get install -y git
git config --global user.name "your user name"
git config --global user.email "your@email"
git config --global init.defaultBranch main
```
# Go 1.24.5
```bash
wget https://go.dev/dl/go1.24.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.24.5.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.profile
source ~/.profile
go version
```
# Docker
```bash
sudo apt-get install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker  # або перелогінитися!
```
# Kubectl
```bash
sudo apt-get install -y kubectl
kubectl version --client
```
# Google Cloud SDK + GKE auth plugin
```bash
sudo apt-get install -y apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
  | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update
sudo apt-get install -y google-cloud-sdk google-cloud-sdk-gke-gcloud-auth-plugin
which gke-gcloud-auth-plugin
```
## Структура проєкту

```text
prometheus-devops-practice/
├── .gitignore
├── Dockerfile                 # Основний Go-додаток
├── README.md
├── docker-compose.yml         # Для dnsmasq/dev-runner
├── go.mod
├── html/                      # Статика (SVG, JS, HTML)
├── infra/
│   └── dnsmasq/
│       ├── Dockerfile
│       └── dnsmasq.conf
├── k8s/
│   ├── alertmanager/
│   ├── grafana/
│   ├── node-exporter/
│   ├── prometheus/
│   ├── deployment.yaml
│   └── service.yaml
├── monitoring/
│   ├── docker-compose.yml     # Альтернатива моніторингу локально
│   ├── grafana/
│   ├── node_exporter/
│   └── prometheus/
└── src/
    └── main.go
```
Запуск у різних середовищах
Локально через Docker Compose

Для швидкого запуску кешуючого DNS та dev-runner:
```bash
cd infra/
docker-compose up -d --build
```
# Перевірка роботи dnsmasq:
```bash
docker exec -it dev-runner bash
apt update && apt install -y dnsutils
dig google.com
```
Моніторинг локально (за бажанням)
```bash
cd monitoring
docker-compose up -d
```
# Grafana: http://localhost:3000 (login: admin/admin)

Локально через Kubernetes (kind)

# Встановлення kind
```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```
# Створення кластера
```bash
kind create cluster --name dev-cluster
```
# Перевірка статусу
```bash
kubectl cluster-info
kubectl get nodes
```
# Застосування маніфестів
```bash
kubectl apply -f k8s/
```
Хмара Google GKE

# Логін і ініціалізація
```bash
gcloud init
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
gcloud config set compute/zone europe-west3-a
```
# Отримання доступу до кластера
```bash
gcloud container clusters get-credentials demo-cluster --zone=europe-west3-a
```
# Деплой додатку
```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
# Доступ до NodePort:
```bash
gcloud compute instances describe <NODE_NAME> --zone=<ZONE> --format="get(tags.items)"
gcloud compute instances add-tags <NODE_NAME> --tags=gke-node --zone=<ZONE>
gcloud compute firewall-rules create allow-nodeport-demo \
  --allow=tcp:30080 \
  --target-tags=gke-node \
  --direction=INGRESS \
  --source-ranges=0.0.0.0/0 \
  --priority=1000 \
  --description="Allow external traffic to NodePort 30080"
```
Оновлення застосунку (zero downtime)

# Припустимо, новий образ вже запушено (див. наступний блок)
```bash
kubectl set image deployment/demo-app demo-app=mexxo-dvp/demo-app:v1.0.2 --record
kubectl rollout status deployment/demo-app
```
Робота з Docker-образами

# Збірка бінарника Go
```bash
go build -o bin/server ./src
```
# Збірка Docker-образу
```bash
docker build -t mexxo-dvp/demo-app:v1.0.2 .
```
# Логін у Docker Hub та публікація
```bash
docker login
docker push mexxo-dvp/demo-app:v1.0.2
```
# (за потреби) Перейменування та пуш у публічний репозиторій
```bash
docker tag mexxo-dvp/demo-app:v1.0.2 paranoidlookup/demo-app:v1.0.2
docker push paranoidlookup/demo-app:v1.0.2
```
Docker Hub:
Теги репозиторію
Альтернатива
Моніторинг та алертинг

Kubernetes-маніфести для моніторингу — у папці k8s/.
Включає:

    Prometheus (метрики додатку/кластеру)

    Grafana (дашборди, login: admin/admin)

    Node Exporter (метрики хосту)

    Alertmanager (шаблони сповіщень через Telegram, Slack тощо — потрібен свій webhook/token!)

Локальний запуск моніторингу:
```bash
cd monitoring && docker-compose up -d
```
Прискорення DNS-запитів (dnsmasq)

    Кешуючий DNS-сервер dnsmasq для швидкої локальної CI/CD-розробки.

    Dockerfile та конфігурація у infra/dnsmasq/

    Включено до docker-compose.yml

Корисні команди

    Відкрити порт NodePort вручну:
```bash
gcloud compute firewall-rules create allow-nodeport-demo \
  --allow=tcp:30080 --target-tags=gke-node \
  --direction=INGRESS --source-ranges=0.0.0.0/0 --priority=1000
```
Доступ до застосунку:
Через браузер: http://34.40.127.19:30080
Або через port-forward:
```bash
kubectl port-forward service/demo-service 8080:80
curl http://localhost:8080
```
Перегляд тегів на ноді:
```bash
gcloud compute instances describe <NODE_NAME> --zone=<ZONE> --format="get(tags.items)"
```
Додавання тегу:
```bash
gcloud compute instances add-tags <NODE_NAME> --tags=gke-node --zone=<ZONE>
```
Оновлення статичного контенту

    Додавання або оновлення файлів у папці html/

    Закомітити зміни:
```bash
git add html/
git commit -m "feat: update static content in html/"
git tag v1.0.3
git push origin main --tags
```
## Changelog

### v1.0.3
- Оновлено інструкцію README, додано деталізований опис для локального та GKE-розгортання.
- В `deployment.yaml` оновлено образ на paranoidlookup/demo-app:v1.0.3.
- Додано розділ про альтернативний запуск моніторингу через monitoring/docker-compose.yml.
- Додано пояснення про перелогін після додавання в групу docker.
- Додано деталізовані команди для роботи з NodePort та Google Cloud Firewall.
- Уточнено вимоги щодо алертів у Alertmanager (webhook, токени).
- Додано Changelog у кінець файлу.
- Єдиний підхід до неймінгу образів та тегів.
- Додано README файли до стеку моніторингу та dnsmasq

### v1.0.2
- Додано кешуючий DNS-сервер dnsmasq для оптимізації локальної розробки.
- Додано Docker Compose для запуску dnsmasq/dev-runner.
- Впроваджено систему моніторингу: Prometheus, Grafana, Node Exporter, Alertmanager у Kubernetes.
- Внесено зміни до Kubernetes manifests для розгортання моніторингу.
- README: інструкції щодо запуску локального DNS-кеша.

### v1.0.1
- Додано та оновлено статичний контент у директорії `html/`.
- Описано коміти, роботу з тегами та деплой через kubectl set image.
- README: деталізовано процес оновлення застосунку у Kubernetes (zero downtime).

### v1.0.0
- Базова ініціалізація проєкту: структура директорій, базовий Go-застосунок, Dockerfile.
- CI/CD: ручне складання, деплой у GKE, базові kubernetes manifests (deployment, service).
- README: мінімальні інструкції щодо збірки, публікації та деплою додатку.

---

Автор

mexxo-dvp GitHub: @mexxo-dvp


Примітки

    Для налаштування алертів в Alertmanager потрібен свій Telegram-бот/Slack Webhook — див. офіційну документацію.