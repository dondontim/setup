#!/usr/bin/env bash
#
# Install command-line tools using Homebrew.


echo "exititing brew.sh"
exit 0

# Run this file ./brew.sh > brew.log

# Install Homebrew (if not installed)
echo "Installing Homebrew."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


function brew_install() {
  brew install "$1" && {
    echo "[+] [$1] Success"
    echo "[+] [$1] Success" >> brew2.log
  } || {
    echo "[!] [$1] An error occurred"
    echo "[!] [$1] An error occurred" >> brew_install.log
  }
}
function brew_cask() {
  brew install --cask "$1" && {
    echo "[+] [$1] Success"
    echo "[+] [$1] Success" >> brew2.log
  } || {
    echo "[!] [$1] An error occurred"
    echo "[!] [$1] An error occurred" >> brew_cask.log
  }
}

################################################################################
# How to replace Mac OS X utilities with GNU core utilities?                   #
################################################################################
#
# This adds symlinks for GNU utilities with g prefix to /usr/local/bin/:
### brew install coreutils findutils gnu-tar gnu-sed gawk gnutls gnu-indent gnu-getopt grep
#
# If you want to use the commands without a g prefix add for example
# /usr/local/opt/coreutils/libexec/gnubin before other directories on your PATH.
#
# Additionally, you can access their man pages with normal names if you add
# the "gnuman" directory to your MANPATH from your bashrc as well:
#
# MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"


# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Install GNU core utilities (those that come with macOS are outdated).
# Don’t forget to add `$(brew --prefix coreutils)/libexec/gnubin` to `$PATH`.
brew_install coreutils
ln -s "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"

# Install some other useful utilities like `sponge`.
brew_install moreutils
# Install GNU `find`, `locate`, `updatedb`, and `xargs`, `g`-prefixed.
brew_install findutils
# Install GNU `sed`, overwriting the built-in `sed`.
brew_install gnu-sed --with-default-names
# Install a modern version of Bash.
brew_install bash
brew_install bash-completion2

# Switch to using brew-installed bash as default shell
#if ! fgrep -q "${BREW_PREFIX}/bin/bash" /etc/shells; then
#  echo "${BREW_PREFIX}/bin/bash" | sudo tee -a /etc/shells;
#  chsh -s "${BREW_PREFIX}/bin/bash";
#fi;


# Switch to zsh as default shell
chsh -s $(which zsh)

# Install `wget` with IRI support.
brew_install wget --with-iri

# Install GnuPG to enable PGP-signing commits.
brew_install gnupg

# Install more recent versions of some macOS tools.
brew_install vim --with-override-system-vi
brew_install grep
brew_install openssh
brew_install screen
brew_install php
brew_install gmp

# Install font tools.
#brew tap bramstein/webfonttools
#brew_install sfnt2woff
#brew_install sfnt2woff-zopfli
#brew_install woff2

# Install some CTF tools; see https://github.com/ctfs/write-ups.
brew_install aircrack-ng
brew_install bfg
brew_install binutils
brew_install binwalk
brew_install cifer
brew_install dex2jar
brew_install dns2tcp
brew_install fcrackzip
brew_install foremost
brew_install hashpump
brew_install hydra
brew_install john
brew_install knock
brew_install netpbm
brew_install nmap
brew_install pngcheck
brew_install socat
brew_install sqlmap
brew_install tcpflow
brew_install tcpreplay
brew_install tcptrace
brew_install ucspi-tcp # `tcpserver` etc.
brew_install xpdf
brew_install xz

# Install other useful binaries.
brew_install ack
#brew_install exiv2
brew_install git
brew_install git-lfs
brew_install gs
brew_install imagemagick --with-webp
brew_install lua
brew_install lynx
brew_install p7zip
brew_install pigz
brew_install pv
brew_install rename
brew_install rlwrap
brew_install ssh-copy-id
brew_install tree
brew_install vbindiff
brew_install zopfli



###############################################################################
##### Custom stuff from here
###############################################################################

# Connect and disconnect Bluetooth devices
brew_install bluetoothconnector
# Get/set bluetooth power and discoverable state
brew_install blueutil
# Platform built on V8 to build network applications
brew_install node #, link: false
# Improved top (interactive process viewer)
brew_install htop
# Interpreted, interactive, object-oriented programming language
brew_install python3
# Monitors sleep, wakeup, and idleness of a Mac
brew_install sleepwatcher

brew_install neovim
brew_install ffmpeg
brew_install youtube-dl


# gdrive 
brew_install gdrive # (gdrive CLI) 

# colordiff (wrapper for gnu diff command)
brew_install colordiff

# Highlight to color for example 'less' page viewer
brew_install highlight # or brew_install pygments depends on choice

# json viewer
brew_install fx # if you install fx, you can remove jsontools.plugin.zsh 

# GNU Readline Library so you can use .inputrc
# https://unix.stackexchange.com/a/424475 
brew_install readline

# Basic calculator
brew_install bc





#####
# Cask
#####


# Client for the Google Drive storage service
brew_cask google-drive # (google drive app)
# Tool to create native applications from command-line scripts
brew_cask platypus
# Move and resize windows using keyboard shortcuts or snap areas
brew_cask rectangle


# Browsers
brew_cask brave-browser
brew_cask google-chrome
brew_cask tor-browser

brew_cask burp-suite
brew_cask iterm2


# FROM BREWFILE
#brew tap "clintmod/formulas"
#brew tap "homebrew/bundle"
#brew tap "homebrew/cask"
#brew tap "homebrew/core"

brew tap "caskroom/cask" # Add more repositories to install vscode
brew_cask visual-studio-code

brew_cask microsoft-teams
brew_cask zoom

brew_cask virtualbox







#####
##### QuickLook Plugins
#####
#
### Links
# https://sayzlim.net/must-have-macos-quicklook-plugins/
#
# JUST INSTALL ALL PLUGINS FROM:
# https://github.com/sindresorhus/quick-look-plugins

mkdir -p ~/Library/QuickLook

brew install qlcolorcode qlstephen qlmarkdown quicklook-json qlimagesize suspicious-package apparency quicklookase qlvideo && {
    sudo mv /Library/QuickLook/Video.qlgenerator ~/Library/QuickLook
    # Remove quarantine from these packages so macos will not stop it from working
    xattr -d -r com.apple.quarantine ~/Library/QuickLook
    # Reload QuickLook
    # qlmanage -r resets Quick Look Server and all Quick Look client's generator cache.
    qlmanage -r 
    echo "[+] [brew quicklook] Success"
    echo "[+] [brew quicklook] Success" >> brew_install.log
} || {
    #echo "Some thing failed with QuickLook plugins"
    echo "[!] [brew quicklook] An error occurred"
    echo "[!] [brew quicklook] An error occurred" >> brew_install.log
}









### Ubuntu’s command-not-found equivalent for Homebrew on macOS
#
# https://github.com/Homebrew/homebrew-command-not-found
brew tap homebrew/command-not-found


# IP lookup command line tools that use the GeoIP library (ex. get ip location)
brew_install GeoIP


brew_install rust # rust contains its package manager called cargo (required to install viu)

# Awsome image viewer from terminal
# https://github.com/atanunq/viu
# Other such tools: https://askubuntu.com/questions/97542/how-do-i-make-my-terminal-display-graphical-pictures
cargo install viu # it is possible to install with brew but with cargo is recommended 
#brew install viu


brew_install ack # grep-like text finder
brew_install gawk

















############################ DESKTOP ###########################################

### Command-line translator
# Ref: https://github.com/soimort/translate-shell
# Download the self-contained executable and place it into your path.
mkdir -p ~/bin
wget git.io/trans && chmod +x ./trans && mv ./trans ~/bin


# FTP Client and talk other protocols
brew_install lftp



##### SFTP WITH AUTO COMPLETION

# 1. Macports 
# SSH protocol suite and sftp built with tab completion.
# https://ports.macports.org/port/openssh/

# 2. withreadline
# http://www.greenend.org.uk/rjk/sw/withreadline.html

# 3. lftp
# https://how-to.fandom.com/wiki/How_to_use_lftp_as_a_sftp_client

# 4. Made by someone
# https://askubuntu.com/a/14658





# TODO(tim): install macports (brew equivalent)
# https://www.macports.org/install.php




# Remove outdated versions from the cellar.
brew cleanup
