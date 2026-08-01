#!/usr/bin/env bash
set -e

# Allow a bind-mounted AIR SDK to replace the bundled Flex SDK at runtime.
# CrossBridge's makefiles prefer AIR_HOME when it contains lib/compiler.jar.
if [[ -n "${AIR_HOME:-}" && -d "${AIR_HOME}/bin" ]]; then
    export PATH="${AIR_HOME}/bin:${PATH}"
fi

if [[ -n "${AIR_HOME:-}" && -d "${AIR_HOME}/frameworks/libs/player" ]]; then
    export PLAYERGLOBAL_HOME="${AIR_HOME}/frameworks/libs/player"
fi

if [[ $# -eq 0 ]]; then
    exec bash
fi

case "$1" in
    gcc|g++|ar|nm|ranlib|strip|llvm-*)
        tool="$1"
        shift
        exec "/opt/crossbridge/sdk/usr/bin/${tool}" "$@"
        ;;
    *)
        exec "$@"
        ;;
esac
