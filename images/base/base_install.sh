#!/bin/bash

set -ex

apt -y update

apt install -y  --no-install-recommends locales apt-utils
sed -i -e "s/# $LC_ALL UTF-8/$LC_ALL UTF-8/" /etc/locale.gen
dpkg-reconfigure --frontend=noninteractive locales
update-locale LANG=$LANG

MINIMUM_DEPS=(
	# Build
    binutils
	build-essential
	patch
	make
	gawk
	# Cairo / pygobject
	pkg-config
	libcairo2-dev
	libgirepository1.0-dev
	gir1.2-gtk-3.0
	# Libraries
	librsvg2-2
	librsvg2-common
	libpython3-dev
	openssl

	# Usability
	git
	curl
	wget
	sudo
	xterm
	parallel
	bzip2
	zip
	unzip
	unrar
	python3-pip
	python3-tk
)

UTILITY_DEPS=(
	# EDITORS
	neovim
	nano
	gedit

	# MISC
	tree
	less
	htop
	gtkwave
)

XSCHEM_DEPS=(
	libglu1-mesa
	libxpm4
	libtcl8.6
	libtk8.6
	libcairo2
	tcl-tclreadline
)


MAGIC_DEPS=(
	tk
	libglu1-mesa
	libcairo2
)

NGSPICE_DEPS=(
	libfftw3-bin
	libxaw7
	libxft2
)

GAW_DEPS=(
	libasound2
)

KLAYOUT_DEPS=(
	libqt5core5a
	libqt5designer5
	libqt5gui5
	libqt5multimedia5
	libqt5multimediawidgets5
	libqt5network5
	libqt5opengl5
	libqt5printsupport5
	libqt5sql5
	libqt5svg5
	libqt5widgets5
	libqt5xml5
	libqt5xmlpatterns5
	libgit2-1.1
	libruby3.0
	libqt5dbus5
)

OPENROAD_DEPS=(
	libqt5charts5
)

ORFS_DEPS=(
	time
)

DEPS=(
	"${MINIMUM_DEPS[@]}"
	"${UTILITY_DEPS[@]}"
	"${XSCHEM_DEPS[@]}"
	"${MAGIC_DEPS[@]}"
	"${NGSPICE_DEPS[@]}"
	"${GAW_DEPS[@]}"
	"${KLAYOUT_DEPS[@]}"
	"${OPENROAD_DEPS[@]}"
	"${ORFS_DEPS[@]}"
)

apt install -y --no-install-recommends "${DEPS[@]}"

rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*
apt -y autoremove --purge
apt -y clean

# tigervnc-standalone-server \
# xfce4 \
# xfce4-terminal \

update-alternatives --install /usr/bin/python python /usr/bin/python3 0	
