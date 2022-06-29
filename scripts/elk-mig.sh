#!/bin/bash
sudo apt update && sudo apt install elasticsearch mc -y
yes | sudo /usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token $(gcloud secrets versions access latest --secret="node-token")
sudo systemctl start elasticsearch.service
echo -n $(sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node) | gcloud secrets versions add node-token --data-file=-
echo -n $(yes | sudo /usr/share/elasticsearch/bin/elasticsearch-reset-password -u logstash_system) | awk '{print $NF}' - | gcloud secrets versions add logstash-pass --data-file=-