FROM nginx:alpine
COPY /build /usr/share/nginx/html

RUN mkdir -p /var/cache/nginx /var/run/nginx \
    && chgrp -R 0 /var/cache/nginx /var/run/nginx /usr/share/nginx/html \
    && chmod -R g=u /var/cache/nginx /var/run/nginx /usr/share/nginx/html

COPY nginx.conf /etc/nginx/nginx.conf