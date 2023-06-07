set -x

echo Pull images ###
kubeadm config images pull

echo Init cluster (first node) ###
kubeadm init --apiserver-advertise-address $(hostname -i) --pod-network-cidr 10.5.0.0/16

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

echo Wait start ###
kubectl get nodes -w
kubectl version

# echo Destroy cluster (node) ###
# kubeadm reset -f

echo Setup network ###
# kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml

echo Deploy dashboard ###
curl -L -s https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml | sed 's/targetPort: 8443/targetPort: 8443\n  type: LoadBalancer/' | kubectl apply -f -

echo Add Google DNS ###
kubectl get deployment --namespace=kube-system kube-dns -oyaml|sed -r 's,(.*--server)=(/ip6.arpa/.*),&\n\1=8.8.8.8,'|kubectl apply -f -

echo Grant dashboard admin access ###
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
kubectl label clusterrolebinding kubernetes-dashboard k8s-app=kubernetes-dashboard

echo Completion and other ###
cd
yum -q -y install bash-completion git-core tmux vim wget sudo which > /dev/null
kubectl completion bash > /etc/bash_completion.d/kubectl.completion
source /etc/bash_completion.d/kubectl.completion

echo Join command ###
echo kubeadm join --discovery-token-unsafe-skip-ca-verification --token $(kubeadm token list |sed -n 2p|egrep -o '^\S+') $(sed -rn s,.*server:.*//,,p /etc/kubernetes/admin.conf)
