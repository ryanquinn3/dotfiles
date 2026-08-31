# syntax=docker/dockerfile:1

# exeuntu supplies the exe.dev VM contract (systemd, Docker, Shelley hooks,
# the exedev user, and the base command-line environment).
ARG EXEUNTU_IMAGE=ghcr.io/boldsoftware/exeuntu:latest
FROM ${EXEUNTU_IMAGE}

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Homebrew's Linux prefix is owned by exedev. exeuntu already includes the
# compiler/toolchain prerequisites required by the Homebrew installer, so do
# not add another apt layer here.
USER exedev
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}" \
    HOMEBREW_NO_AUTO_UPDATE=1 \
    HOMEBREW_NO_ANALYTICS=1

RUN NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

COPY --chown=exedev:exedev brew/exe.Brewfile /tmp/exe.Brewfile

RUN brew bundle install --file=/tmp/exe.Brewfile \
    && brew cleanup -s --prune=all \
    && rm -rf /home/linuxbrew/.cache /home/exedev/.cache/Homebrew \
              /tmp/exe.Brewfile

# Preserve exe.dev's expected image behavior when this Dockerfile is later
# rebased onto a different Ubuntu-derived image.
EXPOSE 8000 9999
LABEL "exe.dev/login-user"="exedev" \
      "exe.dev/install-shelley"="true"
