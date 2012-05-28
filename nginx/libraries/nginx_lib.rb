def nginx_home
  "#{node.nginx.install_root}/nginx-#{node.nginx.version}"
end

def nginx_user
  node.www_user
end

def nginx_unix_proxy(attributes)
  directory "#{nginx_home}/conf/sites-enabled" do
    owner nginx_user
    mode "0755"
  end

  template "#{nginx_home}/conf/sites-enabled/#{attributes[:name]}" do
    source "unix_socket_proxy.erb"
    cookbook "nginx"
    variables(attributes)
    mode "0644"
    owner nginx_user
  end
end