#https://github.com/OpenShiftDemos/gogs-openshift-docker.git
mkdir gogs-persistent && cd gogs-persistent

oc new-project gogs --display-name="Persistent Git Repo"
oc adm policy add-role-to-user admin admin -n gogs

#oc new-app -f https://raw.githubusercontent.com/OpenShiftDemos/gogs-openshift-docker/master/openshift/gogs-template.yaml --param=HOSTNAME=gogs-ephemeral.apps.soshyant.local
wget https://raw.githubusercontent.com/OpenShiftDemos/gogs-openshift-docker/master/openshift/gogs-persistent-template.yaml 

- kind: PersistentVolumeClaim
  apiVersion: v1
  metadata:
    name: gogs-data
    labels:
      app: ${APPLICATION_NAME}
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: ${GOGS_VOLUME_CAPACITY}
    storageClassName: glusterfs-storage
- kind: PersistentVolumeClaim
  apiVersion: v1
  metadata:
    name: gogs-postgres-data
    labels:
      app: ${APPLICATION_NAME}
  spec:
    accessModes:
      - ReadWriteOnce
    resources:
      requests:
        storage: ${DB_VOLUME_CAPACITY}
    storageClassName: glusterfs-storage

oc new-app -f gogs-persistent-template.yaml --param=HOSTNAME=gogs-persistent.apps.soshyant.local 

* With parameters:
        * APPLICATION_NAME=gogs
        * HOSTNAME=gogs-persistent.apps.soshyant.local
        * GOGS_VOLUME_CAPACITY=1Gi
        * DB_VOLUME_CAPACITY=1Gi
        * Database Username=gogs
        * Database Password=gogs
        * Database Name=gogs
        * Database Admin Password=QjtBIkjQ # generated
        * Maximum Database Connections=100
        * Shared Buffer Amount=12MB
        * Gogs Version=0.9.97
        * Installation lock=true
        * Skip TLS verification on webhooks=false

#Create New Repo
