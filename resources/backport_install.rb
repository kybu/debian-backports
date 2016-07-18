resource_name :backport_install

property :dsc_url

property :ignore_dependencies, Symbol, default: :no
property :install, Symbol, default: :upgrade

property :control_file
property :rules_file

action :run do
  pkg_name = name
  idep = ignore_dependencies
  ctrl_file = control_file
  rls_file = rules_file
  dsc = dsc_url

  pkg_dir = "/root/deb-packages/#{pkg_name}"
  tmp_dir = '/root/deb-packages/_tmp'

  backport name do
    dsc_url dsc
    ignore_dependencies idep
    control_file(ctrl_file)
    rules_file(rls_file)
  end

  directory tmp_dir do
    action :delete
    recursive true
  end

  directory "#{tmp_dir} - create" do
    path tmp_dir
  end

  ruby_block "Copy #{pkg_name} deb files" do
    block do
      ::Dir[pkg_dir+'/*.deb'].each do |deb_file|
        Chef::Log.info "Copy #{deb_file}"
        rf = Chef::Resource::RemoteFile.new tmp_dir+"/"+::File.basename(deb_file), run_context
        rf.source "file://#{deb_file}"
        rf.run_action :create
      end
    end
  end

  aptly_repo '-force-replace debian-backports' do
    action :add
    directory tmp_dir
  end

  aptly_publish 'debian-backports' do
    action :create
    type 'repo'
    prefix ' debian-backports'
  end

  aptly_publish '-force-overwrite jessie' do
    action :update
    prefix 'debian-backports'
  end

  bash 'apt-get update' do
    code <<BLA
apt-get -qq update \
  -o Dir::Etc::sourcelist="sources.list.d/debian-backports.list" \
  -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"
BLA
  end

  bash 'apt-get upgrade' do
    code 'apt-get -qq upgrade'
    only_if { install == :upgrade}
  end

  bash 'apt-get dist-upgrade' do
    code 'apt-get -qq dist-upgrade'
    only_if { install == :dist_upgrade}
  end
end
