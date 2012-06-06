include_recipe "java"

INSTALL_DIR = node.source.install_dir
JENKINS_USER = node.jenkins.user
JENKINS_USER_HOME = "/home/#{JENKINS_USER}"

JENKINS_DIR = "#{INSTALL_DIR}/jenkins-#{node.jenkins.version}"
SRC_DIR = "#{INSTALL_DIR}/src"
JENKINS_HOME = "#{JENKINS_USER_HOME}/.jenkins"

user JENKINS_USER do
  action :create
  shell "/bin/bash"
end

directory JENKINS_HOME do
  mode "755"
  owner JENKINS_USER
end

directory SRC_DIR do
  action :create
  recursive true
end

JENKINS_FILE = "jenkins-#{node.jenkins.version}.war"
JENKINS_PATH = "#{INSTALL_DIR}/jenkins/lib/#{JENKINS_FILE}"
JENKINS_JAR_DIR = "#{INSTALL_DIR}/jenkins/lib"

directory JENKINS_JAR_DIR do
  recursive true
end

remote_file JENKINS_PATH do
  source "http://mirrors.jenkins-ci.org/war/#{node.jenkins.version}/jenkins.war"
  owner JENKINS_USER
  mode "0644"
  not_if "test -e #{JENKINS_PATH}"
end

link "#{JENKINS_JAR_DIR}/jenkins.war" do
  to JENKINS_PATH
end

template "/etc/init.d/jenkins" do
  source "jenkins_start_stop.erb"
  mode "0744"
end

directory "#{JENKINS_HOME}/plugins" do
  owner JENKINS_USER
  mode "755"
  recursive true
end

node.jenkins.plugins.each do |plugin|
  remote_file "#{JENKINS_HOME}/plugins/#{plugin}.hpi" do
    source "http://updates.jenkins-ci.org/latest/#{plugin}.hpi"
    owner JENKINS_USER
  end
end

upstream_server = NginxConfigRenderer.upstream_server("jenkins_server", "#{node.jenkins.address}:#{node.jenkins.port}")
location = NginxConfigRenderer.proxied_location("/", "jenkins_server")
server = NginxConfigRenderer.server("#{node.nginx.address}:80", node.jenkins.server_name, "#{JENKINS_HOME}/war", [location])

create_nginx_upstream_proxy(:jenkins, [upstream_server, server].join("\n"))
