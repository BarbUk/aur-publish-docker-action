FROM archlinux/archlinux:base

RUN pacman -Sy && \
    pacman -Sy --noconfirm openssh \
      git base-devel pacman-contrib && \
      pacman -Scc --noconfirm

RUN useradd -ms /bin/bash builder && \
    mkdir -p /home/builder/.ssh && \
    touch /home/builder/.ssh/known_hosts

COPY ssh_config /home/builder/.ssh/config

RUN chown builder:builder /home/builder -R && \
    chmod 600 /home/builder/.ssh/* -R

COPY entrypoint.sh /entrypoint.sh

USER builder
WORKDIR /home/builder

ENTRYPOINT ["/entrypoint.sh"]

