# Redirect (permanent) to https:
server {
    listen      80;
    server_name www.markhepburn.com markhepburn.com;
    return 301 https://markhepburn.com$request_uri;
}

# SSL settings from https://wiki.mozilla.org/Security/Server_Side_TLS#Modern_compatibility
# See also https://raymii.org/s/tutorials/Strong_SSL_Security_On_nginx.html
# Certificates obtained via Let's Encrypt (http://letsencrypt.readthedocs.org/en/latest/using.html)
server {
	listen 443 ssl;
    ssl on;

	server_name www.markhepburn.com markhepburn.com;

    ssl_certificate      /etc/letsencrypt/live/markhepburn.com/fullchain.pem;
    ssl_certificate_key  /etc/letsencrypt/live/markhepburn.com/privkey.pem;

    ssl_protocols TLSv1.1 TLSv1.2;
    ssl_ciphers 'AES256+EECDH:AES256+EDH:!aNULL';
    ssl_prefer_server_ciphers on;

    ssl_session_timeout 5m;
    ssl_session_cache shared:SSL:5m;

    # HSTS (ngx_http_headers_module is required) (15768000 seconds = 6 months)
    add_header Strict-Transport-Security max-age=15768000;
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;

    ssl_dhparam /etc/nginx/ssl/dhparam.pem;

    # OCSP Stapling ---
    # fetch OCSP records from URL in ssl_certificate and cache them
    ssl_stapling on;
    ssl_stapling_verify on;

    ## verify chain of trust of OCSP response using Root CA and Intermediate certs
    ssl_trusted_certificate /etc/ssl/private/startssl-ca-certs.pem;

    resolver 8.8.4.4 8.8.8.8 valid=300s;

	# Hack: http://wiki.nginx.org/UserDir
	location ~ ^/~(.+?)(/.*)?$ {
 		alias /home/$1/public_html$2;
	}

	location / {
		root /srv/www/markhepburn.com;
		index index.html;
	}
}
