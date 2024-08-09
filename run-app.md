### Create cluster:

eksctl create cluster --name my-cluster --region us-east-1 --nodegroup-name my-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2

###  Delete cluster (Optional)
eksctl delete cluster --name my-cluster

### Connect kubectl to eks:

aws eks --region us-east-1 update-kubeconfig --name my-cluster

### attach policy 
aws iam attach-role-policy --role-name "eksctl-my-cluster-nodegroup-my-nod-NodeInstanceRole-8i9dVCVCdZrC" --policy-arn "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"

aws eks create-addon --addon-name amazon-cloudwatch-observability --cluster-name my-cluster


### Create db

sh ./db/apply.sh

### Set up port-forwarding to `postgresql-service`

kubectl port-forward service/postgresql-service 5432:5432 

### Close port-forwarding to `postgresql-service`
ps aux | grep 'kubectl port-forward' | grep -v grep | awk '{print $2}' | xargs -r kill

### Import env variable to os (local)
export DB_NAME=viettq-db-name
export DB_PASSWORD=viettq-db-password
export DB_USERNAME=viettq-db-user
export DB_HOST=127.0.0.1
export DB_PORT=5432

### Insert data to database

PGPASSWORD="$DB_PASSWORD" psql --host $DB_HOST -U $DB_USERNAME -d $DB_NAME -p $DB_PORT < ./db/1_create_tables.sql
PGPASSWORD="$DB_PASSWORD" psql --host $DB_HOST -U $DB_USERNAME -d $DB_NAME -p $DB_PORT < ./db/2_seed_users.sql
PGPASSWORD="$DB_PASSWORD" psql --host $DB_HOST -U $DB_USERNAME -d $DB_NAME -p $DB_PORT < ./db/3_seed_tokens.sql


### Check database alive
psql -h localhost -p -U viettq-db-user -d viettq-db-name -c 
select * from users
select * from tokens
'\q'

### Generate DB password encrypt and replace to DB_PASSWORD in deployment/secret.yaml
echo -n 'viettq-db-password' | base64

### push image to ecr (manual)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 438118501148.dkr.ecr.us-east-1.amazonaws.com
docker build -t cloud-proj3:v1 .
docker tag cloud-proj3:v1 438118501148.dkr.ecr.us-east-1.amazonaws.com/cloud-proj3:v1
docker push 438118501148.dkr.ecr.us-east-1.amazonaws.com/cloud-proj3:v1
docker tag cloud-proj3:v1 438118501148.dkr.ecr.us-east-1.amazonaws.com/cloud-proj3:latest
docker push 438118501148.dkr.ecr.us-east-1.amazonaws.com/cloud-proj3:latest

### Run app in EKS
kubectl apply -f ./deployment/secret.yaml
kubectl apply -f ./deployment/configmap.yaml
kubectl apply -f ./deployment/coworking.yaml

### Clear app in EKS
kubectl delete -f ./deployment/secret.yaml
kubectl delete -f ./deployment/configmap.yaml
kubectl delete -f ./deployment/coworking.yaml