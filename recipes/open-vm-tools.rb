backport_install 'dkms'

backport_install 'open-vm-tools' do
  install :dist_upgrade
end