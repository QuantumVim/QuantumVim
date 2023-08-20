#!/usr/bin/env bash
set -e

export XDG_STATE_HOME="$HOME/.local/state"

export QV_FIRST_TIME_SETUP=1
export NVIM_APPNAME="${NVIM_APPNAME:-"qvim"}"
export QUANTUMVIM_RTP_DIR="${QUANTUMVIM_RTP_DIR:-"$XDG_STATE_HOME/$NVIM_APPNAME"}"

QUANTUMVIM_CACHE_DIR="$(mktemp -d)"
QUANTUMVIM_DATA_DIR="$(mktemp -d)"
QUANTUMVIM_CONFIG_DIR="$(mktemp -d)"

export QUANTUMVIM_CACHE_DIR QUANTUMVIM_STATE_DIR QUANTUMVIM_DATA_DIR QUANTUMVIM_CONFIG_DIR

echo "rtp: $QUANTUMVIM_RTP_DIR"
echo "cache: $QUANTUMVIM_CACHE_DIR"
echo "data: $QUANTUMVIM_DATA_DIR"
echo "config: $QUANTUMVIM_CONFIG_DIR"

# TODO log dir

mkdir -p "$QUANTUMVIM_RTP_DIR/after/pack/lazy/opt"
git clone https://github.com/nvim-lua/plenary.nvim.git "$QUANTUMVIM_RTP_DIR/after/pack/lazy/opt/plenary"

qvim() {
    exec -a qvim nvim -u "$QUANTUMVIM_RTP_DIR/tests/minimal_init.lua" \
        --cmd "set runtimepath+=$QUANTUMVIM_RTP_DIR/after/pack/lazy/opt/plenary" \
        "$@"
}

if [ -n "$1" ]; then
    qvim --headless -c "lua require('plenary.busted').run('$1')"
else
    qvim --headless -c "PlenaryBustedDirectory tests/specs { minimal_init = './tests/minimal_init.lua' }"
fi
