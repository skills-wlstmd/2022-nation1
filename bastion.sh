# ENV
EKS_CLUSTER_NAME="skills-cluster"
AWS_ACCOUNT_ID="362708816803"

# EKS Cluster
public_a=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=skills-public-a" --query "Subnets[].SubnetId[]" --region ap-northeast-2 --output text)
public_b=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=skills-public-b" --query "Subnets[].SubnetId[]" --region ap-northeast-2 --output text)
public_c=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=skills-public-c" --query "Subnets[].SubnetId[]" --region ap-northeast-2 --output text)
private_a=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=skills-private-a" --query "Subnets[].SubnetId[]" --region ap-northeast-2 --output text)
private_b=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=skills-private-b" --query "Subnets[].SubnetId[]" --region ap-northeast-2 --output text)
private_c=$(aws ec2 describe-subnets --filters "Name=tag:Name,Values=skills-private-c" --query "Subnets[].SubnetId[]" --region ap-northeast-2 --output text)

sed -i "s|public_a|$public_a|g" cluster.yaml
sed -i "s|public_b|$public_b|g" cluster.yaml
sed -i "s|public_c|$public_c|g" cluster.yaml
sed -i "s|private_a|$private_a|g" cluster.yaml
sed -i "s|private_b|$private_b|g" cluster.yaml
sed -i "s|private_c|$private_c|g" cluster.yaml

eksctl create cluster -f cluster.yaml

# Cluster Autoscaler
aws iam create-policy \
    --policy-name AmazonEKSClusterAutoscalerPolicy \
    --policy-document file://cluster-autoscaler-policy.json

eksctl create iamserviceaccount \
  --cluster=$EKS_CLUSTER_NAME \
  --namespace=kube-system \
  --name=cluster-autoscaler \
  --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/AmazonEKSClusterAutoscalerPolicy \
  --override-existing-serviceaccounts \
  --approve

kubectl apply -f cluster-auto-scaler.yaml

kubectl patch deployment cluster-autoscaler \
  -n kube-system \
  -p '{"spec":{"template":{"metadata":{"annotations":{"cluster-autoscaler.kubernetes.io/safe-to-evict": "false"}}}}}'

kubectl -n kube-system logs -f deployment.apps/cluster-autoscaler

kubectl get nodes

# Metrics Server for HPA
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# Calico
helm repo add projectcalico https://docs.tigera.io/calico/charts
helm repo update

cat > values.yaml << EOF
nodeSelector:
  eks.amazonaws.com/nodegroup: skills-addon
EOF

helm install calico projectcalico/tigera-operator --version v3.28.2 -f values.yaml

kubectl patch installation default --type='json' -p='[{"op": "replace", "path": "/spec/cni", "value": {"type":"Calico"} }]'

# AWS Load Balancer Controller
curl -O https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.7.2/docs/install/iam_policy.json

aws iam create-policy \
    --policy-name AWSLoadBalancerControllerIAMPolicy \
    --policy-document file://iam_policy.json

eksctl create iamserviceaccount \
  --cluster=$EKS_CLUSTER_NAME \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole \
  --attach-policy-arn=arn:aws:iam::$AWS_ACCOUNT_ID:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve

helm repo add eks https://aws.github.io/eks-charts
helm repo update eks
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$EKS_CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

kubectl get deployment -n kube-system aws-load-balancer-controller