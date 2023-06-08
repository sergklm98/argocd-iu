curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

minikube start

minikube dashboard &

sudo install tools/oc /usr/local/bin/oc
sudo cp tools/oc_completion /etc/bash_completion.d/
source /etc/bash_completion.d/oc_completion

oc version

oc create ns argocd
kubectl config set-context --current --namespace=argocd
oc apply -f infra/ArgoCD.yaml
oc apply -f infra/ArgoCDimageUpdater.yaml
oc apply -f infra/App.yaml

oc port-forward service/argocd-server 6443:443 >>port-forward.log 2>&1
oc port-forward -n default service/flask-sample 8080:80 >>port-forward.log 2>&1

echo admin:$(oc get secret/argocd-initial-admin-secret -o go-template --template="{{.data.password|base64decode}}")

# minikube delete