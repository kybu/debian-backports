include_recipe 'debian-backports::common'

backport_install 'debian-keyring'

backport_install 'dh-python'

backport_install 'dh-make'

backport_install 'bash-completion'

backport_install 'dh-strip-nondeterminism'

package 'dh-strip-nondeterminism'

backport_install 'devscripts' do
  install :dist_upgrade
end

backport_install 'dh-autoreconf'

# tar needs FORCE_UNSAFE_CONFIGURE=1
# Newer tar is needed by dpkg-dev
backport_install 'tar'

backport_install 'dpkg-dev'

backport_install 'debhelper'