# https://launchpad.net/~ubuntu-lxc/+archive/ubuntu/lxd-stable/+packages

backport_install 'init-system-helpers'

backport_install 'sysvinit-utils'

backport_install 'util-linux'

backport_install 'dh-systemd' do
  install :dist_upgrade
end