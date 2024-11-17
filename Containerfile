ARG version
FROM fedora:${version}-aarch64 as build
ARG version
WORKDIR /sysroot
RUN echo "fastestmirror=True" >>/etc/dnf/dnf.conf
RUN dnf install --use-host-config --installroot /sysroot --releasever "${version}" -y --setopt install_weak_deps=false python3-inotify python-unversioned-command && dnf clean all --installroot /sysroot -y

FROM scratch
COPY --from=build /sysroot /
COPY finishDetectionDaemon.py /usr/bin/finishDetectionDaemon.py
RUN chmod +x /usr/bin/finishDetectionDaemon.py
LABEL org.opencontainers.image.source="https://github.com/KilianHanich/finish-detection-daemon"
LABEL org.opencontainers.image.license="EUPL-1.2"
ENTRYPOINT ["/usr/bin/finishDetectionDaemon.py"]

