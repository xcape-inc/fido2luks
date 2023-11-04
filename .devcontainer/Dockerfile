# [Choice] Debian OS version (use bullseye on local arm64/Apple Silicon): buster, bullseye
ARG VARIANT="bullseye"
FROM rust:1-${VARIANT} as vscode_devcontainers_rust_0_1

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"

# Enable new "BUILDKIT" mode for Docker CLI
ENV DOCKER_BUILDKIT=1

# Install needed packages and setup non-root user. Use a separate RUN statement to add your
# own dependencies. A user of "automatic" attempts to reuse an user ID if one already exists.
ARG USERNAME=automatic
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# [Option] Install Docker CLI
ARG INSTALL_DOCKER="true"
# [Option] Enable non-root Docker access in container
ARG ENABLE_NONROOT_DOCKER="true"
# [Option] Use the OSS Moby CLI instead of the licensed Docker CLI
ARG USE_MOBY="true"

COPY .devcontainer/library-scripts/*.sh /tmp/library-scripts/
RUN export DEBIAN_FRONTEND=noninteractive; apt-get update \
    # Remove imagemagick due to https://security-tracker.debian.org/tracker/CVE-2019-10131
    && apt-get purge -y imagemagick imagemagick-6-common \
    # Install common packages, non-root user, updated lldb, dependencies
    && bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
    && (if [ "${INSTALL_DOCKER}" = "true" ]; then \
        /bin/bash /tmp/library-scripts/docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "/var/run/docker-host.sock" "/var/run/docker.sock" "${USERNAME}"; \
    else \
        echo '#!/bin/bash\n"$@"' > /usr/local/share/docker-init.sh && chmod +x /usr/local/share/docker-init.sh; \
    fi ) \
    && bash /tmp/library-scripts/rust-debian.sh "${CARGO_HOME}" "${RUSTUP_HOME}" "${USERNAME}" "true" "true" \
    && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/library-scripts

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
# ----

ARG IMAGE_VERSION=${IMAGE_VERSION:-0-1}
ARG REGISTRY_URI=${REGISTRY_URI:-mcr.microsoft.com/}
ARG BRANCH_NAME=${BRANCH_NAME:-master}
# The original rust uses debian 10; this uses ubuntu 20.04
#FROM ${REGISTRY_URI}vscode/devcontainers/rust:${IMAGE_VERSION} as ms_base
#FROM vscode_devcontainers_rust_0_1 as ms_base

USER 0
ARG USERNAME=vscode
# Need a place to write npm settings junk
ARG USER_HOME_DIR=${USER_HOME_DIR:-/home/${USERNAME}}

ENV LLVM_CONFIG_PATH=/usr/bin/llvm-config-10

# Switch to the site root directory
WORKDIR ${USER_HOME_DIR}

USER ${USERNAME}

RUN rustup component add rustfmt && \
    cargo install cargo-deb cargo-binutils && \
    rustup component add llvm-tools-preview

# Enable the arm64 architecture; things from here down could easily be another architecture
ENV PKG_CONFIG_ALLOW_CROSS=1

RUN rustup target add aarch64-unknown-linux-gnu

USER 0

# Add new architecture, limit default sources to arm64, and add sources for arm64
RUN dpkg --add-architecture arm64 
    #(echo -ne "deb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ focal main restricted universe multiverse\ndeb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ focal-security main restricted universe multiverse\ndeb [arch=arm64] http://ports.ubuntu.com/ubuntu-ports/ focal-updates main restricted universe multiverse\n" | tee -a /etc/apt/sources.list)
RUN export DEBIAN_FRONTEND=noninteractive; \
    apt-get update && \
    apt-get -o Dpkg::Options::="--force-confold" install -y \
        libcryptsetup-dev libclang-dev && \
    apt-get -o Dpkg::Options::="--force-confold" install -y \
        libc6-arm64-cross libc6-dev-arm64-cross libclang-dev:arm64 \
        libcryptsetup-dev:arm64 pkg-config:arm64 gcc-10-aarch64-linux-gnu g++-10-aarch64-linux-gnu && \
    apt-get -o Dpkg::Options::="--force-confold" install --reinstall -y libclang-dev && \
    update-alternatives --install /usr/local/bin/aarch64-linux-gnu-gcc-ar aarch64-linux-gnu-gcc-ar /usr/bin/aarch64-linux-gnu-gcc-ar-10 10 && \
    update-alternatives --install /usr/local/bin/aarch64-linux-gnu-gcc aarch64-linux-gnu-gcc /usr/bin/aarch64-linux-gnu-gcc-10 10

#COPY --chown=0:0 run_script_nonroot.sh /usr/local/sbin/run_script_nonroot.sh

LABEL org.opencontainers.image.authors='Xcape, Inc. <support@xcapeinc.com>'
LABEL org.opencontainers.image.url='https://github.com/xcape-inc/fido2luks'
LABEL org.opencontainers.image.documentation='https://xcape-inc.github.io/fido2luks'
LABEL org.opencontainers.image.source='https://github.com/xcape-inc/fido2luks.git'
LABEL org.opencontainers.image.vendor='Xcape, Inc.'
#LABEL org.opencontainers.image.licenses=''
LABEL org.opencontainers.image.title='ghcr.io/xcape-inc/fido2luks-builder'
LABEL org.opencontainers.image.description="Docker image for building fido2luks deb package including cross compiling"

ARG VERSION=unset
ARG LONG_FORM_VERSION=unset
USER root
# TODO: change this into the server run command
RUN (printf 'fido2luks devcontainer' > /etc/opencontainers_image_title) && \
    (printf '%s' "${VERSION}" > /etc/opencontainers_image_version) && \
    (printf '%s' "${LONG_FORM_VERSION}" > /etc/opencontainers_image_version_long)

USER vscode
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]
