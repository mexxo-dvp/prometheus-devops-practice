## `demo-project/`

### Опис

Навчальний проєкт у рамках курсу DevOps від Prometheus. Простий веб-застосунок на Go з веб-інтерфейсом, контейнеризований за допомогою Docker та розгорнутий у Kubernetes-кластері GKE (Google Kubernetes Engine).

### Технології

- Мова: Go  
- Контейнеризація: Docker  
- Оркестрація: Kubernetes (GKE)  
- Інфраструктура: Google Cloud Platform  
- CI/CD: — *(буде додано пізніше)*

---

###  Як запустити

####  Збірка бінарника та Docker-образу

```bash
# Збірка Go-бінарника
go build -o bin/server ./src

# Створення Docker-образу
docker build -t paranoidlookup/demo-app:v1.0.0 .

Публікація в Docker Hub

docker push paranoidlookup/demo-app:v1.0.0

Деплой у Kubernetes

kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

Доступ до застосунку

Відкриття NodePort у брандмауері GCP:

gcloud compute firewall-rules create allow-nodeport-demo \
  --allow=tcp:30080 \
  --target-tags=gke-node \
  --direction=INGRESS \
  --source-ranges=0.0.0.0/0 \
  --priority=1000 \
  --description="Allow external traffic to NodePort 30080"

Тепер застосунок доступний за адресою:

http://34.40.61.254:30080

34.40.61.254 — зовнішня IP-адреса ноди з kubectl get nodes -o wide
Перевірка

curl http://34.40.61.254:30080

Або з використанням port-forward:

kubectl port-forward service/demo-service 8080:80
curl http://localhost:8080

Структура проєкту

demo-project/
├── bin/                  # Скомпільований Go-бінарник
├── Dockerfile            # Інструкція Docker
├── go.mod                # Go-модулі
├── html/                 # Статичні файли (веб-інтерфейс)
├── k8s/                  # YAML-файли Kubernetes
├── src/                  # Початковий код на Go
└── README.md             # Цей файл

Версія

v1.0.0 — мінімально робоча версія, вручну задеплоєна у Kubernetes.

Автор

mexxo-dvp — DevOps-практикант
GitHub: @mexxo-dvp
=======
# prometeus_devops_practice
