#!/usr/bin/env zsh

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

curl -s "https://get.sdkman.io" | bash

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash

curl https://pyenv.run | bash

curl -sSL https://install.python-poetry.org | python3 -

curl -sS https://starship.rs/install.sh | sh

curl -fsSL https://get.pnpm.io/install.sh | sh -

curl -fsSL https://install.julialang.org | sh

curl -sfS "https://dotenvx.sh?directory=${HOME}/.local/bin" | sh

curl -L -O "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
bash Miniforge3-$(uname)-$(uname -m).sh
rm Miniforge3-$(uname)-$(uname -m).sh

curl -LsSf https://astral.sh/uv/install.sh | sh

curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash

curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh" | bash

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-4 | bash
