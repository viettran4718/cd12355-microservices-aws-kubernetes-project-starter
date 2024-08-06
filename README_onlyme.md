Create cluster:

aws cloudformation create-stack --stack-name viettq-eks --template-body file://eks-cluster.yaml --capabilities CAPABILITY_IAM

Delete cluster:
aws cloudformation delete-stack --stack-name viettq-eks

Connect kubectl to eks:
aws eks --region us-east-1 update-kubeconfig --name viettq-eks-Cluster

Create db

sh ./db/apply.sh