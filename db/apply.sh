kubectl apply -f ./db/pvc.yaml
kubectl apply -f ./db/pv.yaml
kubectl apply -f ./db/postgresql-deployment.yaml
kubectl apply -f ./db/postgresql-service.yaml