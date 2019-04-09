
oc get   templates -n openshift
oc edit templates jenkins-persistent -n openshift
/kind: PersistentVolumeClaim
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

:x

oc new-project jenkins-persistent --description="CI/CD project" --display-name="Jenkins"

oc new-app -e \
    OPENSHIFT_ENABLE_OAUTH=true \
    JENKINS_PASSWORD=<Password> \
    INSTALL_PLUGINS=tfs,slack\
    OVERRIDE_PV_PLUGINS_WITH_IMAGE_PLUGINS=true \
    jenkins-persistent
#check environment that passed to pod!
#oc exec jenkins-1-7ktbb -it -- env | grep INSTALL_PLUGINS

oc adm policy add-role-to-user admin admin -n jenkins-persistent

#Update /etc/hosts for dns resolve FQDN
oc get route 
#Browse to route
