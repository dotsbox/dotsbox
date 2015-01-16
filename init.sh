#!/usr/bin/env bash

echo ""
echo "      ___       ___          ___          ___                   ___      "
echo "     /  /\     /__/\        /  /\        /  /\         ___     /  /\     "
echo "    /  /::\    \  \:\      /  /:/_      /  /:/_       /  /\   /  /::\    "
echo "   /  /:/\:\    \  \:\    /  /:/ /\    /  /:/ /\     /  /:/  /  /:/\:\   "
echo "  /  /:/~/:/_____\__\:\  /  /:/_/::\  /  /:/ /::\   /  /:/  /  /:/~/:/   "
echo " /__/:/ /://__/::::::::\/__/:/__\/\:\/__/:/ /:/\:\ /  /::\ /__/:/ /:/___ "
echo " \  \:\/:/ \  \:\~~\~~\/\  \:\ /~~/:/\  \:\/:/~/://__/:/\:\\  \:\/:::::/ "
echo "  \  \::/   \  \:\  ~~~  \  \:\  /:/  \  \::/ /:/ \__\/  \:\\  \::/~~~~  "
echo "   \  \:\    \  \:\       \  \:\/:/    \__\/ /:/       \  \:\\  \:\      "
echo "    \  \:\    \  \:\       \  \::/       /__/:/         \__\/ \  \:\     "
echo "     \__\/     \__\/        \__\/        \__\/                 \__\/     "
echo ""
echo "        ..........................................................       "
echo "        . Dotfiles 0.1.0 (DotsBox) for setting up OSX Workspace  .       "
echo "        .      https://github.com/dotsbox/dotsbox.git           .       "
echo "        ..........................................................       "
echo ""

# To run this, you must download & install the latest Xcode and Commandline Tools
# https://developer.apple.com/xcode/
# https://developer.apple.com/downloads/

# Configurations
USER=dotsbox
DOTS=dots
BOX=box
DEST_DOTSBOX=${HOME}/.dotsbox

# os_verification
os_verification() {
	echo ""
	echo "Step 0 : VERIFY '$(uname -s)' != 'Darwin'"
	[[ "$(uname -s)" != "Darwin" ]] && exit 0
	echo " ---> OS Type: Darwin"
  	echo "*** Before running this script, you should do the following things:"
  	echo " ---> run 'ssh-keygen' to generate your SSH key"
  	echo " ---> add the key to GitHub"
}

# Install Xcode
install_xcode() {
	echo ""
	echo "Step 1a : VERIFY -x /usr/bin/gcc"
	# Download and install Command Line Tools
	if [[ -x /usr/bin/gcc ]]; then
		echo " ---> Xcode is already installed."
		return
	fi

	echo "Step 1b : INSTALL xcode-select --install"
	echo "*** If a dialog is shown, \
	push 'Get Xcode' button to download Xcode before proceeding! ***"
	xcode-select --install

	echo "Step 1c : RUN xcodebuild -license"
	sudo xcodebuild -license
}

# Install Homebrew
install_homebrew() {
	echo ""
	echo "Step 2a : VERIFY --f /usr/local/bin/brew"
  	if [[ -f /usr/local/bin/brew ]]; then
    	echo " ---> Homebrew is already installed."
    	return
	fi

	echo "Step 2b : INSTALL ruby -e $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

	echo "Step 2c : RUN brew doctor"
  	brew doctor
}

# Install packages for running Ansible playbook
install_ansible() {
	echo ""
	echo "Step 3a : VERIFY pip"
	if [[ ! -x `which pip` ]]; then
		echo "Step 3b : INSTALL easy_install pip"
		sudo easy_install pip
	fi

	echo "Step 3c : VERIFY pip && ansible "
	if [[ -x `which pip` && ! -x `which ansible` ]]; then
		echo "Step 3d : INSTALL ansible"
		sudo CFLAGS=-Qunused-arguments CPPFLAGS=-Qunused-arguments pip install ansible
	fi
}

# Clone my GitHub repository
clone_dots() {
	echo ""
	echo "Step 4a : VERIFY  dots"
  	if [[ -d ${DEST_DOTSBOX}/${DOTS} ]]; then
    	echo " ---> Repository ${USER}/${DOTS} is already cloned."
    	return
  	fi

	echo "Step 4b : MAKE  mkdir -p $DEST_DOTSBOX"
  	mkdir -p $DEST_DOTSBOX

  	echo "Step 4c : RUN  cd $DEST_DOTSBOX"
  	cd $DEST_DOTSBOX

	echo "Step 4d : CLONE  git clone git@github.com:${USER}/${DOTS}.git"
  	git clone --recursive git@github.com:${USER}/${DOTS}.git
}

provision_dots() {
	echo ""
	echo "Step 5a : INSTALL brew install git"
  	brew install git
	echo "Step 5b : RUN  cd $DEST_DOTSBOX/${DOTS}"
	cd "$DEST_DOTSBOX/${DOTS}"
	echo "Step 5c : EXEC script/bootstrap"
	script/bootstrap
}

# Clone my GitHub repository
clone_box() {
  	echo ""
	echo "Step 6a : VERIFY  box"
  	if [[ -d ${DEST_DOTSBOX}/${BOX} ]]; then
    	echo " ---> Repository ${USER}/${BOX} is already cloned."
    	return
  	fi

	# echo "Step 4b : RUN  mkdir -p $DEST_DOTSBOX"
  	# mkdir -p $DEST_DOTSBOX

  	echo "Step 6b : RUN  cd $DEST_DOTSBOX"
  	cd $DEST_DOTSBOX

	echo "Step 6c : CLONE  git clone git@github.com:${USER}/${BOX}.git"
  	git clone git@github.com:${USER}/${BOX}.git
}

# Provision
provision_box() {
	echo ""
	echo "Step 7a : RUN  cd $DEST_DOTSBOX/${BOX}"
  	cd "${DEST_DOTSBOX}/${BOX}"
  	echo " ---> Start provisioning..."
  	echo "Step 7b : EXEC  ansible-playbook site.yml"
  	ansible-playbook site.yml
}

# Run the above functions
run() {
	os_verification
  	install_xcode
  	install_homebrew
  	clone_dots
  	provision_dots
  	clone_box
  	provision_box
}

run
