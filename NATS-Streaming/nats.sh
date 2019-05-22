git clone https://github.com/nats-io/nats-streaming-operator.git
oc new-project farabixo-nats-stream-broker
oc new-project mdp-nats --display-name="MDP Nats" 

oc adm policy add-role-to-user admin admin -n farabixo-nats-stream-broker
oc adm policy add-role-to-user admin admin -n mdp-nats
cd nats-streaming-operator
wget https://github.com/nats-io/nats-operator/releases/download/v0.4.3/00-prereqs.yaml
wget https://github.com/nats-io/nats-operator/releases/download/v0.4.3/10-deployment.yaml
wget https://raw.githubusercontent.com/nats-io/nats-streaming-operator/master/deploy/default-rbac.yaml
wget https://raw.githubusercontent.com/nats-io/nats-streaming-operator/master/deploy/deployment.yaml

oc project farabixo-nats-stream-broker
oc project mdp-nats

oc adm policy add-role-to-user admin admin -n mdp-nats


#### Beter to use this :
####oc adm policy add-scc-to-user anyuid -z  <serviceaccount that hasn't RBAC>
oc adm policy add-scc-to-user anyuid -z default
oc adm policy add-scc-to-user anyuid -z nats-operator
oc adm policy add-scc-to-user anyuid -z nats-streaming-operator
#oc adm policy add-role-to-user admin system:serviceaccount:nats-io:nats-operator -n farabixo-nats-stream-broker
!oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:farabixo-nats-stream-broker:nats-operator
!oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:mdp-nats:nats-operator

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
  name: "farabixo-nats"
spec:
  size: 3

oc apply -f example-nats.yaml 

oc expose svc farabixo-nats
oc expose svc  farabixo-nats-mgmt

oc expose svc mdp-nats
oc expose svc mdp-nats-mgmt



vim StreamingCluster.yaml

apiVersion: "streaming.nats.io/v1alpha1"
kind: "NatsStreamingCluster"
metadata:
  name: "farabixo-stan"
  namespace: "farabixo-nats-stream-broker"
spec:
  size: 3
  natsSvc: "farabixo-nats"


oc apply -f StreamingCluster.yaml


vim service-expose.yaml

apiVersion: v1
kind: Service
metadata:
  labels:
    app: nats
    nats_cluster: farabixo-nats
  name: farabixo-nats-1
  namespace: farabixo-nats-stream-broker
  ownerReferences:
    - apiVersion: nats.io/v1alpha2
      controller: true
      kind: NatsCluster
      name: farabixo-nats
      uid: 4d21758d-64f7-11e9-bea0-005056af2f60
spec:
  externalIPs:
    - 192.168.110.134
    - 192.168.110.135
    - 192.168.110.136
  ports:
    - name: client
      port: 4222
      protocol: TCP
      targetPort: 4222
  selector:
    nats_cluster: farabixo-nats

oc create -f service-expose.yaml