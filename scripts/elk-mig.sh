#!/bin/bash
sudo apt update && sudo apt install elasticsearch mc -y

ES_HOSTS=$(echo $(gcloud compute instances list --filter='name ~ elastic*' --format 'csv[no-heading](INTERNAL_IP)' | awk '{ printf "\"%s\", ", $0 }'))
ES_HOSTNAME=$(hostname)
sudo cat << EOF > /etc/elasticsearch/elasticsearch.yml
# ======================== Elasticsearch Configuration =========================
#
# NOTE: Elasticsearch comes with reasonable defaults for most settings.
#       Before you set out to tweak and tune the configuration, make sure you
#       understand what are you trying to accomplish and the consequences.
#
# The primary way of configuring a node is via this file. This template lists
# the most important settings you may want to configure for a production cluster.
#
# Please consult the documentation for further information on configuration options:
# https://www.elastic.co/guide/en/elasticsearch/reference/index.html
#
# ---------------------------------- Cluster -----------------------------------
#
# Use a descriptive name for your cluster:
#
cluster.name: elastic-cluster
#
# ------------------------------------ Node ------------------------------------
#
# Use a descriptive name for the node:
#
node.name: $ES_HOSTNAME
#
# node.roles: [ master, data ]
#
# Add custom attributes to the node:
#
#node.attr.rack: r1
#
# ----------------------------------- Paths ------------------------------------
#
# Path to directory where to store the data (separate multiple locations by comma):
#
path.data: /var/lib/elasticsearch
#
# Path to log files:
#
path.logs: /var/log/elasticsearch
#
# ----------------------------------- Memory -----------------------------------
#
# Lock the memory on startup:
#
#bootstrap.memory_lock: true
#
# Make sure that the heap size is set to about half the memory available
# on the system and that the owner of the process is allowed to use this
# limit.
#
# Elasticsearch performs poorly when the system is swapping the memory.
#
# ---------------------------------- Network -----------------------------------
#
# By default Elasticsearch is only accessible on localhost. Set a different
# address here to expose this node on the network:
#
network.host: 0.0.0.0
#
# By default Elasticsearch listens for HTTP traffic on the first free port it
# finds starting at 9200. Set a specific HTTP port here:
#
http.port: 9200
#
# For more information, consult the network module documentation.
#
# --------------------------------- Discovery ----------------------------------
#
# Pass an initial list of hosts to perform discovery when this node is started:
# The default list of hosts is ["127.0.0.1", "[::1]"]
#
discovery.seed_hosts: [$ES_HOSTS]
#
# Bootstrap the cluster using an initial set of master-eligible nodes:
#
cluster.initial_master_nodes:  [$ES_HOSTS]
#
# For more information, consult the discovery and cluster formation module documentation.
#
# --------------------------------- Readiness ----------------------------------
#
# Enable an unauthenticated TCP readiness endpoint on localhost
#
#readiness.port: 9399
#
# ---------------------------------- Various -----------------------------------
#
# Allow wildcard deletion of indices:
#
#action.destructive_requires_name: false

#----------------------- BEGIN SECURITY AUTO CONFIGURATION -----------------------
#
# The following settings, TLS certificates, and keys have been automatically
# generated to configure Elasticsearch security features on 18-06-2022 09:29:53
#
# --------------------------------------------------------------------------------
# Enable security features
xpack.security.enabled: true

xpack.security.enrollment.enabled: true

# Enable encryption for HTTP API client connections, such as Kibana, Logstash, and Agents
xpack.security.http.ssl:
  enabled: true
  keystore.path: certs/http.p12
  verification_mode: none

# Enable encryption and mutual authentication between cluster nodes
xpack.security.transport.ssl:
  enabled: true
  verification_mode: none
  keystore.path: certs/transport.p12
  truststore.path: certs/transport.p12
# Create a new cluster with the current node only
# Additional nodes can still join the cluster later
# Allow HTTP API connections from anywhere
# Connections are encrypted and require user authentication
http.host: 0.0.0.0

# Allow other nodes to join the cluster from anywhere
# Connections are encrypted and mutually authenticated
transport.host: 0.0.0.0

#----------------------- END SECURITY AUTO CONFIGURATION -------------------------
EOF

# sudo /usr/share/elasticsearch/bin/elasticsearch-keystore remove xpack.security.http.ssl.keystore.secure_password
# sudo /usr/share/elasticsearch/bin/elasticsearch-keystore remove xpack.security.transport.ssl.keystore.secure_password
# sudo /usr/share/elasticsearch/bin/elasticsearch-keystore remove xpack.security.transport.ssl.truststore.secure_password

# sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service


# sudo tail -f /var/log/elasticsearch/elastic-cluster.log

# Authentication and authorization are enabled.
# TLS for the transport and HTTP layers is enabled and configured.

# The generated password for the elastic built-in superuser is : WV9m2NSTqXIzNnDhmLrg

# If this node should join an existing cluster, you can reconfigure this with
# '/usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token <token-here>'
# after creating an enrollment token on your existing cluster.

# You can complete the following actions at any time:

# Reset the password of the elastic built-in superuser with
# '/usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic'.

# Generate an enrollment token for Kibana instances with
#  '/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana'.

# Generate an enrollment token for Elasticsearch nodes with
# '/usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s node'.
