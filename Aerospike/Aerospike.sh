mkdir aerospike-broker-farabixo
cd aerospike-broker-farabixo
git clone https://github.com/aerospike/aerospike-kubernetes.git
cd aerospike-kubernetes/



export APP_NAME=broker
export NAMESPACE=aerospike-broker-farabixo
export AEROSPIKE_NODES=3
export AEROSPIKE_NAMESPACE=broker
export AEROSPIKE_REPL=2
export AEROSPIKE_MEM=1
export AEROSPIKE_TTL=0

cat manifests/* | envsubst > expanded.yaml

vim expanded.yaml
 storageClassName: glusterfs-storage


oc create -f expanded.yaml
oc project aerospike-broker-farabixo
oc create configmap aerospike-conf -n aerospike-broker-farabixo --from-file=configs/
oc adm policy add-role-to-user admin admin -n aerospike-broker-farabixo
oc adm policy add-scc-to-user anyuid -z default
 

vim service-expose.yaml
 
apiVersion: v1
kind: Service
metadata:
  labels:
    app: broker
  name: as-cluster-1
  selfLink: /api/v1/namespaces/aerospike-test/services/aerospike
  namespace: aerospike-broker-farabixo
spec:
  externalIPs:
    - 192.168.20.151
    - 192.168.20.152
    - 192.168.20.153
  ports:
    - name: service
      port: 3000
      protocol: TCP
      targetPort: 3000
  selector:
    app: broker

oc create -f service-expose.yaml








git clone https://github.com/travelaudience/aerospike-operator.git
cd aerospike-operator
vim +154 docs/examples/00-prereqs.yml

- apiGroups:
  - aerospike.travelaudience.com
  resources:
  - aerospikeclusters/finalizers
  - aerospikenamespacebackups/finalizers
  - aerospikenamespacerestores/finalizers
  verbs:
  - update

:x
vim +24  docs/examples/10-aerospike-operator.yml
  replicas: 1
:x

vim docs/examples/20-aerospike-cluster.yml
G

      storageClassName: glusterfs-storage
      

:x

oc new-project  aerospike-operator
oc adm policy add-scc-to-user anyuid -z default

oc create -f docs/examples/00-prereqs.yml
oc adm policy add-role-to-user admin admin -n aerospike-operator #It must show "aerospike-operator" project in openshift panel for admin user!
oc create -f docs/examples/10-aerospike-operator.yml
oc create -f docs/examples/20-aerospike-cluster.yml


oc get svc as-cluster-0 -o yaml | grep uid
    uid: 9a8f098d-6322-11e9-95f6-005056afc8ad


#change uid in service yaml file based on previous service
oc create -f service-expose.yaml

#ALL Nodes
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 3000 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 3002 -j ACCEPT



iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 9145 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 3002 -j ACCEPT


