include_recipe "source"
include_recipe "nginx"

%w(libcairo2-dev python-cairo python-twisted python-django python-django-tagging gunicorn python-memcache).each do |pkg|
  package pkg
end

GRAPHITE_PREFIX = "graphite-web-0.9.10-pre4"
GRAPHITE_FILE = "#{GRAPHITE_PREFIX}.tar.gz"

CARBON_PREFIX = "carbon-0.9.10-pre3"
CARBON_FILE = "#{CARBON_PREFIX}.tar.gz"

WHISPER_PREFIX = "whisper-0.9.10-pre3"
WHISPER_FILE = "#{WHISPER_PREFIX}.tar.gz"

download_file "https://launchpad.net/graphite/0.9/0.9.10/+download/#{GRAPHITE_FILE}"
download_file "https://launchpad.net/graphite/0.9/0.9.10/+download/#{CARBON_FILE}"
download_file "https://launchpad.net/graphite/0.9/0.9.10/+download/#{WHISPER_FILE}"

USER = node.graphite.user

user USER do
  action :create
  shell "/bin/bash"
end

GRAPHITE_DIR = "/opt/graphite"
DJANGO_ROOT = "#{GRAPHITE_DIR}/webapp/graphite"

directory GRAPHITE_DIR do
  owner USER
  mode "0755"
end

execute "install whisper" do
  cwd "/tmp"
  command "tar xvfz #{src_dir}/#{WHISPER_FILE} && cd /tmp/#{WHISPER_PREFIX} && python setup.py install --prefix #{GRAPHITE_DIR}"
  creates "#{GRAPHITE_DIR}/bin/whisper-fetch.py"
  user USER
end

execute "install carbon" do
  cwd "/tmp"
  command "tar xvfz #{src_dir}/#{CARBON_FILE} && cd /tmp/#{CARBON_PREFIX} && python setup.py install --prefix #{GRAPHITE_DIR}"
  creates "#{GRAPHITE_DIR}/bin/carbon-client.py"
  user USER
end

execute "unpack graphite-web" do
  cwd "/tmp"
  command "tar xvfz #{src_dir}/#{GRAPHITE_FILE} && cd /tmp/#{GRAPHITE_PREFIX} && python setup.py install --prefix #{GRAPHITE_DIR}"
  creates "#{GRAPHITE_DIR}/conf/graphite.wsgi.example"
  user USER
end

execute "create django database" do
  cwd DJANGO_ROOT
  command "python ./manage.py syncdb --noinput"
  user USER
  creates "#{GRAPHITE_DIR}/storage/graphite.db"
end

WHISPER_DATA_DIR = node.graphite.whisper_data_dir

directory WHISPER_DATA_DIR do
  recursive true
  owner USER
end

execute "symlink whisper" do
  command "rmdir #{GRAPHITE_DIR}/storage/whisper; ln -nfs #{WHISPER_DATA_DIR} #{GRAPHITE_DIR}/storage/whisper"
  not_if "readlink #{GRAPHITE_DIR}/storage/whisper | grep #{WHISPER_DATA_DIR}"
  user USER
end

template "#{GRAPHITE_DIR}/conf/carbon.conf" do
  owner USER
  mode "644"
end

template "#{GRAPHITE_DIR}/conf/storage-aggregation.conf" do
  owner USER
  mode "644"
end

template "#{GRAPHITE_DIR}/conf/storage-schemas.conf" do
  owner USER
  mode "644"
end

template "/etc/init.d/graphite" do
  mode "755"
end

nginx_unix_proxy(:name => "graphite", :socket_path => "/tmp/graphite.socket", :root => DJANGO_ROOT, 
  :location => "/", :server_name => node.graphite.server_name, :interface => node.graphite.nginx_interface, :port => node.graphite.nginx_port
)