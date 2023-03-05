# Statically linked OpenSSH

> ℹ️ By default container run ssh daemon on port 2022

Statically linked [OpenSSH] container image with [Bash]

> 28M (1,1M bash)

```bash
ghcr.io/awesome-containers/static-openssh:latest
ghcr.io/awesome-containers/static-openssh:9.2

docker.io/awesomecontainers/static-openssh:latest
docker.io/awesomecontainers/static-openssh:9.2
```

Slim statically linked [OpenSSH] container image with [Bash] and
packaged with [UPX]

> 12M (578K bash)

```bash
ghcr.io/awesome-containers/static-openssh:latest-slim
ghcr.io/awesome-containers/static-openssh:9.2-slim

docker.io/awesomecontainers/static-openssh:latest-slim
docker.io/awesomecontainers/static-openssh:9.2-slim
```

[OpenSSH]: https://www.openssh.com/
[Bash]: https://github.com/awesome-containers/static-bash
[UPX]: https://upx.github.io/

<!--
```bash
image="localhost/${PWD##*/}"

podman build -t "$image:latest" .
podman build -t "$image:latest-slim" -f Containerfile-slim \
  --build-arg STATIC_OPENSSH_IMAGE="$image" \
  --build-arg STATIC_OPENSSH_VERSION=latest --no-cache .

echo "$image:latest"
podman inspect "$image:latest" | jq '.[].Size' | numfmt --to=iec
echo "$image:latest-slim"
podman inspect "$image:latest-slim" | jq '.[].Size' | numfmt --to=iec

```
-->
