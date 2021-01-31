FROM caddy:2.2.1-alpine

RUN apk update && apk add --no-cache tor ca-certificates curl unzip

ADD configure.sh /configure.sh

RUN chmod +x /configure.sh

CMD /configure.sh
