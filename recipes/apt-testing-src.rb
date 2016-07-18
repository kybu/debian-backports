include_recipe 'debian-backports::common'

bash 'Update repository keys' do
  code 'apt-key update'
end

package 'aptitude'

cookbook_file 'apt-testing-src-source.list' do
  path '/etc/apt/sources.list.d/apt-testing-src.list'
end

bash 'aptitude update' do
  code 'aptitude -y update'
end
