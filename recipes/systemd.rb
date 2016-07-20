include_recipe 'debian-backports::common'

backport_install 'init-system-helpers'

backport_install 'sysvinit-utils'

backport_install 'util-linux'

backport_install 'dh-systemd' do
  install :dist_upgrade
end

backport_install 'ifupdown'

backport_install 'e2fsprogs'

# initramfs needs busybox
backport_install 'busybox'

package 'busybox'

backport_install 'klibc'

backport_install 'initramfs-tools'

backport_install 'systemd' do
  control_file(Proc.new do |c|
    c.search_file_replace(
        /\b(libcap-dev|libapparmor-dev|apparmor|libseccomp-dev)\s+\(.*?\)/,
        '\1')
  end)

  install :dist_upgrade
end