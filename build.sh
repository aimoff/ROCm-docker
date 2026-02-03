#!/bin/sh

OS=${OS:-ubuntu}
#OS=${OS:-debian}
OS_VERSION=${OS_VERSION:-24.04}
#OS_VERSION=${OS_VERSION:-trixie}
OS_VARIANT=${OS_VARIANT:-${OS}-${OS_VERSION}}
ROCM_VERSION=${ROCM_VERSION:-7.1.1}
GFX_VERSION=${GFX_VERSION:-10.3.0}
GFX_ARCH=${GFX_ARCH:-gfx1030}
TERM_FLAVOR="-complete-sdk"
XTERM_FLAVOR="-complete"
RENDER_GID=$(getent group render | cut --delimiter ':' --fields 3)

cat >.env <<EOF
OS_VARIANT=${OS_VARIANT}
ROCM_VERSION=${ROCM_VERSION}
GFX_VERSION=${GFX_VERSION}
GFX_ARCH=${GFX_ARCH}
TERM_FLAVOR=${TERM_FLAVOR}
XTERM_FLAVOR=${XTERM_FLAVOR}
UID=${UID:-$(id -u)}
RENDER_GID=${RENDER_GID}
EOF

# choose your compose tool
#COMPOSE="docker-compose"
COMPOSE="docker compose"

# build rocm/dev-${OS_VARIANT}:${ROCM_VERSION}
${COMPOSE} build base || exit $?
# docker tag rocm/dev-${OS_VARIANT}:${ROCM_VERSION} rocm/dev-${OS_VARIANT}:latest

# build rocm/dev-${OS_VARIANT}:${ROCM_VERSION}-${FLAVOR}
FLAVORS="openmp-sdk opencl opencl-sdk hip hip-sdk ml ml-sdk complete complete-sdk"
for flavor in ${FLAVORS}; do
  ${COMPOSE} build ${flavor} || exit $?
  # docker tag rocm/dev-${OS_VARIANT}:${ROCM_VERSION}-${FLAVOR} rocm/dev-${OS_VARIANT}:latest-${FLAVOR}
done

# build rocm/rocm-terminal:${ROCM_VERSION}-${OS_VARIANT}${TERM_FLAVOR}
${COMPOSE} build term || exit $?
# docker tag rocm/rocm-terminal:${ROCM_VERSION}-${OS_VARIANT}${TERM_FLAVOR} rocm/rocm-terminal:latest-${OS_VARIANT}${TERM_FLAVOR}

${COMPOSE} build xterm || exit $?
# docker tag rocm/rocm-terminal:${ROCM_VERSION}-${OS_VARIANT}${TERM_FLAVOR}-x11 rocm/rocm-terminal:latest-${OS_VARIANT}${TERM_FLAVOR}-x11
