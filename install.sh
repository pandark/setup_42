#!/usr/bin/env zsh

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

cd ~/
for f in ".zshrc" ".config" ".gitconfig" ".gitignore_global" ".npmrc" ".ssh" ".gdbinit" ".lldbinit" ".ocamlinit"; do
    rm -Rf $f;
    ln -s ${REMOTE_HOME}/.dotfiles/$f;
done

cd ~/
for f in ".nvimlog" ".opam" ".lesshst" ".zcompdump"; do
    rm -Rf $f;
    ln -s ${REMOTE_HOME}/$f;
done

if [ ! -d "${REMOTE_HOME}/.brew" ]; then
    mkdir ${REMOTE_HOME}/.brew && \
        curl -L https://github.com/Homebrew/homebrew/tarball/master | \
        tar xz --strip 1 -C ${REMOTE_HOME}/.brew
fi

if [ ! -f "${REMOTE_HOME}/.brew/share/zsh/site-functions/_brew" ] ; then
     curl -Lo "${REMOTE_HOME}/.brew/share/zsh/site-functions/_brew" https://raw.githubusercontent.com/Homebrew/homebrew/master/Library/Contributions/brew_zsh_completion.zsh
fi

if [ "$(which brew)" = "${REMOTE_HOME}/.brew/bin/brew" ]; then
    brew update && brew upgrade

    brew tap neovim/neovim
    brew install --HEAD neovim

    brew install tree
    brew install pstree
    brew install ag
    brew install htop
    brew install wget
    brew install valgrind
    brew install ranger
    brew install tig
    brew install redshift

    # requires sudo
    #brew cask install exa
fi

curl -fLo ~/.config/nvim/autoload/plug.vim \
    --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

brew install node
npm config set prefix '${REMOTE_HOME}/.npm-packages'

brew install python
brew install python3

# Install XQuartz, reboot, then...
if [ -n "$(which-command Xquartz)" ]; then
brew install ocaml --with-x11
brew install rlwrap
brew install opam
opam init
sed -i -E "s#/nfs/.*/$USER/#\${REMOTE_HOME}/#g" ~/.opam/opam-init/init.*
eval $(opam config env)
fi
#opam switch 4.02.0
#eval $(opam config env)
#opam install lablgtk
