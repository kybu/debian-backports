cookbook_file '/etc/profile.d/unsafe_configure.sh' do
  source 'unsafe_configure.sh'
  owner 'root'
  group 'root'
  mode '0555'
end

cookbook_file 'apt-conf-90ignore-release-date' do
  path '/etc/apt/apt.conf.d/90ignore-release-date'
end

Dir['/etc/apt/sources.list.d/*']+['/etc/apt/sources.list'].each do |source_list|
  next if source_list == '/etc/apt/sources.list.d/debian-sources.list'

  delete_lines "Delete all deb-src entries from #{source_list}" do
    path source_list
    pattern %q{^\s*deb-src\b}

    notifies :run, 'ruby_block[apt sources changed]', :immediately
  end
end

file '/etc/apt/sources.list.d/debian-sources.list' do
  content "deb-src #{node['debian-backports']['sources']}"

  notifies :run, 'ruby_block[apt sources changed]', :immediately
end

ruby_block 'apt sources changed' do
  block { node.default['debian-backports']['sources-changed'] = true }
  action :nothing
end

bash 'apt-get update after sources list change' do
  code 'apt-get -qq update'

  only_if { !node['debian-backports']['sources-changed'].nil? }
end

package 'build-essential'

include_recipe 'debian-backports::aptly-local-repo'
include_recipe 'debian-backports::must-have'