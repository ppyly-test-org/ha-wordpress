#!/bin/bash
sudo apt update && sudo apt install elasticsearch mc -y

ES_HOSTS=$(echo $(gcloud compute instances list --filter='name ~ elastic*' --format 'csv[no-heading](INTERNAL_IP)' | awk '{ printf "\"%s\", ", $0 }'))
ES_HOSTNAME=$(hostname)
sudo cat << EOF > /etc/elasticsearch/elasticsearch.yml
path.data: /var/lib/elasticsearch
path.logs: /var/log/elasticsearch
network.host: 0.0.0.0
http.port: 9200
discovery.seed_hosts: [$ES_HOSTS]
cluster.initial_master_nodes:  [$ES_HOSTNAME]
xpack.security.enabled: true

xpack.security.enrollment.enabled: true

xpack.security.http.ssl:
  enabled: true
  keystore.path: certs/http.p12

xpack.security.transport.ssl:
  enabled: true
  verification_mode: certificate
  keystore.path: certs/transport.p12
  truststore.path: certs/transport.p12

http.host: 0.0.0.0
transport.host: 0.0.0.0
EOF

sudo systemctl start elasticsearch.service
echo -n $(sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node) | gcloud secrets versions add node-token --data-file=-
sudo gcloud secrets versions add elastic-ca --data-file=/etc/elasticsearch/certs/http_ca.crt
echo -n $(yes | sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic) | awk '{print $NF}' - | gcloud secrets versions add elastic-pass --data-file=-

# sudo tail -f /var/log/elasticsearch/elasticsearch.log

