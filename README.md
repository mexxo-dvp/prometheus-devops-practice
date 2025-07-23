# demo-project

## Опис

Навчальний проєкт у рамках курсу **DevOps від Prometheus**.  
Веб‑застосунок на Go з веб‑інтерфейсом, контейнеризований Docker і розгорнутий у Kubernetes (GKE).

---

## Передумови

Виконайте на Ubuntu-системі:

```bash
# 1. Встановлення Git
sudo apt-get update
sudo apt-get install -y git
git config --global user.name "mexxo-dvp"
git config --global user.email "paranoidlookup@gmail.com"
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

Структура проєкту

demo-project/
├── bin/                  # Go‑бінарник
├── Dockerfile            # Інструкція Docker
├── go.mod                # Go‑модулі
├── html/                 # Статичні файли
├── k8s/                  # YAML‑манифести Kubernetes
├── src/                  # Початковий код Go
└── README.md             # Документація

Автор

mexxo-dvp — DevOps‑практикант
GitHub: @mexxo-dvp
