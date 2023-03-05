# https://github.com/awesome-containers/static-bash
ARG STATIC_BASH_VERSION=5.2.15
ARG STATIC_BASH_IMAGE=ghcr.io/awesome-containers/static-bash

# https://github.com/awesome-containers/alpine-build-essential
ARG BUILD_ESSENTIAL_VERSION=3.17
ARG BUILD_ESSENTIAL_IMAGE=ghcr.io/awesome-containers/alpine-build-essential


FROM $STATIC_BASH_IMAGE:$STATIC_BASH_VERSION AS static-bash
FROM $BUILD_ESSENTIAL_IMAGE:$BUILD_ESSENTIAL_VERSION AS build

# hadolint ignore=DL3018
RUN apk add --no-cache zlib-dev zlib-static openssl-dev openssl-libs-static

# https://www.openssh.com/releasenotes.html
ARG OPENSSH_VERSION=9.2

WORKDIR /src/openssh
# hadolint ignore=DL4006
RUN set -xeu; \
    tag="$(echo "$OPENSSH_VERSION" | awk -F. '{print "V_" $1 "_" $2 "_P1"}')"; \
    curl -#Lo openssh.tar.gz \
        "https://github.com/openssh/openssh-portable/archive/refs/tags/$tag.tar.gz"; \
    tar -xvf openssh.tar.gz --strip-components=1; \
    rm -f openssh.tar.gz

ARG CFLAGS='-w -g -Os -static'
ARG EPATH=/src/openssh/bin
RUN set -xeu; \
    autoreconf; \
    ./configure \
        --bindir=$EPATH --sbindir=$EPATH --libexecdir=$EPATH --prefix= \
        --disable-security-key --disable-etc-default-login --disable-lastlog \
        --with-ldflags=-static --with-privsep-user=nobody; \
    make install-nosysconf; \
    strip -s -R .comment --strip-unneeded bin/*; \
    ! ldd bin/ssh && :; \
    ! ldd bin/sshd && :; \
    chmod -cR 755 bin/*; \
    chown -cR 0:0 bin/*; \
    ./bin/ssh -V; \
    printf '%s\n' 'root:x:0:0:root:/:/bin/bash' \
        'nobody:x:65534:65534:nobody:/:/bin/false' > ../passwd; \
    printf '%s\n' 'nogroup:x:65534:' 'root:x:0:' > ../group; \
    mkdir -p empty

# static openssh image
FROM static-bash

COPY --from=build /src/openssh/sshd_config /src/passwd /src/group /etc/
COPY --from=build /src/openssh/empty /var/empty
COPY --from=build /src/openssh/bin/ /bin/

ENTRYPOINT ["/bin/bash"]
CMD ["-c" , "/bin/ssh-keygen -A && /bin/sshd -t && /bin/sshd -D -e -o PidFile=/run/sshd.pid -o port=2022"]
