resource_name :backport

property :dsc_url

property :ignore_dependencies, Symbol, default: :no
property :verify, Symbol, default: :yes
property :version, String, default: nil

property :control_file
property :rules_file

property :nproc, Fixnum, default: `nproc`.to_i

action :run do
  pkg_name = name
  pkg_dir = "/root/deb-packages/#{pkg_name}"
  debian_release = node['debian-backports']['sources'].split(' ')[1]

  node.default['debian-backports']['already-installed'] = false
  pkgnames=`apt-cache pkgnames #{pkg_name}`.chop.each_line do |n|
    if Dir["/var/lib/debian-backports/**/#{n}_*.deb"].size != 0
      node.default['debian-backports']['already-installed'] = true
      next
    end
  end
  next if node.default['debian-backports']['already-installed'] == true
  node.default['debian-backports']['already-installed'] = false

  bash "#{name} - getting the source package using .dsc" do
    code <<BLA
rm -rf #{pkg_dir}
mkdir -p #{pkg_dir}
cd #{pkg_dir}
dget #{verify == :no ? " -u " : ""} #{dsc_url}
BLA

    not_if { dsc_url.nil? || dsc_url.empty? }
  end

  bash "#{name} - getting the source package" do
    code <<BLA
rm -rf #{pkg_dir}
mkdir -p #{pkg_dir}
cd #{pkg_dir}
apt-get source #{pkg_name}/#{debian_release}
BLA

    not_if { !dsc_url.nil? && !dsc_url.empty? }
  end

  bash "#{name} - install the source package build dependencies" do
    code <<BLA
cd #{pkg_dir}
d=`ls -d */`
# awk gets rid of package versions, e.g. "golang (>= 1.1)" to "golang"
deps=`cd $d && dpkg-checkbuilddeps 2>&1 | awk '{
  gsub(/^.*Unmet build dependencies:/,"") ;
  gsub(/\\([^\\)]*\\)|\\|/,"") ;
  gsub(/ libcurl-dev /, " ") ;
  print $0 }'`
[ -z ${deps} ] || apt-get -qq install ${deps}
BLA
  end

  ruby_block 'Debian control file patching' do
    block do
      control = Chef::Util::FileEdit.new(Dir["#{pkg_dir}/*/debian/control"][0])
      control_file.call control
      control.write_file
    end
    not_if { control_file == nil }
  end

  ruby_block 'Debian rules file patching' do
    block do
      rules = Chef::Util::FileEdit.new(Dir["#{pkg_dir}/*/debian/rules"][0])
      rules_file.call rules
      rules.write_file
    end
    not_if { rules_file == nil }
  end

  bash "#{name} - build" do
    code <<BLA
cd #{pkg_dir}
cd `ls -d */`
DEB_BUILD_OPTIONS='nocheck parallel=#{nproc}' FORCE_UNSAFE_CONFIGURE=1 dpkg-buildpackage -uc -us #{ignore_dependencies == :yes ? '-d' : ''}
BLA

    environment({   DEB_BUILD_MAINT_OPTIONS: 'hardening=-all',
                    DEB_CFLAGS_MAINT_SET: '-march=ivybridge -g -O2 -ffunction-sections -fdata-sections',
                    DEB_CXXFLAGS_MAINT_SET: '-march=ivybridge -g -O2 -ffunction-sections -fdata-sections',
                    DEB_LDFLAGS_SET: '-Wl,--gc-sections',
                    CROSS_ARCHS: ''})
  end

end
