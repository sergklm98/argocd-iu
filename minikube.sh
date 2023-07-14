curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

minikube start

minikube dashboard &

kubectl create ns argocd
kubectl config set-context --current --namespace=argocd

helm repo add argo https://argoproj.github.io/argo-helm

helm upgrade -i -n argocd argocd argo/argo-cd --version 5.36.0 -f helm/charts/argo-cd/values.yaml
helm upgrade -i -n argocd argocd-apps argo/argocd-apps --version 1.2.0 -f helm/charts/argocd-apps/values.yaml

kubectl get pods
kubectl get apps

kubectl port-forward service/argocd-server 6443:443 >>port-forward.log &
echo admin:$(oc get secret/argocd-initial-admin-secret -o go-template --template="{{.data.password|base64decode}}")

kubectl port-forward -n default service/flask-sample 8080:80 >>port-forward.log 2>&1 &
curl localhost:8080

curl -L https://istio.io/downloadIstio | sh -
export PATH="$PATH:$PWD/istio-1.18.0/bin"
istioctl install --set profile=demo -y
kubectl label namespace default istio-injection=enabled

kubectl apply -f samples/bookinfo/platform/kube/bookinfo.yaml
kubectl apply -f samples/bookinfo/networking/bookinfo-gateway.yaml

# minikube delete