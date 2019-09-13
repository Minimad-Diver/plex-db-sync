FROM alpine
MAINTAINER NOSPAM <nospam@nnn.nnn>

COPY docker.sh /docker.sh
COPY plex-db-sync /plex-db-sync

ENV BACKUP=false \
    DEBUG=false \
    INITIALRUN=false \
    DRYRUN=false \
    LOCAL_PLEX_NAME=plex \
    CRON=0 4 * * * \
    REMOTE_SSH_KEY=/sshkey \
    REMOTE_SSH_USER=root \
    REMOTE_SSH_HOST=hostname \
    REMOTE_SSH_PATH=/opt/appdata/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases \
    REMOTE_STOP=ssh -oStrictHostKeyChecking=no -i /sshkey root@hostname 'docker stop plex' \
    REMOTE_START=ssh -oStrictHostKeyChecking=no -i /sshkey root@hostname 'docker start plex' \
    LOCAL_DB_PATH=/mnt/DB2 \
    LOCAL_STOP='curl --unix-socket /var/run/docker.sock -X POST /containers/plex/stop' \
    LOCAL_START='curl --unix-socket /var/run/docker.sock -X POST /containers/plex/start'    
    
VOLUME  /etc/localtime:/etc/localtime:ro \
        /opt/appdata/plex-db-sync/sshkey:/sshkey \
        /docker/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/:/mnt/DB2 \
        /var/run/docker.sock:/var/run/docker.sock
     
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
