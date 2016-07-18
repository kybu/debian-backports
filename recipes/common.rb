cookbook_file '/etc/profile.d/unsafe_configure.sh' do
  source 'unsafe_configure.sh'
  owner 'root'
  group 'root'
  mode '0555'
end

package 'build-essential'