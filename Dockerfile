FROM archlinux/archlinux:base-devel

RUN pacman -Sy --noconfirm openssh \
      git pcre2 pacman-contrib && \
      pacman -Scc --noconfirm

RUN useradd -ms /bin/bash builder --groups alpm && \
    mkdir -p /home/builder/.ssh && \
    touch /home/builder/.ssh/known_hosts && \
    echo 'builder ALL = NOPASSWD: ALL' > /etc/sudoers.d/builder_pacman && \
    chmod 400 /etc/sudoers.d/builder_pacman

COPY ssh_config /home/builder/.ssh/config

RUN chown builder:builder /home/builder -R && \
    chmod 600 /home/builder/.ssh/* -R

COPY entrypoint.sh /entrypoint.sh

USER builder
WORKDIR /home/builder

ENTRYPOINT ["/entrypoint.sh"]

