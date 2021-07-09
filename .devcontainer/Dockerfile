FROM buildpack-deps:focal as rust_1

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.53.0

RUN set -eux; \
    dpkgArch="$(dpkg --print-architecture)"; \
    case "${dpkgArch##*-}" in \
        amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='3dc5ef50861ee18657f9db2eeb7392f9c2a6c95c90ab41e45ab4ca71476b4338' ;; \
        armhf) rustArch='armv7-unknown-linux-gnueabihf'; rustupSha256='67777ac3bc17277102f2ed73fd5f14c51f4ca5963adadf7f174adf4ebc38747b' ;; \
        arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='32a1532f7cef072a667bac53f1a5542c99666c4071af0c9549795bbdb2069ec1' ;; \
        i386) rustArch='i686-unknown-linux-gnu'; rustupSha256='e50d1deb99048bc5782a0200aa33e4eea70747d49dffdc9d06812fd22a372515' ;; \
        *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
    esac; \
    url="https://static.rust-lang.org/rustup/archive/1.24.3/${rustArch}/rustup-init"; \
    wget "$url"; \
    echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y --no-modify-path --profile minimal --default-toolchain $RUST_VERSION --default-host ${rustArch}; \
    rm rustup-init; \
    chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
    rustup --version; \
    cargo --version; \
    rustc --version;

# ----

FROM rust_1 as vscode_devcontainers_rust_0_1

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"
# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID
COPY library-scripts/*.sh library-scripts/*.env /tmp/library-scripts/
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    # Remove imagemagick due to https://security-tracker.debian.org/tracker/CVE-2019-10131
    && apt-get purge -y imagemagick imagemagick-6-common \
    # Install common packages, non-root user, updated lldb, dependencies
    && bash /tmp/library-scripts/common-debian.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}" "true" "true" \
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
FROM vscode_devcontainers_rust_0_1 as ms_base

USER 0
ARG USERNAME=${USERNAME:-vscode}
ARG GROUPNAME=${USERNAME:-${USERNAME}}
ARG CREATE_GROUP=${CREATE_GROUP:-false}
ARG CREATE_USER=${CREATE_USER:-false}
ARG UID=${UID:-1000}
ARG GID=${GID:-1000}
# Need a place to write npm settings junk
ARG USER_HOME_DIR=${USER_HOME_DIR:-/home/${USERNAME}}

# set C.UTF-8 locale as default.
ENV LANG=C.UTF-8
SHELL ["/bin/bash", "-c"]

# Add sudo, bintools, and docker
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confold" install -y \
        binutils sudo apt-transport-https ca-certificates curl  gnupg lsb-release && \
    (export DEBIAN_FRONTEND=noninteractive; apt-get remove -y docker; apt-get remove -y docker-engine; apt-get remove -y  docker.io; apt-get remove -y containerd; apt-get remove -y runc)

RUN (curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg) && \
    (echo \
    "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null) && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confold" install -y docker-ce docker-ce-cli containerd.io

# TODO: docker compose
#get-pip
#pip install docker-compose
#sudo curl \
#    -L https://raw.githubusercontent.com/docker/compose/1.29.2/contrib/completion/bash/docker-compose \
#    -o /etc/bash_completion.d/docker-compose

# create a user
# TODO: check if the group exixts and validate the GID
# TODO: check if the user exixts and validate the UID and primary GID
RUN (if [[ 'true' == "${CREATE_GROUP}" ]]; then \
      groupadd -g "${GID}" "${GROUPNAME}"; \
    fi) && \
    (if [[ 'true' == "${CREATE_USER}" ]]; then \
      useradd -m -d "${USER_HOME_DIR}" -g "${GID}" -s /bin/bash \
              -u "${UID}" -G "sudo,docker" "${USERNAME}"; \
    else \
      usermod -aG sudo,docker ${USERNAME}; \
    fi) && cat /etc/passwd

RUN mkdir /var/www-data && chown "${USERNAME}:${USERNAME}" /var/www-data && \
    (echo -ne "\n${USERNAME} ALL=(ALL:ALL) NOPASSWD: ALL\n" >> /etc/sudoers)

# Create the home directory and give ownership to the user
RUN mkdir -p "${USER_HOME_DIR}" && \
    chown -R "${UID}:${GID}" "${USER_HOME_DIR}" && \
    ls -la /root

# Add ruist cargo stuff
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confold" install -y \
        cargo libkeyutils-dev libclang-dev clang pkg-config libcryptsetup-dev \
        gcc-8-aarch64-linux-gnu g++-8-aarch64-linux-gnu && \
    update-alternatives --install /usr/local/bin/aarch64-linux-gnu-gcc aarch64-linux-gnu-gcc /usr/bin/aarch64-linux-gnu-gcc-8 10
#    update-alternatives --install /usr/local/bin/llvm-objdump aarch64-linux-gnu-gcc /usr/bin/llvm-objdump-10 10

ENV LLVM_CONFIG_PATH=/usr/bin/llvm-config-10

# Switch to the site root directory
WORKDIR ${USER_HOME_DIR}

USER ${USERNAME}

RUN rustup component add rustfmt && \
    cargo install cargo-deb cargo-binutils && \
    rustup component add llvm-tools-preview

USER 0
