oc project emc
oc apply -f redis-master-deployment.yaml
oc apply -f redis-master-service.yaml
oc expose svc redis-master
oc get route
redis-cli -h redis-master-emc.apps.snt.local -p 80