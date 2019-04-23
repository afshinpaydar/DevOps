#On VPN Server:
docker pull docker.elastic.co/elasticsearch/elasticsearch-oss:6.4.3
docker pull docker.elastic.co/kibana/kibana-oss:6.4.3
docker pull docker.elastic.co/logstash/logstash-oss:6.4.3

docker save docker.elastic.co/elasticsearch/elasticsearch-oss:6.4.3 -o /tmp/elasticsearch-oss.tar
docker save docker.elastic.co/kibana/kibana-oss:6.4.3 -o /tmp/kibana-oss.tar
docker save docker.elastic.co/logstash/logstash-oss:6.4.3 /tmp/logstash-oss.tar

scp /tmp/elasticsearch-oss.tar soshya-openshift-node1:/tmp/ 
scp /tmp/elasticsearch-oss.tar soshya-openshift-node2:/tmp/ 
scp /tmp/elasticsearch-oss.tar soshya-openshift-node3:/tmp/ 

scp /tmp/kibana-oss.tar soshya-openshift-node1:/tmp/ 
scp /tmp/kibana-oss.tar soshya-openshift-node2:/tmp/ 
scp /tmp/kibana-oss.tar soshya-openshift-node3:/tmp/

scp /tmp/logstash-oss.tar soshya-openshift-node1:/tmp/
scp /tmp/logstash-oss.tar soshya-openshift-node2:/tmp/
scp /tmp/logstash-oss.tar soshya-openshift-node3:/tmp/
#On All Nodes
docker load -i /tmp/elasticsearch-oss.tar
docker load -i /tmp/kibana-oss.tar
docker load -i /tmp/logstash-oss.tar
#On Master Node
oc new-project elasticsearch --display-name="ELK Project"
oc adm policy add-role-to-user admin admin -n elasticsearch
oc adm policy add-scc-to-user anyuid -z default
oc create serviceaccount  privilegeduser
oc adm policy add-scc-to-user privileged -nelasticsearch -z privilegeduser
oc adm policy add-scc-to-user privileged -nelasticsearch -z default
oc create -f elastic-svc.yaml
oc create -f elastic-app.yaml

#Check
oc get svc
oc get pod
oc port-forward es-cluster-0 9200:9200 &
curl localhost:9200
#Handling connection for 9200
# {
#   "name" : "es-cluster-0",
#   "cluster_name" : "px-elk-demo",
#   "cluster_uuid" : "DfyBasqmR_OtIGoEiEChKg",
#   "version" : {
#     "number" : "6.4.3",
#     "build_flavor" : "oss",
#     "build_type" : "tar",
#     "build_hash" : "fe40335",
#     "build_date" : "2018-10-30T23:17:19.084789Z",
#     "build_snapshot" : false,
#     "lucene_version" : "7.4.0",
#     "minimum_wire_compatibility_version" : "5.6.0",
#     "minimum_index_compatibility_version" : "5.0.0"
#   },
#   "tagline" : "You Know, for Search"
# }

#need jq 'yum install jq'
curl -s localhost:9200/_nodes | jq ._nodes

fg
#Cntl+C
oc expose svc elasticsearch

#KIBANA
oc create -f kibana-svc.yaml
oc create -f kibana-app.yaml
oc expose svc kibana

#LOGSTASH
#Later must save all config to config file and edit logstash.yaml to mount configmap instead !!!
#oc create configmap logstash-config --from-file=config/logstash.conf
oc create -f logstash.yaml
oc expose svc logstash
oc get route


#Test from local host (import log to logstash):
#wget https://raw.githubusercontent.com/elastic/examples/master/Common%20Data%20Formats/nginx_json_logs/nginx_json_logs
#curl -v -H "content-type: application/json" http://logstash-elasticsearch.apps.soshyant.local -d @'/tmp/nginx_json_logs'

curl -O https://download.elastic.co/demos/kibana/gettingstarted/7.x/shakespeare.json
curl -O https://download.elastic.co/demos/kibana/gettingstarted/7.x/accounts.zip
curl -O https://download.elastic.co/demos/kibana/gettingstarted/7.x/logs.jsonl.gz