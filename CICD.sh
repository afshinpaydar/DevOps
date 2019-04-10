git clone https://github.com/openshift/origin.git
cd origin
vim examples/jenkins/jenkins-persistent-template.json
/"kind": "PersistentVolumeClaim",

#            "apiVersion": "v1",
#            "kind": "PersistentVolumeClaim",
#            "metadata": {
#                "name": "${JENKINS_SERVICE_NAME}"
#            },
#            "spec": {
#                "accessModes": [
#                    "ReadWriteOnce"
#                ],
#                "resources": {
#                    "requests": {
#                        "storage": "${VOLUME_CAPACITY}"
#                    }
#                },
#                "storageClassName": "glusterfs-storage"

#oc delete templates jenkins-persistent -n openshift
oc apply -f examples/jenkins/jenkins-persistent-template.json -n openshift
#Check 
oc edit templates jenkins-persistent -n openshift -o json
/"kind": "PersistentVolumeClaim",



#oc get   templates -n openshift
#oc edit templates jenkins-persistent -n openshift
#/kind: PersistentVolumeClaim
#Add '    storageClassName: glusterfs-storage' below resources:
#- apiVersion: v1
#  kind: PersistentVolumeClaim
#  metadata:
#    name: ${JENKINS_SERVICE_NAME}
#  spec:
#    accessModes:
#    - ReadWriteOnce
#    resources:
#      requests:
#        storage: ${VOLUME_CAPACITY}
#    storageClassName: glusterfs-storage

#:x

oc new-project jenkins-persistent --description="CI/CD project" --display-name="Jenkins"

oc new-app -e \
    JENKINS_PASSWORD=admin1234 \
    INSTALL_PLUGINS=tfs\
    OVERRIDE_PV_PLUGINS_WITH_IMAGE_PLUGINS=true \
    jenkins-persistent
#check environment that passed to pod!
#oc exec jenkins-1-7ktbb -it -- env | grep INSTALL_PLUGINS
#oc exec jenkins-1-t45wx -it -- env | grep MEMORY_LIMIT
#oc exec jenkins-1-t45wx -it -- env | grep MEMORY_REQUEST

oc adm policy add-role-to-user admin admin -n jenkins-persistent

#Update /etc/hosts for dns resolve FQDN
oc get route 
#Browse to route
