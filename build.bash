#!/usr/bin/bash
# SPDX-License-Identifier: EUPL-1.2
# SPDX-FileCopyrightText: 2023 Kilian Hanich <khanich.opensource@gmx.de>

set -x

ctr=$(buildah from scratch)
export ctr

# gets latest Fedora release
release_version=$(podman run --rm registry.fedoraproject.org/fedora:latest dnf --version | head -n2 | tail -n1 | awk '{print $2}' | python3 -c 'print(input().split(".")[-2][2:])')
export release_version

buildah unshare bash --norc -xc '

mnt=$(buildah mount $ctr)
trap "buildah umount $ctr" EXIT

podman run --rm -v "$mnt":/sysroot registry.fedoraproject.org/fedora:latest dnf install --installroot "/sysroot" --releasever $release_version -y --setopt install_weak_deps=false python3-inotify python3
podman run --rm -v "$mnt":/sysroot registry.fedoraproject.org/fedora:latest dnf clean all --installroot "/sysroot" -y

cp finishDetectionDaemon.py "${mnt}/usr/bin/"
chmod +x "${mnt}/usr/bin/finishDetectionDaemon.py"
'

buildah config --label org.opencontainers.image.source="https://github.com/KilianHanich/finish-detection-daemon" $ctr

buildah config --label org.opencontainers.image.license="EUPL-1.2" $ctr

buildah config --entrypoint '["/usr/bin/finishDetectionDaemon.py"]' $ctr

buildah commit $ctr finish-detection-daemon
buildah rm $ctr

