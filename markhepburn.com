server {
	listen 80;
	server_name www.markhepburn.com markhepburn.com;

	# Hack: http://wiki.nginx.org/UserDir
	location ~ ^/~(.+?)(/.*)?$ {
 		alias /home/$1/public_html$2;
	}

	location / {
		root /srv/www/markhepburn.com;
		index index.html;
	}
}
