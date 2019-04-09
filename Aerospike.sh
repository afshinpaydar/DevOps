git clone https://github.com/travelaudience/aerospike-operator.git
cd aerospike-operator
oc create -f docs/examples/00-prereqs.yml
oc adm policy add-role-to-user admin admin -n aerospike-operator #It must show "aerospike-operator" project in openshift panel for admin user!
oc create -f docs/examples/10-aerospike-operator.yml
oc expose svc aerospike-operator
oc create -f docs/examples/20-aerospike-cluster.yml
