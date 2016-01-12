#!/usr/bin/env zsh

if [ -z "$USER" ]; then
    export USER="$(id -un)"
fi
if [ -z "$FULLNAME" ]; then
    export FULLNAME="$(id -F)"
fi
if [ -z "$MAIL" ]; then
    export MAIL="$USER@student.42.fr"
fi
if [ -z "$GROUP" ]; then
    export GROUP=$(id -gn $USER)
fi

export REMOTE_HOME="/tmp/.${USER}_rhome"

if [ ! -d "${REMOTE_HOME}" ]; then
    mkdir "${REMOTE_HOME}"
fi

export NPM_PACKAGES=${REMOTE_HOME}/.npm-packages
export NODE_PATH="${NPM_PACKAGES}/lib/node_modules:${NODE_PATH}"
export PATH="${REMOTE_HOME}/.brew/bin:${NPM_PACKAGES}/bin:${REMOTE_HOME}/.meteor:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin:/usr/local/munki"
export HOMEBREW_CACHE="${REMOTE_HOME}/.tmp/brew_cache"

if [ -z "$(mount | grep "${REMOTE_HOME}")" ]; then
    mount -t nfs zfs-student-1:/tank/sgoinfre/goinfre/Perso/Students/${USER} \
        ${REMOTE_HOME}
fi

if [ ! -d "${REMOTE_HOME}/.git" ]; then
    git clone https://github.com/pandark/setup_42.git ${REMOTE_HOME}
fi

if [ -z "$(git config --global user.name)" ]; then
    git config --global user.name "$FULLNAME"
fi
if [ -z "$(git config --global user.email)" ]; then
    git config --global user.email "$MAIL"
fi

if [ -z "$(git config --global core.excludesfile)" ]; then
    git config --global core.excludesfile "$REMOTE_HOME/.dotfiles/.gitignore_global"
fi
if [ -z "$(git config --global push.default)" ]; then
    git config --global push.default "simple"
fi

cd $HOME
for f in ".config" ".gitconfig" ".gitignore_global" ".npmrc" ".ssh" ".gdbinit" ".lldbinit" ".ocamlinit"; do
    if [ ! -L $f ]; then
        rm -Rf $f
        ln -s ${REMOTE_HOME}/.dotfiles/$f
    fi
done

cd $HOME
for f in ".nvimlog" ".opam" ".lesshst" ".zcompdump"; do
    if [ ! -L $f ]; then
        rm -Rf $f
        ln -s ${REMOTE_HOME}/$f
    fi
done

if [ ! -d "${REMOTE_HOME}/.brew" ]; then
    mkdir ${REMOTE_HOME}/.brew && \
        curl -L https://github.com/Homebrew/homebrew/tarball/master | \
        tar xz --strip 1 -C ${REMOTE_HOME}/.brew
        brew update
        brew upgrade
fi

if [ ! -f "${REMOTE_HOME}/.brew/share/zsh/site-functions/_brew" ] ; then
     curl -Lo "${REMOTE_HOME}/.brew/share/zsh/site-functions/_brew" https://raw.githubusercontent.com/Homebrew/homebrew/master/Library/Contributions/brew_zsh_completion.zsh
fi

if [ -z "$(brew list | grep -w neovim)" ]; then
    brew tap neovim/neovim
    brew install --HEAD neovim

    curl -fLo $HOME/.config/nvim/autoload/plug.vim \
        --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

for software in "tree" "pstree" "the_silver_searcher" "htop-osx" "wget" "valgrind" "ranger" "tig" "redshift" "node" "python" "python3"; do
    if [ -z "$(brew list | grep -w $software)" ]; then
        brew install $software
    fi
done

if [ -n "$(which-command npm)" ]; then
    npm config set prefix '${REMOTE_HOME}/.npm-packages'
fi

rm $HOME/.zshrc
curl -fLo "$HOME/.zshrc" https://raw.githubusercontent.com/pandark/setup_42/master/.dotfiles/.zshrc

# Install XQuartz, reboot, then...
if [ -n "$(which-command Xquartz)" ]; then
    brew install ocaml --with-x11
    brew install rlwrap
    brew install opam
    opam init
    sed -i -E "s#/nfs/.*/$USER/#\${REMOTE_HOME}/#g" $HOME/.opam/opam-init/init.*
    eval $(opam config env)
else
    echo "Install XQuartz with Managed Software Center, reboot, then launch install.sh again"
fi
#opam switch 4.02.0
#eval $(opam config env)
#opam install lablgtk
