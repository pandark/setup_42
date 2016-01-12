My setup at 42
==============

# Get and load the .zshrc

``` sh
curl -Lo ${HOME}/.zshrc https://raw.githubusercontent.com/pandark/setup_42/master/.dotfiles/.zshrc
source ${HOME}/.zshrc
```

# Clone the repo

``` sh
git clone https://github.com/pandark/setup_42.git ${REMOTE_HOME}
${REMOTE_HOME}/install.sh
```

# Manual steps

* Read the end of `${REMOTE_HOME}/install.sh` for OCaml install.
* Open `nvim` and run :PlugInstall
