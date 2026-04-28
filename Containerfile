# Fedora-based container image with the Python data-analysis stack
# (pandas, numpy, matplotlib, scikit-learn, ipykernel) and a handful of
# read-only CLI tools (git, jq, ripgrep, etc.). Designed to be run as a
# rootless one-shot container under hardened defaults:
#
#     podman run --rm \
#       --read-only \
#       --cap-drop=ALL \
#       --security-opt=no-new-privileges \
#       --network=none \
#       --tmpfs=/tmp:rw,size=128m \
#       --tmpfs=/home/sandbox/.ipython:rw,size=32m \
#       --tmpfs=/home/sandbox/.cache:rw,size=32m \
#       --volume=/path/to/workspace:/workspace:rw,Z \
#       ghcr.io/elcanotek/sandbox:latest
#
# /opt/bridge is a pre-created mount point for callers who want to
# bind-mount an extra script into the container without touching the
# rest of the rootfs. Empty by default.
#
# Network-shaped tools (curl, wget) are intentionally absent — the image
# is intended for --network=none use, and shipping them would only
# mislead callers.

FROM registry.fedoraproject.org/fedora:43

# Python data stack via Fedora RPMs rather than pip. Fedora rebuilds
# pandas/numpy/etc. against whatever python3 it ships, which sidesteps
# the "no wheel for this Python" trap, and shared libs dedupe cleanly
# across the stack.
RUN dnf install -y \
        --setopt=install_weak_deps=False \
        --setopt=tsflags=nodocs \
        bash \
        ca-certificates \
        coreutils \
        findutils \
        git \
        grep \
        jq \
        less \
        python3 \
        python3-pip \
        python3-ipykernel \
        python3-jupyter-client \
        python3-pandas \
        python3-numpy \
        python3-matplotlib \
        python3-scikit-learn \
        python3-pyarrow \
        python3-requests \
        ripgrep \
        sed \
        shadow-utils \
    && dnf clean all \
    && rm -rf /var/cache/dnf /var/log/dnf*

# Pre-warm matplotlib's font cache so the first plot at runtime doesn't
# pay the multi-second TTF scan.
RUN python3 -c "import matplotlib.pyplot; matplotlib.pyplot.figure().savefig('/tmp/_warm.png'); import os; os.remove('/tmp/_warm.png')"

# Non-root user with a real $HOME. /home/sandbox is read-only at runtime;
# the directories that need to be writable (.ipython, .cache, /tmp) are
# expected to be tmpfs-mounted by the caller per the example above.
RUN useradd --create-home --uid 1000 --shell /bin/bash sandbox \
    && mkdir -p /home/sandbox/.cache /home/sandbox/.ipython /workspace /opt/bridge \
    && cp -r /root/.cache/matplotlib /home/sandbox/.cache/ 2>/dev/null || true \
    && chown -R sandbox:sandbox /home/sandbox /workspace /opt/bridge

USER sandbox
WORKDIR /workspace

# Default CMD keeps the namespace alive for callers that exec into the
# container repeatedly (e.g. running a long-lived bridge process via
# `podman exec -i`). One-shot callers can override.
CMD ["sleep", "infinity"]
