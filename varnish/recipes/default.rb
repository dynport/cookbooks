package 'curl'

execute "add varnish key to apt" do
  command "curl http://repo.varnish-cache.org/debian/GPG-key.txt | apt-key add -"
end

execute "add varnish debian repo to sources" do
  command "echo 'deb http://repo.varnish-cache.org/debian/ squeeze varnish-3.0' >> /etc/apt/sources.list && apt-get update"
end

package 'varnish'

template '/etc/varnish/default.vcl' do
  source 'default.vcl.erb'
end

template '/etc/default/varnish' do
  source 'varnish.erb'
end

service 'varnish' do
  action [:stop, :start] 
end

# see varnish.erb for start script options
#execute 'start varnish' do
  #command "varnishd -f /etc/varnish/default.vcl -s malloc,1G -T 127.0.0.1:2000 -a #{node.varnish.listen_interface}:#{node.varnish.listen_port}"
#end
# Nginx needs to listen on 443 => Varnish => Nginx on 127.0.0.1:80 proxying unicorn or unicorn on port instead of socket
# TODO: Benchmark if this is any enhancement and decide wether setup is feasible
# Also: remember that nginx projects have to listen on localhost:8080 in this setup, achieved this with:
# 
#server {
#  listen <%= nginx_interface %>:<%= nginx_listen_port %>;
#
#
#def nginx_interface
#  if node[:enable_varnish]   
#    node[:varnish][:backend_interface]
#  else
#    '0.0.0.0'
#  end
#end
#
#def nginx_listen_port
#  if node[:enable_varnish]    
#    node[:varnish][:backend_port]
#  else
#    '80'
#  end
#end
