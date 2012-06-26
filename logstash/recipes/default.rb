LOGSTASH_FILE = "logstash-#{node.logstash.version}-monolithic.jar"
LOGSTASH_DIR = "/opt/lib"
LOGSTASH_PATH = "#{LOGSTASH_DIR}/#{LOGSTASH_FILE}"

directory LOGSTASH_DIR do
  recursive true
end

remote_file LOGSTASH_PATH do
  source "http://semicomplete.com/files/logstash/#{LOGSTASH_FILE}"
  not_if "test -e #{LOGSTASH_PATH}"
end

template "/etc/logstash.conf" do
end
