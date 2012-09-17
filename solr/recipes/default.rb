include_recipe "java"

INSTALL_DIR = node.source.install_dir
SOLR_USER = "solr"
SOLR_VERSION = node.solr.version

SOLR_DATA_DIR = node.solr.home
SOLR_DIR = "#{INSTALL_DIR}/apache-solr-#{SOLR_VERSION}"
SRC_DIR = "#{INSTALL_DIR}/src"

SOLR_FILE = "apache-solr-#{SOLR_VERSION}.tgz"

user SOLR_USER do
  action :create
end

directory SRC_DIR do
  action :create
  recursive true
end

download_file "http://mirror.netcologne.de/apache.org/lucene/solr/#{SOLR_VERSION}/#{SOLR_FILE}"

execute "install solr" do
  cwd INSTALL_DIR
  command "tar xvfz #{SRC_DIR}/#{SOLR_FILE}"
  creates "#{SOLR_DIR}/example/start.jar"
end

link "#{INSTALL_DIR}/apache-solr" do
  to SOLR_DIR
end

["#{SOLR_DATA_DIR}/master", "#{SOLR_DATA_DIR}/slave"].each do |solr_home|
  directory solr_home do
    action :create
    owner SOLR_USER
    recursive true
  end

  template "#{solr_home}/solr.xml" do
    action :create_if_missing
    source "solr.xml"
    mode "0644"
    owner SOLR_USER
    variables(
      :solr_home => solr_home
    )
  end

  execute "init solr home" do
    command "cp -Rv #{File.expand_path("../../files/conf", __FILE__)} #{solr_home} && chown #{SOLR_USER} #{solr_home}"
    creates "#{solr_home}/conf/schema.xml"
  end

  template "#{solr_home}/conf/solrconfig.xml" do
    mode "0644"
    owner SOLR_USER
    source "solrconfig.xml.erb"
    variables(
      :solr_home => solr_home,
      :poll_interval => node.solr[:replication_poll_interval]
    )
  end
end

template "/etc/init.d/solr_master" do
  source "solr-jetty.erb"
  mode "0744"
  variables(
    :solr_home => "#{SOLR_DATA_DIR}/master",
    :solr_port => node.solr.master_port,
    :solr_host => node.solr[:host],
    :role => "master",
    :master_slave_options => "-Denable.master=true"
  )
end

template "/etc/init.d/solr_slave" do
  source "solr-jetty.erb"
  mode "0744"
  variables(
    :solr_home => "#{SOLR_DATA_DIR}/slave",
    :solr_port => node.solr.slave_port,
    :solr_host => node.solr[:host],
    :role => "slave",
    :master_slave_options => "-Denable.slave=true -Dmaster.url=#{node.solr.master_url}"
  )
end

