#! /bin/bash

cat > /etc/nginx/nginx.conf << EOF
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
        worker_connections 768;
        # multi_accept on;
}

stream {
  log_format basic '$remote_addr [$time_local] '
                   '$protocol $status $bytes_sent $bytes_received $server_port'
                   '$session_time';

  access_log  /var/log/nginx/stream_access.log basic;
  error_log  /var/log/nginx/stream_error.log debug;

  upstream rke2_servers {
    least_conn;
    server 192.168.56.11:9345 max_fails=3 fail_timeout=5s;
    server 192.168.56.12:9345 max_fails=3 fail_timeout=5s;
    server 192.168.56.13:9345 max_fails=3 fail_timeout=5s;
  }

  server {
    listen 9345;
    proxy_pass rke2_servers;
  }

  upstream k8s_api {
    least_conn;
    server 192.168.56.11:6443 max_fails=3 fail_timeout=5s;
    server 192.168.56.12:6443 max_fails=3 fail_timeout=5s;
    server 192.168.56.13:6443 max_fails=3 fail_timeout=5s;
  }

  server {
    listen 6443;
    proxy_pass k8s_api;
  }

  upstream k8s_http {
    least_conn;
    server 192.168.56.11:80 max_fails=3 fail_timeout=5s;
    server 192.168.56.12:80 max_fails=3 fail_timeout=5s;
    server 192.168.56.13:80 max_fails=3 fail_timeout=5s;
  }

  server {
    listen 80;
    proxy_pass k8s_http;
  }

  upstream k8s_https {
    least_conn;
    server 192.168.56.11:443 max_fails=3 fail_timeout=5s;
    server 192.168.56.12:443 max_fails=3 fail_timeout=5s;
    server 192.168.56.13:443 max_fails=3 fail_timeout=5s;
  }

  server {
    listen 443;
    proxy_pass k8s_https;
  }
}

EOF

apt update
apt install -y nginx net-tools