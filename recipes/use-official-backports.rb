cookbook_file 'apt-official-backports-source.list' do
  path '/etc/apt/sources.list.d/apt-official-backports-source.list'
end

cookbook_file 'apt-preferences-official-backports' do
  path '/etc/apt/preferences.d/official-backports'
end

bash 'apt-get update' do
  code 'apt-get -qq update'
end

bash 'apt-get dist-upgrade' do
   code 'apt-get -qq dist-upgrade'
end