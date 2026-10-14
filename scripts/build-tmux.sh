#!/usr/bin/env bash
# Build the latest tmux into ~/.local without root.
# libevent and ncurses are built statically alongside (and byacc if no yacc is present)
# so no -dev packages are needed; only a C compiler and make are required.
#
# Usage: scripts/build-tmux.sh

set -euo pipefail

LIBEVENT_VERSION=2.1.12-stable
NCURSES_VERSION=6.5
BYACC_VERSION=20241231

prefix="$HOME/.local"
deps="$HOME/.local/opt/tmux-deps"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
jobs=$(nproc 2>/dev/null || echo 2)

# Download to a file first: a retried transfer cannot be streamed into tar.
fetch() { curl -fsSL --retry 3 --retry-all-errors -o "$work/src.tar.gz" "$1" && tar xzf "$work/src.tar.gz"; }

tmux_version=$(curl -fsSL --retry 3 --retry-all-errors https://api.github.com/repos/tmux/tmux/releases/latest |
    sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')

if [[ -x $prefix/bin/tmux ]] && [[ $("$prefix/bin/tmux" -V) == "tmux $tmux_version" ]]; then
    echo "tmux $tmux_version already installed"
    exit 0
fi

export PATH="$deps/bin:$PATH"
echo "building tmux $tmux_version (libevent $LIBEVENT_VERSION, ncurses $NCURSES_VERSION)"
cd "$work"

# tmux's configure requires yacc even for release tarballs.
if ! command -v yacc >/dev/null && ! command -v bison >/dev/null && ! command -v byacc >/dev/null; then
    fetch "https://invisible-island.net/archives/byacc/byacc-$BYACC_VERSION.tgz"
    (cd "byacc-$BYACC_VERSION" &&
        ./configure --prefix="$deps" >/dev/null &&
        make -j"$jobs" >/dev/null && make install >/dev/null)
fi

fetch "https://github.com/libevent/libevent/releases/download/release-$LIBEVENT_VERSION/libevent-$LIBEVENT_VERSION.tar.gz"
(cd "libevent-$LIBEVENT_VERSION" &&
    ./configure --prefix="$deps" --enable-shared=no --disable-openssl --disable-samples --disable-libevent-regress >/dev/null &&
    make -j"$jobs" >/dev/null && make install >/dev/null)

fetch "https://ftp.gnu.org/gnu/ncurses/ncurses-$NCURSES_VERSION.tar.gz"
(cd "ncurses-$NCURSES_VERSION" &&
    ./configure --prefix="$deps" --with-shared=no --with-default-terminfo-dir=/usr/share/terminfo \
        --with-terminfo-dirs="/etc/terminfo:/lib/terminfo:/usr/share/terminfo" \
        --enable-pc-files --with-pkg-config-libdir="$deps/lib/pkgconfig" \
        --without-ada --without-cxx --without-manpages --without-tests --disable-db-install >/dev/null &&
    make -j"$jobs" >/dev/null && make install >/dev/null)
# Without pkg-config, tmux's configure always appends -lncurses even after finding ncursesw.
ln -sf libncursesw.a "$deps/lib/libncurses.a"

fetch "https://github.com/tmux/tmux/releases/download/$tmux_version/tmux-$tmux_version.tar.gz"
(cd "tmux-$tmux_version" &&
    PKG_CONFIG_PATH="$deps/lib/pkgconfig" \
        CPPFLAGS="-I$deps/include -I$deps/include/ncursesw" \
        LDFLAGS="-L$deps/lib" \
        ./configure --prefix="$prefix" >/dev/null &&
    make -j"$jobs" >/dev/null && make install >/dev/null)

"$prefix/bin/tmux" -V
