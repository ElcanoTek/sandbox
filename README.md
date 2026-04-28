# sandbox

A Fedora-based container image bundling the Python data-analysis stack
(`pandas`, `numpy`, `scipy`, `matplotlib`, `seaborn`, `scikit-learn`,
`pyarrow`, `ipykernel`), document and image tooling (`Pillow`,
`openpyxl`, `xlsxwriter`, `pypdf`, `reportlab`, `BeautifulSoup`, `lxml`,
`pyyaml`, `tabulate`), plus a handful of read-only CLI tools (`git`,
`jq`, `ripgrep`, `pandoc`, `ImageMagick`). Intended for rootless
one-shot execution under hardened defaults.

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
