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

export NPM_PACKAGES=${HOME}/.npm-packages
export NODE_PATH="${NPM_PACKAGES}/lib/node_modules:${NODE_PATH}"
export PATH="${HOME}/.brew/bin:${NPM_PACKAGES}/bin:${HOME}/.meteor:/usr/local/munki:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/opt/X11/bin"
export HOMEBREW_CACHE="${HOME}/.tmp/brew_cache"

if [ -z "$(git config --global user.name)" ]; then
    git config --global user.name "$FULLNAME"
fi
if [ -z "$(git config --global user.email)" ]; then
    git config --global user.email "$MAIL"
fi
if [ -z "$(git config --global core.excludesfile)" ]; then
    git config --global core.excludesfile "${HOME}/.gitignore_global"
fi
if [ -z "$(git config --global push.default)" ]; then
    git config --global push.default "simple"
fi
#if [ -z "$(git config --global diff.tool)" ]; then
#    git config --global diff.tool vimdiff
#fi
#if [ -z "$(git config --global difftool.prompt)" ]; then
#    git config --global difftool.prompt false
#fi
#if [ -z "$(git config --global alias.df)" ]; then
#    git config --global alias.df diff
#fi
#if [ -z "$(git config --global alias.dt)" ]; then
#    git config --global alias.dt difftool
#fi

for f in ".zshrc" ".config/nvim/init.vim" ".config/agrc" ".config/redshift.conf" ".gitignore_global" ".gdbinit" ".lldbinit"; do
    if [ ! -f "${HOME}/${f}" ]; then
        curl -fLo "${HOME}/${f}" --create-dirs "https://raw.githubusercontent.com/pandark/setup_42/master/.dotfiles/${f}"
    fi
done

for f in ".nvimlog" ".lesshst" ".zcompdump"; do
    if [ ! -L $f ]; then
        rm -Rf $f
        ln -s ${HOME}/$f
    fi
done

if [ ! -d "${HOME}/.brew" ]; then
    mkdir ${HOME}/.brew && \
        curl -L https://github.com/Homebrew/homebrew/tarball/master | \
        tar xz --strip 1 -C ${HOME}/.brew
        brew update
        brew upgrade
fi

if [ ! -f "${HOME}/.brew/share/zsh/site-functions/_brew" ] ; then
     curl -Lo "${HOME}/.brew/share/zsh/site-functions/_brew" https://raw.githubusercontent.com/Homebrew/homebrew/master/Library/Contributions/brew_zsh_completion.zsh
fi

if [ -z "$(brew list | grep -w neovim)" ]; then
    brew tap neovim/neovim
    brew install --HEAD neovim

    curl -fLo ${HOME}/.config/nvim/autoload/plug.vim \
        --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

for software in "tree" "pstree" "the_silver_searcher" "htop-osx" "wget" "valgrind" "ranger" "redshift" "node" "python" "python3"; do
    if [ -z "$(brew list | grep -w $software)" ]; then
        brew install $software
    fi
done

if [ -n "$(whence npm)" ]; then
    npm config set prefix '${HOME}/.npm-packages'
fi
