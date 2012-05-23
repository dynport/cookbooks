include_recipe "java"

INSTALL_DIR = "/opt"
JENKINS_USER = node.jenkins.user
JENKINS_DIR = "#{INSTALL_DIR}/jenkins-#{node.jenkins.version}"
SRC_DIR = "#{INSTALL_DIR}/src"


user JENKINS_USER do
  action :create
  shell "/bin/bash"
end

directory "/home/#{JENKINS_USER}" do
  mode "755"
  owner JENKINS_USER
end

directory SRC_DIR do
  action :create
  recursive true
end

directory "#{INSTALL_DIR}/jenkins/lib" do
  owner JENKINS_USER
  recursive true
end

JENKINS_FILE = "jenkins-#{node.jenkins.version}.war"

JENKINS_PATH = "#{INSTALL_DIR}/jenkins/lib/#{JENKINS_FILE}"

remote_file JENKINS_PATH do
  source "http://mirrors.jenkins-ci.org/war/#{node.jenkins.version}/jenkins.war"
  owner JENKINS_USER
  mode "0644"
  not_if "test -e #{JENKINS_PATH}"
end

link "#{INSTALL_DIR}/jenkins/lib/jenkins.war" do
  to JENKINS_PATH
end

template "/etc/init.d/jenkins" do
  source "jenkins_start_stop.erb"
  mode "0744"
end