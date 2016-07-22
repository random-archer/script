#!/bin/bash

log() {
    1>&2 echo "### aur: $1"
}

is_root() {
    [[ $(id -u) == "0" ]]
}

sudo_user() {
    is_root || return 0 
    printf "sudo -u $user"    
}

assert_sudo() {
    sudo bash -c "echo > /dev/null"
}

sudo_create() {
    is_root || return 0 
    echo "$user ALL=(ALL) NOPASSWD: ALL" > "$sudo_file"
}

sudo_delete() {
    [[ -e "$sudo_file" ]] || return 0 
    rm -f "$sudo_file"
}

random_string() {
    cat /dev/urandom | tr -d -c 'a-z' | fold -w 32 | head -n 1
}

clean() {
    sudo_delete
    cd "$work"
}

error() {
    log "$name error: $1"
}

build() {
    local "$@"
    log "$name build"
    local pack="$name.tar.gz"
    local repo="https://aur.archlinux.org/cgit/aur.git/snapshot/$pack"
    local temp=$(mktemp -d /tmp/bash-aur=${name}.XXXXXXX)
    is_root && chown -R "$user" "$temp" || true
    cd "$temp"
    $(sudo_user) curl $repo -o "$pack"
    $(sudo_user) tar -xvf "$pack"
    cd "$name"
    $(sudo_user) $command
    rm -r -f "$temp"
}

build_list() {
    local name=
    for name in "$@" ; do
        build name="$name"
    done
}

###

trap 'error $LINENO' ERR
trap 'clean' EXIT
set -o posix -o errexit

readonly work=$(pwd)
readonly user="nobody"
readonly command="makepkg -s -r -i -c -f -L --skippgpcheck   --noconfirm"
readonly sudo_file="/etc/sudoers.d/$(random_string)"

assert_sudo
sudo_create
build_list $@
sudo_delete
