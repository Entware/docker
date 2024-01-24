#!/bin/sh

set -e

SRC=$(dirname $(readlink -f $0))

sudo chown me:me "$SRC"
sudo chown me:me "$HOME/E"

[ -d "$SRC/home" ] || mkdir "$SRC/home"
[ -d "$SRC/dl" ] || mkdir "$SRC/dl"

for i in $(ls -A1 "$SRC/home"); do
    rm -fr "$HOME/$i"
    ln -sf "$SRC/home/$i" "$HOME/$i"
done

if [ ! "$(ls -A ${HOME}/E)"  ]; then
    git clone https://github.com/Entware/Entware.git "$HOME/E"
    ln -sf "$SRC/dl" "$HOME/E/dl"
    cd "$HOME/E"
    git fetch
    case $ENTWARE_ARCH in
	armv5-3.2)
	    git switch armv5-3.2
	;;
	armv7-2.6|x86-2.6)
	    git switch k2.6
	;;
    esac
    make package/symlinks
    if [ ! -z "$ENTWARE_ARCH" ]; then
	cp -vf configs/${ENTWARE_ARCH}.config .config
	cat <<EOF
You may start from...

make -j12 tools/install
make -j12 toolchain/install
make -j12 target/compile
make -j12 package/compile

EOF
    else
	echo 'No arch specified for this container.'
    fi
else
    echo 'Buildroot already deployed.'
fi

export EDITOR='/usr/bin/mcedit'
cd "$HOME/E"
echo 'Have a nice coding!'
echo 'PS1="🐳${ENTWARE_ARCH}:\w$ "' > ${HOME}/.bashrc
bash
