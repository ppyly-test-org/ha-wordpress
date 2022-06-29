#!/bin/bash

sudo gcloud secrets versions access latest --secret="elastic-ca" > /etc/logstash/http_ca.crt
sudo chmod 777 /etc/logstash/http_ca.crt
ES_HOSTS=$(gcloud compute instances list --filter='name ~ elastic*' --format 'csv[no-heading](INTERNAL_IP)' | awk '{ printf "\"https://%s:9200\", ", $0 }' | awk '{ print substr( $0, 1, length($0)-2 ) }')
ES_PASS=$(gcloud secrets versions access latest --secret='elastic-pass')
cat << EOF > /etc/logstash/conf.d/beats.conf
input {
  beats {
    port => 5044
  }
}

output {
  elasticsearch {
    index => 'apache-%{+YYYY.MM.dd}'
    hosts => [$ES_HOSTS]
    ssl => true
    cacert => '/etc/logstash/http_ca.crt'
    user => 'elastic'
    password => '$ES_PASS'
  }
}
EOF

sudo systemctl start logstash.service