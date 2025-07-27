# demo-project

## Опис

Навчальний проєкт у рамках курсу **DevOps від Prometheus**.  
Веб-застосунок на Go з веб-інтерфейсом, контейнеризований через Docker і розгорнутий у Kubernetes (GKE).

---

## Передумови

Проєкт розроблявся на Ubuntu 22.04 (локально). 
Для коректної роботи виконайте на Ubuntu-системі такі кроки:

```bash
# 1. Встановлення Git
sudo apt-get update
sudo apt-get install -y git
git config --global user.name "your user name"
git config --global user.email "your email"
git config --global init.defaultBranch main

# 2. Встановлення Go 1.24.5
wget https://go.dev/dl/go1.24.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.24.5.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
go version

# 3. Встановлення Docker
sudo apt-get install -y docker.io
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker  # застосувати зміни групи

# 4. Встановлення Google Cloud SDK та плагіну для GKE-авторизації
sudo apt-get install -y apt-transport-https ca-certificates gnupg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" \
  | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
  | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update
sudo apt-get install -y google-cloud-sdk google-cloud-sdk-gke-gcloud-auth-plugin
which gke-gcloud-auth-plugin

# 5. Логін і налаштування GCP
gcloud init
gcloud auth login
# Встановіть потрібні налаштування, наприклад, проект та зону:
gcloud config set project YOUR_PROJECT_ID
gcloud config set compute/zone europe-west3-a

# Отримання облікових даних кластера
gcloud container clusters get-credentials demo-cluster --zone=europe-west3-a

Технології

    Go

    Docker

    Kubernetes (GKE)

    Google Cloud Platform (GCP)

Як запустити
Крок 1. Збірка Go-бінарника та Docker-образу

У кореневій папці проєкту виконати:

go build -o bin/server ./src

docker build -t mexxo-dvp/demo-app:v1.0.0 .

Крок 2. Публікація образу в Docker Hub

docker login
docker push mexxo-dvp/demo-app:v1.0.0

Крок 3. Деплой у Kubernetes (GKE)

kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

Доступ до застосунку

Перевірка та налаштування доступу через NodePort у Google Cloud

    Перевірка тегів на віртуальній машині (ноді):

gcloud compute instances describe ІМ'Я_НОДИ --zone=ЗОНА --format="get(tags.items)"

Приклад:

gcloud compute instances describe gke-demo-cluster-default-pool-5e0e558d-1fsu --zone=europe-west3-a --format="get(tags.items)"

    Додавання необхідного тегу для відкриття порту (якщо тег відсутній):

gcloud compute instances add-tags ІМ'Я_НОДИ --tags=ІМ'Я_ТЕГУ --zone=ЗОНА

Приклад:

gcloud compute instances add-tags gke-demo-cluster-default-pool-5e0e558d-1fsu --tags=gke-node --zone=europe-west3-a

    Створення правила firewall для доступу до NodePort:

gcloud compute firewall-rules create allow-nodeport-demo \
  --allow=tcp:30080 \
  --target-tags=gke-node \
  --direction=INGRESS \
  --source-ranges=0.0.0.0/0 \
  --priority=1000 \
  --description="Allow external traffic to NodePort 30080"

    Доступ до застосунку:

    Через IP і NodePort у браузері:

http://34.40.127.19:30080

    Або локально через port-forward:

kubectl port-forward service/demo-service 8080:80
curl http://localhost:8080

Оновлення статичного контенту (версія v1.0.1)

    Додайте нові файли у папку html/, наприклад:

wget -P html/ https://raw.githubusercontent.com/your_project/frame1-frame15.svg
# ... аналогічно для інших SVG

    Зафіксуйте зміни у git:

git add html/
git commit -m "feat: update static content in html/"
git tag v1.0.1
git push origin main --tags

Zero-downtime оновлення застосунку в Kubernetes

kubectl set image deployment/demo-app demo-app=mexxo-dvp/demo-app:v1.0.1 --record
kubectl rollout status deployment/demo-app

Моніторинг та оптимізація локальних DNS запитів (версія v1.0.2)
Додано

    dnsmasq — кешуючий DNS-сервер для прискорення локальних CI/Dev-запитів.

    Система моніторингу, готова до Kubernetes:

        Prometheus — збір метрик

        Grafana — візуалізація метрик

        Node Exporter — метрики хост-машини

        Alertmanager — система сповіщень через Telegram або Slack

Конфігурації Kubernetes розміщені у директорії k8s/.
Розгортання моніторингу в Kubernetes через kind
Крок 1. Встановлення kind (у Codespaces)

curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind version

Крок 2. Створення кластера

kind create cluster --name codespace-cluster

Крок 3. Перевірка статусу

kubectl cluster-info
kubectl get nodes

Крок 4. Застосування Kubernetes YAML-манифестів моніторингу

kubectl apply -f k8s/prometheus/configmap.yaml
kubectl apply -f k8s/prometheus/deployment.yaml
kubectl apply -f k8s/prometheus/service.yaml

kubectl apply -f k8s/alertmanager/configmap.yaml
kubectl apply -f k8s/alertmanager/deployment.yaml
kubectl apply -f k8s/alertmanager/service.yaml

kubectl apply -f k8s/grafana/configmap.yaml
kubectl apply -f k8s/grafana/deployment.yaml
kubectl apply -f k8s/grafana/service.yaml

kubectl apply -f k8s/node-exporter/daemonset.yaml
kubectl apply -f k8s/node-exporter/service.yaml

Встановлення та налаштування dnsmasq

Для прискорення DNS-запитів у локальному середовищі використовується кешуючий DNS-сервер dnsmasq.

    Конфігурація та Dockerfile dnsmasq знаходяться в infra/dnsmasq/.

    Docker Compose файл у корені проєкту запускає dnsmasq та тестовий контейнер dev-runner.

Запуск

cd /шлях/до/prometheus-devops-practice
docker-compose up -d --build

Перевірка роботи

docker exec -it dev-runner bash
apt update && apt install -y dnsutils
dig google.com
dig google.com  # повторний запит має бути швидшим — кеш працює
 
Оновлено файл README з детальним описом запуску програми, налаштування Kubernetes та деплою. (версія v1.0.3)

В deployment.yaml оновлено образ на paranoidlookup/demo-app:v1.0.3 для запуску нової версії застосунку.



Структура проєкту

prometheus-devops-practice/
├── .gitignore
├── Dockerfile                     # Dockerfile основного Go-додатку
├── README.md                     # Головна документація проекту
├── docker-compose.yml            # Compose для dnsmasq і dev-runner
├── go.mod                       # Go-модулі
├── html/                        # Статичні файли (SVG, HTML, JS)
│   ├── frame1.svg
│   ├── frame2.svg
│   ├── frame3.svg
│   ├── ...                      # багато інших frame*.svg файлів
│   ├── frame15.svg
│   ├── index.html
│   └── vivus.min.js
├── infra/
│   └── dnsmasq/
│       ├── Dockerfile           # Dockerfile для dnsmasq
│       └── dnsmasq.conf         # Конфігурація dnsmasq
├── k8s/                        # Маніфести Kubernetes для різних компонентів
│   ├── alertmanager/
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── grafana/
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── node-exporter/
│   │   ├── daemonset.yaml
│   │   └── service.yaml
│   ├── prometheus/
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   ├── deployment.yaml
│   └── service.yaml
├── monitoring/                 # Моніторинг: Grafana, Prometheus, node_exporter
│   ├── docker-compose.yml
│   ├── grafana/
│   │   ├── Dockerfile
│   │   └── provisioning/
│   │       ├── dashboards/
│   │       │   ├── dashboards.yaml
│   │       │   └── node_exporter_full.json
│   │       └── datasources/
│   │           └── prometheus.yaml
│   ├── node_exporter/
│   │   ├── LICENSE
│   │   ├── NOTICE
│   │   ├── README.md
│   │   └── node_exporter
│   └── prometheus/
│       ├── alertmanager.yml
│       ├── alerts.yml
│       └── prometheus.yml
└── src/
    └── main.go                 # Основний код додатку

Автор

mexxo-dvp — DevOps-практикант
GitHub: @mexxo-dvp