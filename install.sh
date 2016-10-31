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

######################
#        OS X        #
######################
#
#### dock ###
## remove all application
#defaults delete com.apple.dock persistent-apps
#defaults delete com.apple.dock persistent-others
#
## add application
#defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/System Preferences.app/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
#defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Firefox.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
#defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/iTerm 2.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
#defaults write com.apple.dock persistent-apps -array-add '<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>/Applications/Slack.app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>'
#
## change dock size
#defaults write com.apple.dock tilesize -int 40
#
## set the dock on the right of the screen
#defaults write com.apple.dock orientation -string "bottom"
#
## do not rearrange space based on recent use
#defaults write com.apple.dock mru-spaces -bool false
#
## restart dock to apply changes
#killall Dock
#
#### dock end ###
#
#### finder ###
#
## set preferred view style
#defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
#
## New window points to home
#defaults write com.apple.finder NewWindowTarget -string "PfHm"
#
## Avoid creating .DS_Store files on network volumes
#defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
#
## show path bar
#defaults write com.apple.finder ShowPathbar -int 1
#
## show Library folder
#chflags nohidden ~/Library/
#
#### finder end ###
#
#### mouse ###
#
## scroll not "natural"
#defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
#
#### mouse end ###
#
#### spotlight ###
#
## remove everything from spotlight but applications
#defaults write com.apple.spotlight orderedItems -array \
#	'{"enabled" = 1;"name" = "APPLICATIONS";}' \
#	'{"enabled" = 0;"name" = "SYSTEM_PREFS";}' \
#	'{"enabled" = 0;"name" = "DIRECTORIES";}' \
#	'{"enabled" = 0;"name" = "PDF";}' \
#	'{"enabled" = 0;"name" = "FONTS";}' \
#	'{"enabled" = 0;"name" = "DOCUMENTS";}' \
#	'{"enabled" = 0;"name" = "MESSAGES";}' \
#	'{"enabled" = 0;"name" = "CONTACT";}' \
#	'{"enabled" = 0;"name" = "EVENT_TODO";}' \
#	'{"enabled" = 0;"name" = "IMAGES";}' \
#	'{"enabled" = 0;"name" = "BOOKMARKS";}' \
#	'{"enabled" = 0;"name" = "MUSIC";}' \
#	'{"enabled" = 0;"name" = "MOVIES";}' \
#	'{"enabled" = 0;"name" = "PRESENTATIONS";}' \
#	'{"enabled" = 0;"name" = "SPREADSHEETS";}' \
#	'{"enabled" = 0;"name" = "SOURCE";}' \
#	'{"enabled" = 0;"name" = "MENU_DEFINITION";}' \
#	'{"enabled" = 0;"name" = "MENU_OTHER";}' \
#	'{"enabled" = 0;"name" = "MENU_CONVERSION";}' \
#	'{"enabled" = 0;"name" = "MENU_EXPRESSION";}' \
#	'{"enabled" = 0;"name" = "MENU_WEBSEARCH";}' \
#	'{"enabled" = 0;"name" = "MENU_SPOTLIGHT_SUGGESTIONS";}'
#
#### spotlight end ###
#
#### menu bar ###
#
## display hour in 24h format
#defaults write com.apple.menuextra.clock DateFormat -string "EEE dd/MM/yyyy HH:mm"
#defaults write NSGlobalDomain AppleICUForce12HourTime -bool false
#
#### menu bar end ###
#
#### security ###
#
#defaults write com.apple.screensaver askForPassword -int 1
#
#### security end ###
