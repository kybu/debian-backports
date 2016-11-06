package 'aptly'

pub_key = ::File.read(cookbook_file_location('gpg_pub.key', 'debian-backports'))
bsw_gpg_load_key_from_string 'Import public GPG key' do
  key_contents pub_key
  for_user 'root'
end

priv_key = cookbook_file_contents 'gpg_priv.key', 'debian-backports'
bsw_gpg_load_key_from_string 'Import private GPG key' do
  key_contents priv_key
  for_user 'root'
end

cookbook_file 'gpg_pub.key' do
  path '/root/.gnupg/bilbo_gpg_pub.key'
end

bash 'Add the gpg key into the packaging system' do
  code 'apt-key add /root/.gnupg/bilbo_gpg_pub.key'
end

aptly_repo 'debian-backports' do
  action :create
  comment "Debian backports"
  component 'main'
  distribution 'jessie'
end

bash 'Create debian-backports package repository' do
  code <<BLA
aptly publish repo -architectures=amd64 debian-backports debian-backports
ln -s /root/.aptly/public/debian-backports /var/lib/debian-backports
BLA
  not_if { File.symlink? '/var/lib/debian-backports' }
end

cookbook_file 'apt-debian-backports-source.list' do
  path '/etc/apt/sources.list.d/debian-backports.list'
end

cookbook_file 'apt-preferences-debian-backports' do
  path '/etc/apt/preferences.d/debian-backports'
end
