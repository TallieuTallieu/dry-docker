FROM alpine:latest

RUN apk add --update openssh-client && rm -rf /var/cache/apk/*

CMD ssh \
    -fN -L 0.0.0.0:5432:localhost:5432 $REMOTE_USER@$REMOTE_HOST \
    && while true; do sleep 30; done;
EXPOSE 5432

