# sandbox

A Fedora-based container image with the Python data-analysis stack
(`pandas`, `numpy`, `matplotlib`, `scikit-learn`, `ipykernel`) and a
handful of read-only CLI tools, intended for rootless one-shot
execution under hardened defaults.

## Pulling

```sh
podman pull ghcr.io/elcanotek/sandbox:latest
```

## Running

The image is designed to be run with the following flags. Anything else
is unsupported; in particular, the image deliberately ships no
network-shaped tools because the intended runtime is `--network=none`.

```sh
podman run --rm \
    --read-only \
    --cap-drop=ALL \
    --security-opt=no-new-privileges \
    --network=none \
    --tmpfs=/tmp:rw,size=128m \
    --tmpfs=/home/sandbox/.ipython:rw,size=32m \
    --tmpfs=/home/sandbox/.cache:rw,size=32m \
    --volume=/path/to/workspace:/workspace:rw,Z \
    ghcr.io/elcanotek/sandbox:latest \
    bash -c "echo hello"
```

`/opt/bridge` is a pre-created mount point for callers who want to
bind-mount an extra script into the container.

## License

BSD 3-Clause. See [LICENSE](./LICENSE).
