oc new-project tiller
oc adm policy add-role-to-user admin admin -n tiller
oc project tiller

#Local
export TILLER_NAMESPACE=tiller
curl -s https://storage.googleapis.com/kubernetes-helm/helm-v2.9.0-linux-amd64.tar.gz | tar xz
cd linux-amd64
./helm init --client-only

#Openshift
oc process -f https://github.com/openshift/origin/raw/master/examples/helm/tiller-template.yaml -p TILLER_NAMESPACE="${TILLER_NAMESPACE}" -p HELM_VERSION=v2.9.0 | oc create -f -
oc rollout status deployment tiller
./helm version


#Sample App
oc new-project afshinapp
oc policy add-role-to-user edit "system:serviceaccount:${TILLER_NAMESPACE}:tiller"
./helm install https://github.com/jim-minter/nodejs-ex/raw/helm/helm/nodejs-0.1.tgz -n nodejs-ex
