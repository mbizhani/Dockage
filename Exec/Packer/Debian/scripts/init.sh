#!/bin/bash

apt-get update
apt-get upgrade --yes

A_USER="packer"

LS_CMD=$(cat << 'EOF'

## Added by Packer
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

EOF
)
echo "${LS_CMD}" >> /root/.bashrc
[ -f "/home/${A_USER}/.bashrc" ] && echo "${LS_CMD}" >> /home/${A_USER}/.bashrc


VIMRC=$(cat << 'EOF'
set pastetoggle=<F3>
set paste
syntax on
EOF
)
echo "${VIMRC}" >> /root/.vimrc
[ -f "/home/${A_USER}/.bashrc" ] && echo "${VIMRC}" >> /home/${A_USER}/.vimrc


if [ -f "/etc/vmware-tools/tools.conf" ]; then
  printf "\n[guestinfo]\nprimary-nics=en*\n" >> /etc/vmware-tools/tools.conf
fi

#  NIC="$(ip a | awk '/inet.*brd/{print $NF; exit}')"
#  if [ "${NIC}" ]; then
#    printf "\n[guestinfo]\nprimary-nics=%s\n" ${NIC} >> /etc/vmware-tools/tools.conf
#  fi