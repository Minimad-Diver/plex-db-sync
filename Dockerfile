FROM alpine
MAINTAINER NOSPAM <nospam@nnn.nnn>

COPY docker.sh /docker.sh
COPY plex-db-sync /plex-db-sync

ENV BACKUP=false \
    DEBUG=false \
    INITIALRUN=false \
    DRYRUN=false \
    CRON="0 4 * * *" \
    REMOTE_SSH_KEY=/sshkey \
    REMOTE_SSH_USER=root \
    REMOTE_SSH_HOST=hostname \
    REMOTE_SSH_PORT=22 \
    REMOTE_DB_PATH="/opt/appdata/plex/database/Library/Application Support/Plex Media Server/Plug-in Support/Databases" \
    REMOTE_STOP="docker stop plex" \
    REMOTE_START="docker start plex" \
    LOCAL_PATH_IS_SSH=false \
    LOCAL_PLEX_NAME=plex \
    LOCAL_DB_PATH=/mnt/DB2 \
    LOCAL_STOP='curl --unix-socket /var/run/docker.sock -X POST http://localhost/containers/plex/stop' \
    LOCAL_START='curl --unix-socket /var/run/docker.sock -X POST http://localhost/containers/plex/start'
    
         
RUN chmod a+x /docker.sh /plex-db-sync

RUN apk add --update \
    curl \
    bash \
    sshfs \
    sqlite \
    openssh-client \
    apk-cron \
    && rm -rf /var/cache/apk/*

CMD ["/docker.sh"]
