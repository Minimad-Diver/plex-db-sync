# plex-db-sync
Synchronizes the database watched status between two Plex servers. This includes watched times, and works for all users on the system without the need for tokens.

This is a fork of the Fmstrat/plex-db-sync with focus specifically on Docker usage.

## Docker
The following example is for docker-compose. It assumes you are running one Plex server locally, and another remotely.
```
version: '2'

services:

  plex-db-sync:
    image: lusky3/plex-db-sync
    container_name: plex-db-sync
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - ./plex-db-sync/sshkey:/sshkey
      - /docker/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases/:/mnt/DB2
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
      - REMOTE_SSH_PATH=/docker/plex/Library/Application Support/Plex Media Server/Plug-in Support/Databases
      - REMOTE_START=ssh -oStrictHostKeyChecking=no -i /sshkey root@hostname 'cd /docker; docker-compose up -d plex'
      - REMOTE_STOP=ssh -oStrictHostKeyChecking=no -i /sshkey root@hostname 'cd /docker; docker-compose stop plex'
      - LOCAL_DB_PATH=/mnt/DB2
      - LOCAL_START=cd /docker; docker-compose up -d plex
      - LOCAL_STOP=cd /docker; docker-compose stop plex
    restart: always
```

## Options

Docker Variable | Description 
------------ | --------------- | -----------
`BACKUP` | Create a backup of the DB before running any SQL.  
`DEBUG` | Print debug output.  
`DRYRUN` | Don't apply changes to the DB.  
`LOCAL_DB_PATH` | Location of the server's DB. For the script, this is the file itself, for docker, it is the path.  
`LOCAL_START` | The command to start the Plex server.  
`LOCAL_STOP` | The command to stop the Plex server.  
n/a | Don't compare version db of Plex server.  
`CRON` | A string that defines when the script should run in crond (Default is 4AM).  
`INITIALRUN` | Run at start prior to starting cron.  
`REMOTE_SSH_KEY` | The SSH identity file.  
`REMOTE_SSH_USER` | The SSH user.  
`REMOTE_SSH_HOST` | The SSH host.  
n/a | `REMOTE_SSH_PORT` | The SSH port.  
n/a | `REMOTE_SSH_PATH` | Path to the database file on the SSH server.  
