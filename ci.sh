#!/usr/bin/env bash
set -euo pipefail
nix flake check --print-build-logs
