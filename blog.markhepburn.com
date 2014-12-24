# redirect to github hosted blog (can't just use a CNAME)
server {
	listen 80;
	server_name blog.markhepburn.com;
	return 301 $scheme://blog.everythingtastesbetterwithchilli.com$request_uri;
}
