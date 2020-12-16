## Alpine microcontainer with Apache2 and SFTP

Based on [sftp](https://github.com/atmoz/sftp) and [Docker-alpine-apache](https://github.com/nimmis/docker-alpine-apache).

This is a micro docker container based on Alpine OS, Apache version 2 and sftp. The aim of this project is to create a public FTP accessible from Apache2, used for public science archives.

There images are build on [nimmis/alpine-micro](https://hub.docker.com/r/nimmis/alpine-micro/) ![](https://images.microbadger.com/badges/image/nimmis/alpine-micro.svg) which are a modified version of Alpine OS with a working init process, cron, logrotate  and syslog. All services are started by runit daemon, for more information about how it works and setup of new services please visit <https://hub.docker.com/r/nimmis/alpine-micro/> for more information.

The container also have a backup system with cron schedule, number of copies to save etc, for information about the backup system please visit the [README.md for the backupsystem](https://github.com/nimmis/backup/blob/master/README.md)

You have to pass users.conf volume in `/etc/sftp/users.conf:ro` in order to create users on startup. Works exactly the same as [sftp](https://github.com/atmoz/sftp), but users must be passed as a volume (not as a command argument).

## Store users in config

```
docker run \
    -v <host-dir>/users.conf:/etc/sftp/users.conf:ro \
    -v mySftpVolume:/home \
    -p 2222:22 -d atmoz/sftp
```

<host-dir>/users.conf:

```
foo:123:1001:100
bar:abc:1002:100
baz:xyz:1003:100
```

## Sharing a directory from your computer

Let's mount a directory and set UID:

```
docker run \
    -v <host-dir>/upload:/home/foo/upload \
    -p 2222:22 -d atmoz/sftp \
    foo:pass:1001
```

## Logging in with SSH keys

Mount public keys in the user's `.ssh/keys/` directory. All keys are automatically appended to `.ssh/authorized_keys` (you can't mount this file directly, because OpenSSH requires limited file permissions). In this example, we do not provide any password, so the user `foo` can only login with his SSH key.

```
docker run \
    -v <host-dir>/id_rsa.pub:/home/foo/.ssh/keys/id_rsa.pub:ro \
    -v <host-dir>/id_other.pub:/home/foo/.ssh/keys/id_other.pub:ro \
    -v <host-dir>/share:/home/foo/share \
    -p 2222:22 -d atmoz/sftp \
    foo::1001
```

## Providing your own SSH host key (recommended)

This container will generate new SSH host keys at first run. To avoid that your users get a MITM warning when you recreate your container (and the host keys changes), you can mount your own host keys.

```
docker run \
    -v <host-dir>/ssh_host_ed25519_key:/etc/ssh/ssh_host_ed25519_key \
    -v <host-dir>/ssh_host_rsa_key:/etc/ssh/ssh_host_rsa_key \
    -v <host-dir>/share:/home/foo/share \
    -p 2222:22 -d atmoz/sftp \
    foo::1001
```

Tip: you can generate your keys with these commands:

```
ssh-keygen -t ed25519 -f ssh_host_ed25519_key < /dev/null
ssh-keygen -t rsa -b 4096 -f ssh_host_rsa_key < /dev/null
```

---

![](./images/screenshot.png)
