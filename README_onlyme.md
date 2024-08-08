### Create cluster:

eksctl create cluster --name viettq-cluster --region us-east-1 --nodegroup-name viettq-node --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2

###  Delete cluster (Optional)
eksctl delete cluster --name viettq-cluster

### Connect kubectl to eks:

aws eks --region us-east-1 update-kubeconfig --name viettq-cluster

### Create db

sh ./db/apply.sh

### Set up port-forwarding to `postgresql-service`

kubectl apply -f ./db/postgresql-service.yaml

kubectl port-forward service/postgresql-service 5433:5432 &

### Close port-forwarding to `postgresql-service`
ps aux | grep 'kubectl port-forward' | grep -v grep | awk '{print $2}' | xargs -r kill

### Import env variable to os (local)
export DB_NAME=viettq-db-name
export DB_PASSWORD=viettq-db-password
export DB_USERNAME=viettq-db-user
export DB_HOST=127.0.0.1
export DB_PORT=5433

### Insert data to database

PGPASSWORD="$DB_PASSWORD" psql --host $DB_HOST -U $DB_USERNAME -d $DB_NAME -p $DB_PORT < ./db/1_create_tables.sql
PGPASSWORD="$DB_PASSWORD" psql --host $DB_HOST -U $DB_USERNAME -d $DB_NAME -p $DB_PORT < ./db/2_seed_users.sql
PGPASSWORD="$DB_PASSWORD" psql --host $DB_HOST -U $DB_USERNAME -d $DB_NAME -p $DB_PORT < ./db/3_seed_tokens.sql

### Install lib python (local)
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt

### Run app (local)
python app.py
curl 127.0.0.1:5153/api/reports/daily_usage
curl 127.0.0.1:5153/api/reports/user_visits

### Build docker (local)
docker build -t coworking-analytics .
docker run --network="host" coworking-analytics

### Generate DB password encrypt and replace to DB_PASSWORD in deployment/secret.yaml
echo -n 'viettq-db-password' | base64

### Generate secret variable ekc
kubectl apply -f ./deployment/secret.yaml
kubectl apply -f ./deployment/configmap.yaml
kubectl apply -f ./deployment/coworking.yaml



































eyJwYXlsb2FkIjoiYjNYU2FodmFMTGhXTmt3VGlOR1VwUXBjVTB2eSs4K0QvcGRmR2hGcUU1UlVZOGNJOTlEY1JSTzgxeGNINEdieThKdjBtNzNhQU5FN3VLT3JFV0ZFTjVWSThpV0FEQ0Z2VENOODY0cjBXTVhPa29yRitWWm05bU1qc25JMjlPUHRmUnVibW44d0tOa1JPRXRINXJGVDdmcGdadksrcUorMFU4SjlVZzJubEFRYitZd3hQcElQTG1veGZUY2g4Qmp6S2ZadHZNbFQyYm8vYW00dWhuOVlVTEMrWDRtSWRvSVZJREtiRHM0MG9CVUpLdUtqNzh6ZjRnL2doMkVYUC93U053Y2p1b05ISUpjOFFoTHJabEZ5K0Q2ajhYd3p0SE9DRi9BckhKUFZXZTAzVEhQOUtkYWZvWndJdUJkc0lTQk9GV01nK3ZBZjJWbVZ4L2JVZ2djcTNxYTJodUU5NjFJaWV5b1U3S1E3TmphMDA2YlZYSHVMbjBoYkhES0t0bmFpanZISXBzT04wcDRycXEyeFl3SkR5Qm1NNlR2UFdMeXRtOEZCb2RocEVub3dxRFhFZ3MwcU5YWGdURW9YaFptMEd6K2RKYy8zSWxJb1MzQjR1UlBWMmY5THB1azlCQkNjeVpLOE91Qk9XajI2M21kaHBXSm9keEI4dGdMR1VDLytNbjhyTFpkSWljS3h4TjJLdnlSN05QUUFNdlYxTGZUQzUxeG8wbXZZUXVYRjNnRUY0ei9nWXQ5THRXaExXQlkvcWhNT0pzZUdmd2RHdU5nT2paT2JZbXlFdmxXS2VQbWpQcVBsdXJDUWJ3VEhpTUVSWGdueDIreUtUWDVVWHVXYkVmM21yd1JrUzZsNFE4V3BMS21QWDEyeExUVDNVWkRkaTZDOEZFdWdCL0R1dWNXYnpWakpBL1l4MUU2MUxEbVFPUGZjb0UvTlM2OWF3T0ZvRE44SkFNU2JXVzMrL3IvU3VCUWRnUHNZZkJwVjhxVHVOUnZZM3pSL0p2UXRSWFFwOURaazJkeTN1NVRCSWJGNGFMc0tzWUNWUEt2WFBVM3VSMCtmbmZnZE1VemRWWTJpK1d6Y0J5SVRvanFYTGJhZkVVbGJha2lpVGxKaEExVVdpSXEyanR3UUhmTzlIU2RZa3FETzA2THp4b2hJRVc3dURFbEh3U2phc0xMbExiR3VKRHByaEpqdHFHWlNnekdHOWs0TmJUd1JCejZzZGs2dGw5L0FKWENUSUpSU2JJb2UyS3RGejJUbWtJLzl0Tzl0c0xsaUFVSW9SVXJXSnlmSkV1cUVQS3hLYTkvSWtuYStXaU52UmhtVW04OUQ0ZlNpMHBMSFpSOC9KMEpMIiwiZGF0YWtleSI6IkFRRUJBSGh3bTBZYUlTSmVSdEptNW4xRzZ1cWVla1h1b1hYUGU1VUZjZTlScTgvMTR3QUFBSDR3ZkFZSktvWklodmNOQVFjR29HOHdiUUlCQURCb0Jna3Foa2lHOXcwQkJ3RXdIZ1lKWUlaSUFXVURCQUV1TUJFRURBazl5WS9QUTJwN3B1YUNld0lCRUlBN0RXUkVPbXBWNjJsOW5CYXBndFdmMGQwOVprU01TSkJ4SkRpcUw0Y1VrQzBKT2I0Vnh0R1lnV0VGb2hWM3pSSjdIcjJQY0NWSFZJQ0IyVGs9IiwidmVyc2lvbiI6IjIiLCJ0eXBlIjoiREFUQV9LRVkiLCJleHBpcmF0aW9uIjoxNzIzMTMyNTk0fQ==