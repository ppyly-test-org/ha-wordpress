#!/bin/bash
sudo -u pashkadez gcsfuse --implicit-dirs -o allow_other terraform-wordpress-bucket-123456789 /mnt/wordpress/
sudo ln -s /mnt/wordpress /var/www/
sudo systemctl reload apache2
sudo filebeat modules enable apache
 cat << EOF > /etc/filebeat/modules.d/apache.yml
- module: apache
  access:
    enabled: true
    var.paths: [/var/log/apache2/access.log*]
  error:
    enabled: true
    var.paths: [/var/log/apache2/error.log*]
EOF


KIBANA_HOST=$(gcloud compute instances list --filter='name ~ kibana*' --format 'csv[no-heading](INTERNAL_IP)')
LOGSTASH_HOSTS=$(gcloud compute instances list --filter='name ~ logstash*' --format 'csv[no-heading](INTERNAL_IP)' | awk '{ printf "\"%s:5044\", ", $0 }' | awk '{ print substr( $0, 1, length($0)-2 ) }')
ES_PASS=$(gcloud secrets versions access latest --secret='elastic-pass')
cat << EOF > /etc/filebeat/filebeat.yml
filebeat.inputs:
- type: filestream
  id: my-filestream-id
  enabled: false
  paths:
    - /var/log/*.log

filebeat.config.modules:
  path: \${path.config}/modules.d/*.yml
  reload.enabled: true
  reload.period: 10s


setup.template.settings:
  index.number_of_shards: 1

setup.kibana:
  host: "${KIBANA_HOST}:5601"
  username: "elastic"
  password: "${ES_PASS}"

output.logstash:
  hosts: [${LOGSTASH_HOSTS}]

processors:
  - add_host_metadata:
      when.not.contains.tags: forwarded
  - add_cloud_metadata: ~
  - add_docker_metadata: ~
  - add_kubernetes_metadata: ~
EOF

sudo systemctl start filebeat.service