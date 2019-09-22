# plex-db-sync
Synchronizes the database watched status between two Plex servers. This includes watched times, and works for all users on the system without the need for tokens.

This is a fork of the Fmstrat/plex-db-sync with focus specifically on Docker usage.

## Docker
The following example is for docker. It assumes you are running one Plex server locally (via Docker container), and another remotely (also via Docker container).

Note: Paths are default to [PGBlitz](https://github.com/PGBlitz/PGBlitz.com).

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
      - REMOTE_START=ssh -oStrictHostKeyChecking=no -i /sshkey root@hostname 'docker start plex'
      - REMOTE_STOP=ssh -oStrictHostKeyChecking=no -i /sshkey root@hostname 'docker stop plex'
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
`LOCAL_DB_PATH` | Location of the server's DB.  |  /mnt/DB2  
`LOCAL_START` | The command to start the Plex server.  |  curl --unix-socket /var/run/docker.sock -X POST /containers/plex/start    
`LOCAL_STOP` | The command to stop the Plex server.  |  curl --unix-socket /var/run/docker.sock -X POST /containers/plex/stop  
n/a | Don't compare version db of Plex server.  |  
`CRON` | A string that defines when the script should run in crond (Default is 4AM).  |  0 4 * * *  
`INITIALRUN` | Run at start prior to starting cron.  |  false  
`REMOTE_SSH_KEY` | The SSH identity file.  |  /sshkey  
`REMOTE_SSH_USER` | The SSH user.  |  root  
`REMOTE_SSH_HOST` | The SSH host.  |  hostname  
`REMOTE_SSH_PORT` | The SSH port.  |  22  
`REMOTE_DB_PATH` | Path to the database file on the SSH server.  |  /docker/plex/database/Library/Application Support/Plex Media Server/Plug-in Support/Databases  
