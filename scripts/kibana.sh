# #!/bin/bash

sudo apt update && sudo apt install elasticsearch mc -y
yes | sudo /usr/share/elasticsearch/bin/elasticsearch-reconfigure-node --enrollment-token $(gcloud secrets versions access latest --secret="node-token")

sudo cat << EOF >> /etc/elasticsearch/elasticsearch.yml
node.roles: [ ]
EOF

sudo systemctl start elasticsearch.service
echo -n $(sudo /usr/share/elasticsearch/bin/elasticsearch-create-enrollment-token -s kibana) | gcloud secrets versions add kibana-token --data-file=-
sudo /usr/share/kibana/bin/kibana-setup -t $(gcloud secrets versions access latest --secret="kibana-token")

sudo cat << EOF >> /etc/kibana/kibana.yml
server.port: 5601
server.host: "0.0.0.0"
EOF

sudo systemctl start kibana.service

(cd /opt && wget https://github.com/oauth2-proxy/oauth2-proxy/releases/download/v7.2.0/oauth2-proxy-v7.2.0.linux-amd64.tar.gz)
(cd /opt && tar -xzf oauth2-proxy-v7.2.0.linux-amd64.tar.gz)

COOKIE=$(openssl rand -base64 16)
GH_CLIENT_ID=$(gcloud secrets versions access latest --secret='gh-client-id')
GH_SECRET=$(gcloud secrets versions access latest --secret='gh-secret')
sudo cat << EOF > /opt/oauth2-proxy-v7.2.0.linux-amd64/start.sh
#!/bin/sh
/opt/oauth2-proxy-v7.2.0.linux-amd64/oauth2-proxy \\
--email-domain=*  \\
--http-address="http://127.0.0.1:2345"  \\
--upstream="https://kibana.ppyly.pp.ua" \\
--redirect-url="https://kibana.ppyly.pp.ua/oauth2/callback" \\
--cookie-secret="$COOKIE" \\
--cookie-secure=false \\
--provider=github \\
--client-id="$GH_CLIENT_ID" \\
--client-secret="$GH_SECRET"

EOF
sudo chmod +x /opt/oauth2-proxy-v7.2.0.linux-amd64/start.sh

sudo cat << EOF > /etc/systemd/system/oauth2.service
[Unit]
Description=oauth2 service
After=network.target
StartLimitIntervalSec=0
[Service]
WorkingDirectory=/opt/oauth2-proxy-v7.2.0.linux-amd64/
ExecStart=/opt/oauth2-proxy-v7.2.0.linux-amd64/start.sh
[Install]
WantedBy=multi-user.target
EOF

sudo apt install -y nginx
mkdir /etc/nginx/ssl
openssl req -newkey rsa:4096 \
            -x509 \
            -sha256 \
            -days 3650 \
            -nodes \
            -out /etc/nginx/ssl/certificate.crt \
            -keyout /etc/nginx/ssl/private.key \
            -subj "/C=UA/ST=Volyn/L=NV/O=Security/OU=IT/CN=kibana.ppyly.pp.ua"

sudo chmod 655 /etc/nginx/ssl -R

sudo cat << EOF > /etc/nginx/nginx.conf
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
}
http {
        sendfile on;
        tcp_nopush on;
        tcp_nodelay on;
        keepalive_timeout 65;
        types_hash_max_size 2048;
        include /etc/nginx/mime.types;
        default_type application/octet-stream;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3; # Dropping SSLv3, ref: POODLE
        ssl_prefer_server_ciphers on;
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
        gzip on;
        include /etc/nginx/conf.d/*.conf;
}
EOF


sudo cat << "EOF" > /etc/nginx/conf.d/kibana.conf
server {
        listen 80 default_server;
        listen [::]:80 default_server;
        server_name kibana.ppyly.pp.ua;2345
        rewrite ^ https://$server_name$request_uri? permanent;
}

server {
        listen 443 ssl default_server;
        listen [::]:443 ssl default_server;
        server_name kibana.ppyly.pp.ua;
        ssl_certificate     /etc/nginx/ssl/certificate.crt;
        ssl_certificate_key /etc/nginx/ssl/private.key;
        ssl_prefer_server_ciphers on;
        ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers kEECDH+AES128:kEECDH:kEDH:-3DES:kRSA+AES128:kEDH+3DES:DES-CBC3-SHA:!RC4:!aNULL:!eNULL:!MD5:!EXPORT:!LOW:!SEED:!CAMELLIA:!IDEA:!PSK:!SRP:!SSLv2;
        ssl_session_cache    shared:SSL:64m;
        ssl_session_timeout  24h;
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains;";
        add_header Content-Security-Policy-Report-Only "default-src https:; script-src https: 'unsafe-eval' 'unsafe-inline'; style-src https: 'unsafe-inline'; img-src https: data:; font-src https: data:; report-uri /csp-report";
        location /oauth2/ {
                proxy_pass       http://127.0.0.1:2345;
                proxy_set_header Host                    $host;
                proxy_set_header X-Real-IP               $remote_addr;
                proxy_set_header X-Scheme                $scheme;
                proxy_set_header X-Auth-Request-Redirect $request_uri;
        }
        location = /oauth2/auth {
                proxy_pass       http://127.0.0.1:2345;
                proxy_set_header Host             $host;
                proxy_set_header X-Real-IP        $remote_addr;
                proxy_set_header X-Scheme         $scheme;
                proxy_set_header Content-Length   "";
                proxy_pass_request_body           off;
        }
        location / {
                auth_request /oauth2/auth;
                error_page 401 = /oauth2/sign_in;
                auth_request_set $user   $upstream_http_x_auth_request_user;
                auth_request_set $email  $upstream_http_x_auth_request_email;
                proxy_set_header X-User  $user;
                proxy_set_header X-Email $email;
                auth_request_set $auth_cookie $upstream_http_set_cookie;
                add_header Set-Cookie $auth_cookie;
                proxy_pass http://127.0.0.1:5601;
        }
}

EOF
sudo systemctl start oauth2.service
sudo systemctl start nginx.service