# plex-db-sync
Synchronizes the database watched status between two Plex servers. This includes watched times, and works for all users on the system without the need for tokens.

This is a fork of the Fmstrat/plex-db-sync with focus specifically on Docker usage.

## Deployment

Docker deployment examples. 

### Docker
The following example is for docker. It assumes you are running one Plex server locally (via Docker container), and another remotely (also via Docker container). Use `--privileged` if presented with "permssion denied" errors when mounting the remote host. _Note: Paths are default to [PGBlitz](https://github.com/PGBlitz/PGBlitz.com)._

```
docker run -d \
--name=plex-db-sync \
--hostname=plex-db-sync \
--restart=unless-stopped \
--device /dev/fuse \
--cap-add SYS_ADMIN \
--security-opt apparmor:unconfined \
-e BACKUP=false \
-e DEBUG=false \
-e INITIALRUN=false \
-e DRYRUN=false \
-e CRON="0 4 * * *" \
-e REMOTE_SSH_KEY=/sshkey \
-e REMOTE_SSH_USER=root \
-e REMOTE_SSH_HOST=hostname \
-e REMOTE_SSH_PORT=22 \
-e REMOTE_DB_PATH="/opt/appdata/plex/database/Library/Application Support/Plex Media Server/Plug-in Support/Databases" \
-e REMOTE_STOP="docker stop plex" \
-e REMOTE_START="docker start plex" \
-e LOCAL_PATH_IS_SSH=false \
-e LOCAL_PLEX_NAME=plex \
-e LOCAL_DB_PATH="/mnt/DB2" \
-e LOCAL_STOP="'curl --unix-socket /var/run/docker.sock -X POST http://localhost/containers/plex/stop'" \
-e LOCAL_START="'curl --unix-socket /var/run/docker.sock -X POST http://localhost/containers/plex/start'" \
-v "/home/user/.ssh/id_rsa:/sshkey" \
-v "/opt/appdata/plex/database/Library/Application Support/Plex Media Server/Plug-in Support/Databases:/mnt/DB2" \
-v "/var/run/docker.sock:/var/run/docker.sock" \
-v "/etc/localtime:/etc/localtime:ro" \
lusky3/plex-db-sync
```

### Docker-compose
The following example is for docker-compose. It assumes you are running one Plex server locally (via Docker container), and another remotely (also via Docker container).

```
version: '2'

services:

  plex-db-sync:
    image: lusky3/plex-db-sync
    container_name: plex-db-sync
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./plex-db-sync/sshkey:/sshkey
      - /docker/plex/database/Library/Application Support/Plex Media Server/Plug-in Support/Databases/:/mnt/DB2
      - /var/run/docker.sock:/var/run/docker.sock
    cap_add:
      - SYS_ADMIN
    devices:
      - /dev/fuse
    security_opt:
      - apparmor:unconfined
    environment:
      - CRON=0 4 * * *
      - REMOTE_SSH_KEY=/sshkey
      - REMOTE_SSH_USER=root
      - REMOTE_SSH_HOST=hostname
      - REMOTE_SSH_PORT=22
      - REMOTE_DB_PATH=/docker/plex/database/Library/Application Support/Plex Media Server/Plug-in Support/Databases
      - REMOTE_START==cd /docker; docker-compose up -d plex
      - REMOTE_STOP=cd /docker; docker-compose stop plex
      - LOCAL_PLEX_NAME=plex
      - LOCAL_PATH_IS_SSH=false
      - LOCAL_DB_PATH=/mnt/DB2
      - LOCAL_START=cd /docker; docker-compose up -d plex
      - LOCAL_STOP=cd /docker; docker-compose stop plex
    restart: always
```

## Options

Docker Variable | Description  |  Default
--------------- | -----------  | --------  
`BACKUP` | Create a backup of the DB before running any SQL.  |  false  
`DEBUG` | Print debug output.  |  false  
`DRYRUN` | Don't apply changes to the DB.  |  false  
`LOCAL_PATH_IS_SSH` | Also handle the Local DB as a Remote SSH host. (wip) |  false  
`LOCAL_PLEX_NAME`  |  The name of your Plex docker container |  plex  
`LOCAL_DB_PATH` | Location of the server's DB.  |  /mnt/DB2  
`LOCAL_START` | The command to start the Plex server.  |  curl --unix-socket /var/run/docker.sock -X POST http://localhost/containers/plex/start    
`LOCAL_STOP` | The command to stop the Plex server.  |  curl --unix-socket /var/run/docker.sock -X POST http://localhost/containers/plex/stop  
n/a | Don't compare version db of Plex server.  |  
`CRON` | A string that defines when the script should run in crond (Default is 4AM).  |  0 4 * * *  
`INITIALRUN` | Run at start prior to starting cron.  |  false  
`REMOTE_SSH_KEY` | The SSH identity file.  |  /sshkey  
`REMOTE_SSH_USER` | The SSH user.  |  root  
`REMOTE_SSH_HOST` | The SSH host.  |  hostname  
`REMOTE_SSH_PORT` | The SSH port.  |  22  
`REMOTE_DB_PATH` | Path to the database files on the SSH server.  |  /opt/appdata/plex/database/Library/Application Support/Plex Media Server/Plug-in Support/Databases  
`REMOTE_START`  |  The command to start Plex on the remote.  |  docker start plex  
`REMOTE_STOP`  |  The command to stop Plex on the remote.  |  docker stop plex  
