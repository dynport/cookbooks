include_recipe "java"

INSTALL_DIR = "/opt"
SOLR_USER = "solr"
SOLR_VERSION = "3.6.0"

SOLR_DATA_DIR = "/data/solr"
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

remote_file "#{SRC_DIR}/#{SOLR_FILE}" do
  source "http://mirror.netcologne.de/apache.org/lucene/solr/#{SOLR_VERSION}/#{SOLR_FILE}"
  mode "0644"
  checksum "3acac4323ba3dbfa153d8ef01f156bab9b0eccf1b1f1f03e91b8b6739d3dc6c6"
end

execute "install solr" do
  cwd INSTALL_DIR
  command "tar xvfz #{SRC_DIR}/#{SOLR_FILE}"
  creates "#{SOLR_DIR}/example/start.jar"
end

link "#{INSTALL_DIR}/apache-solr" do
  to SOLR_DIR
end

directory SOLR_DATA_DIR do
  action :create
  owner SOLR_USER
  recursive true
end

directory "#{SOLR_DATA_DIR}/conf" do
  action :create
  owner SOLR_USER
  recursive true
end

template "/etc/init.d/solr-jetty" do
  source "solr-jetty.erb"
  mode "0744"
end

execute "cp -Rv #{File.expand_path("../../files/conf", __FILE__)} #{SOLR_DATA_DIR} && chown #{SOLR_USER} #{SOLR_DATA_DIR}" do
  creates "#{SOLR_DATA_DIR}/conf/schema.xml"
end