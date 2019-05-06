mkdir socketcluster
cd socketcluster
git clone https://github.com/SocketCluster/socketcluster.git
oc new-project socketcluster --display-name="SocketCluster"
oc adm policy add-role-to-user admin admin -n socketcluster
cd socketcluster/kubernetes/
oc create -f scc-broker-service.yaml
oc create -f scc-ingress.yaml
oc create -f scc-state-deployment.yaml
oc create -f scc-broker-deployment.yaml
oc create -f scc-state-service.yaml
oc adm policy add-scc-to-user anyuid -z default

oc create -f socketcluster-deployment.yaml
oc create -f  socketcluster-service.yaml


iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 8000 -j ACCEPT
service iptables save


cat service-expose.yml 
apiVersion: v1
kind: Service
metadata:
  name: socketcluster-1
  namespace: socketcluster
  resourceVersion: "2267495"
  selfLink: /api/v1/namespaces/socketcluster/services/socketcluster
  uid: eeeca7f1-6efa-11e9-b98c-005056af32be
spec:
  externalIPs:
    - 192.168.20.151
    - 192.168.20.152
    - 192.168.20.153
  ports:
    - name: service
      port: 8000
      protocol: TCP
      targetPort: 8000
  selector:
    component: socketcluster

oc create -f service-expose.yml
oc expose svc socketcluster


