git clone 
oc new-project redis --display-name="Redis for EMC Project"
oc adm policy add-role-to-user admin admin -n redis
cd redis-openshift/
oc create -f  openshift/is-base.yaml
oc create -f  list.yaml
oc start-build redis-build



