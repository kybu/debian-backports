cookbook_file 'apt-official-backports-source.list' do
  path '/etc/apt/sources.list.d/apt-official-backports-source.list'
end

bash 'apt-get update' do
  code 'apt-get -qq update'
end

include_recipe 'chef-sugar::default'

bash 'install kernel from backports' do
  code 'apt-get -qq -t jessie-backports install linux-image-amd64 linux-headers-amd64'
end

if vmware?
  bash 'install dkms and vmware tools for all kernels' do
    code <<BLA
apt-get -qq -t jessie-backports install dkms
apt-get -qq -t jessie-backports install open-vm-tools-dkms

# Going to rebuild all extra kernel modules for all installed kernels.
# open-vm-tools package was installed just for the actual kernel.

dkms autoinstall `(cd /lib/modules && echo *) |awk '{print "-k "$1" -k "$2}'`
BLA
  end
end
