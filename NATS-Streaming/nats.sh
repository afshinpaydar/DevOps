git clone https://github.com/nats-io/nats-streaming-operator.git
oc new-project farabixo-nats-stream-broker
oc adm policy add-role-to-user admin admin -n farabixo-nats-stream-broker
cd nats-streaming-operator
wget https://github.com/nats-io/nats-operator/releases/download/v0.4.3/00-prereqs.yaml
wget https://github.com/nats-io/nats-operator/releases/download/v0.4.3/10-deployment.yaml
wget https://raw.githubusercontent.com/nats-io/nats-streaming-operator/master/deploy/default-rbac.yaml
wget https://raw.githubusercontent.com/nats-io/nats-streaming-operator/master/deploy/deployment.yaml

oc project farabixo-nats-stream-broker
#oc adm policy add-role-to-user admin system:serviceaccount:nats-io:nats-operator -n farabixo-nats-stream-broker
#oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:nats-io:nats-operator
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
