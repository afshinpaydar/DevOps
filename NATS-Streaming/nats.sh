# git clone https://github.com/pires/kubernetes-nats-cluster

# oc new-project farabixo-nats-broker
# oc adm policy add-role-to-user admin admin -n farabixo-nats-broker
# cd kubernetes-nats-cluster/
# oc create configmap nats-config --from-file nats.conf
# openssl genrsa -out ca-key.pem 2048
# openssl req -x509 -new -nodes -key ca-key.pem -days 10000 -out ca.pem -subj "/CN=kube-ca"
# openssl genrsa -out nats-key.pem 2048
# openssl req -new -key nats-key.pem -out nats.csr -subj "/CN=kube-nats" -config ssl.cnf
# openssl x509 -req -in nats.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out nats.pem -days 3650 -extensions v3_req -extfile ssl.cnf

# oc create secret generic tls-nats-server --from-file nats.pem --from-file nats-key.pem --from-file ca.pem


# oc create secret generic tls-nats-client --from-file ca.pem
# oc create -f nats.yml
# oc expose svc nats


##########################################################
git clone https://github.com/nats-io/nats-streaming-operator.git
oc new-project farabixo-nats-stream-broker
oc adm policy add-role-to-user admin admin -n farabixo-nats-stream-broker
cd nats-streaming-operator
wget https://github.com/nats-io/nats-operator/releases/download/v0.4.3/00-prereqs.yaml
wget https://github.com/nats-io/nats-operator/releases/download/v0.4.3/10-deployment.yaml
wget https://raw.githubusercontent.com/nats-io/nats-streaming-operator/master/deploy/default-rbac.yaml
wget https://raw.githubusercontent.com/nats-io/nats-streaming-operator/master/deploy/deployment.yaml

change namespace to farabixo-nats-stream-broker
oc adm policy add-role-to-user admin system:serviceaccount:nats-io:nats-operator -n farabixo-nats-stream-broker
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:nats-io:nats-operator
oc adm policy add-cluster-role-to-user cluster-admin  natsstreamingclusters.streaming.nats.io

oc adm policy add-scc-to-user anyuid -z default


#ALL Nodes
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 8222 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 4222 -j ACCEPT

oc apply -f 00-prereqs.yaml
oc apply -f 10-deployment.yaml
oc apply -f  default-rbac.yaml 
oc apply -f  deployment.yaml

vim example-nats.yaml

apiVersion: "nats.io/v1alpha2"
kind: "NatsCluster"
metadata:
  name: "example-nats"
spec:
  size: 3

oc apply -f example-nats.yaml 

oc expose svc example-nats
oc expose svc  example-nats-mgmt


vim StreamingCluster.yaml

apiVersion: "streaming.nats.io/v1alpha1"
kind: "NatsStreamingCluster"
metadata:
  name: "example-stan"
  namespace: "farabixo-nats-stream-broker"
spec:
  size: 3
  natsSvc: "example-nats"


oc apply -f StreamingCluster.yaml
