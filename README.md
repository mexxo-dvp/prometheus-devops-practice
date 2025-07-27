# demo-project

## Опис

Навчальний проєкт у рамках курсу **DevOps від Prometheus**.  
Веб‑застосунок на Go з веб‑інтерфейсом, контейнеризований Docker і розгорнутий у Kubernetes (GKE).

---

## Передумови
Проект спочатку виконувався на ubuntu 22.04 локально.
Виконайте на Ubuntu-системі:

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
newgrp docker  # застосувати зміни до груп

# 4. Встановлення Google Cloud SDK та плагіну для GKE‑авторизації
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
gcloud config set your info
gcloud container clusters get-credentials demo-cluster \
  --zone=europe-west3-a

Технології

    Go

    Docker

    Kubernetes (GKE)

    Google Cloud Platform

Як запустити
1. Збірка Go‑бінарника та Docker‑образу

# Розташування в кореневій папці проєкту
go build -o bin/server ./src

docker build -t mexxo-dvp/demo-app:v1.0.0 .

2. Публікація образу

docker login
docker push mexxo-dvp/demo-app:v1.0.0

3. Деплой у Kubernetes

kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

Доступ до застосунку

    Відкрити NodePort у брандмауері GCP:

gcloud compute firewall-rules create allow-nodeport-demo \
  --allow=tcp:30080 \
  --target-tags=gke-node \
  --direction=INGRESS \
  --source-ranges=0.0.0.0/0 \
  --priority=1000 \
  --description="Allow external traffic to NodePort 30080"

Перейдіть у браузері за адресою:

    http://34.40.61.254:30080

Або локально:

kubectl port-forward service/demo-service 8080:80
curl http://localhost:8080

Оновлення статичного контенту (v1.0.1)

# Додати нові файли у html/
wget -P html/ https://raw.githubusercontent.com/your_project/frame1-frame15.svg

# … аналогічно для інших SVG

git add html/
git commit -m "feat: update static content in html/"
git tag v1.0.1
git push origin main --tags

Zero‑downtime оновлення в Kubernetes

kubectl set image deployment/demo-app \
  demo-app=mexxo-dvp/demo-app:v1.0.1 \
  --record

kubectl rollout status deployment/demo-app


Оновлення Розгортання моніторингу в Kubernetes через kind та використання dnsmasq — як кешуючий локальний DNS-сервер (v1.0.2)
Починаючи з версії v1.0.2 розробка була перенесена у github codespace.
Інфраструктурні компоненти

✅ Додано:

    dnsmasq — кешуючий локальний DNS-сервер для прискорення локальних CI/Dev-запитів.

    Система моніторингу (Kubernetes-ready):

        Prometheus — збір метрик

        Grafana — візуалізація метрик

        Node Exporter — метрики хост-машини

        Alertmanager — система сповіщення про події, через telegram або slack 

Конфігурації Kubernetes лежать у директорії k8s/.



Розгортання моніторингу в Kubernetes через kind

Крок 1. Встановлення kind

Виконай у терміналі Codespaces:

curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

kind version

Крок 2. Створення кластера

kind create cluster --name codespace-cluster

Крок 3. Перевірка статусу

Перевіряємо, що кластер запущено і kubectl має до нього доступ:

kubectl cluster-info
kubectl get nodes

Ти повинен побачити інформацію про майстер-ноду і список вузлів (щонайменше один).
Крок 4. Застосування маніфестів

Тепер можна застосовувати всі свої YAML-файли Kubernetes із папки k8s:

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

Крок 5. Встановлення та налаштування dnsmasq
Для прискорення DNS-запитів у локальному середовищі розробки та CI/CD використовується dnsmasq — легкий кешуючий DNS-сервер. Це допомагає зменшити затримки при багаторазових запитах до одних і тих самих доменів (наприклад, при оновленні пакетів, завантаженні артефактів).
Структура файлів

    Конфігурація та Dockerfile dnsmasq знаходяться в папці:
    infra/dnsmasq/

    Файл docker-compose.yml у корені проекту запускає сервіс dnsmasq та тестовий контейнер dev-runner.

Як запустити

    Перейти у корінь проекту:

cd /шлях/до/prometheus-devops-practice

    Запустити сервіси через Docker Compose:

docker-compose up -d --build

Як перевірити роботу

    Підключитись до тестового контейнера:

docker exec -it dev-runner bash

    Встановити dig (якщо потрібно):

apt update && apt install -y dnsutils

    Виконати перший DNS-запит:

dig google.com

Звернути увагу на час у рядку Query time.

    Виконати запит повторно:

dig google.com

Другий запит повинен бути значно швидшим — це означає, що DNS-відповідь береться з кешу dnsmasq.


Структура проєкту


prometheus-devops-practice/
├── Dockerfile # Dockerfile основного Go-додатку
├── README.md # Головна документація проекту
├── docker-compose.yml # Compose для dnsmasq і dev-runner
├── go.mod # Go-модулі
├── html/ # Статичні файли (SVG, HTML, JS)
│ ├── frame1.svg
│ ├── frame2.svg
│ ├── ... # Інші SVG-файли
│ └── index.html
├── infra/
│ └── dnsmasq/
│ ├── Dockerfile # Dockerfile для dnsmasq
│ └── dnsmasq.conf # Конфігурація dnsmasq
├── k8s/ # Маніфести Kubernetes для різних компонентів
│ ├── alertmanager/
│ │ ├── configmap.yaml
│ │ ├── deployment.yaml
│ │ └── service.yaml
│ ├── deployment.yaml
│ ├── grafana/
│ │ ├── configmap.yaml
│ │ ├── deployment.yaml
│ │ └── service.yaml
│ ├── node-exporter/
│ │ ├── daemonset.yaml
│ │ └── service.yaml
│ ├── prometheus/
│ │ ├── configmap.yaml
│ │ ├── deployment.yaml
│ │ └── service.yaml
│ └── service.yaml
├── monitoring/ # Моніторинг: Grafana, Prometheus, node_exporter
│ ├── docker-compose.yml
│ ├── grafana/
│ │ ├── Dockerfile
│ │ └── provisioning/
│ │ ├── dashboards/
│ │ └── datasources/
│ ├── node_exporter/
│ │ ├── LICENSE
│ │ ├── NOTICE
│ │ ├── README.md
│ │ └── node_exporter
│ └── prometheus/
│ ├── alertmanager.yml
│ ├── alerts.yml
│ └── prometheus.yml
└── src/
└── main.go # Основний код додатку


Автор

mexxo-dvp — DevOps‑практикант
GitHub: @mexxo-dvp
