# Justfile for System Bootstrap

# List available commands
default:
    @just --list

# --- Common Setup ---

# Format supported repository files
format:
    ./scripts/format.sh

# Lint and syntax-check supported repository files
lint:
    ./scripts/lint.sh

# Run all repository quality checks
check: lint

# --- Hosts (hosts/<h>/host.env lists the modules) ---

# Provision a host for real: packages, dotfiles and setup of each module
host h:
    ./scripts/host.sh {{ h }}

# Dry run for a host: dotbot -n, read-only package checks, setup.sh syntax only
dry h:
    ./scripts/host.sh {{ h }} --dry

# Run one module of a host for real
module h m:
    ./scripts/host.sh {{ h }} --only {{ m }}
