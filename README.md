# sshfs-share

sshfs-share is a Docker container image that runs sshd and sftp servers allowing user to share local directory for remote host using sshfs.

## Build

```
docker build --tag arturmadrzak/sshfs-share:latest "."
```

There is an image available on Dockerhub that can be directly downloaded and used:
```
docker pull arturmadrzak/sshfs-share:latest
```

## Usage

### Setting up local share
```
docker run \
  --rm \
  --name sshfs-share \
  --detach \
  --publish 60022:60022 \
  --volume "$(pwd)":/public \
  arturmadrzak/sshfs-share:latest
```
By default, sshd listens on the `60022` port and the same host port is forwarded into the container. In case of port number conflict, sshd can be instructed to listen on different port by  `-p|--port` option of entrypoint script. The port that sshd is reachable for external world can be adjusted by `--publish` option of `docker run` command (ie. `--publish 2222:60022` makes it available at port `2222` from external host).
To stop sharing just call `docker stop sshfs-share`.

### Mounting share in remote host
```
mkdir -p remote
sshfs \
    -o sshfs_sync \
    -o uid="$(id -u)" \
    -o gid="$(id -g)" \
    -o transform_symlinks \
    -o "UserKnownHostsFile=/dev/null" \
    -o "StrictHostKeyChecking=no" \
    -p 60022 \
    root@10.41.1.2:/public \
    remote

```

## Troubleshooting
* Configure UFW to allow traffic to server
    ```
  sudo ufw allow to any port 60022
  ```

* Ensure `--publish` option provides host and container port
`--publish 60022:60022` is correct. `--publish 60022` is not.
