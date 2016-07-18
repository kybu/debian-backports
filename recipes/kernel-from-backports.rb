include_recipe 'debian-backports::common'

cookbook_file 'apt-official-backports-source.list' do
  path '/etc/apt/sources.list.d/apt-official-backports-source.list'
end

bash 'apt-get update' do
  code 'apt-get -qq update'
end

bash 'install kernel from backports' do
  code 'apt-get -qq -t jessie-backports install linux-image-amd64 linux-headers-amd64'
end