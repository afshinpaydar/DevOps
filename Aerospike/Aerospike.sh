git clone https://github.com/travelaudience/aerospike-operator.git
cd aerospike-operator
vim +154 docs/examples/00-prereqs.yml
O
- apiGroups:
  - aerospike.travelaudience.com
  resources:
  - aerospikeclusters/finalizers
  - aerospikenamespacebackups/finalizers
  - aerospikenamespacerestores/finalizers
  verbs:
  - updateO

:x
vim +24  docs/examples/10-aerospike-operator.yml
  replicas: 1
:x

vim docs/examples/20-aerospike-cluster.yml
G

      storageClassName: glusterfs-storage
      accessModes: ReadWriteMany

:x

oc new-project  aerospike-operator
oc adm policy add-scc-to-user anyuid -z default

oc create -f docs/examples/00-prereqs.yml
oc adm policy add-role-to-user admin admin -n aerospike-operator #It must show "aerospike-operator" project in openshift panel for admin user!
oc create -f docs/examples/10-aerospike-operator.yml
oc create -f docs/examples/20-aerospike-cluster.yml

#ALL Nodes
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 3000 -j ACCEPT

