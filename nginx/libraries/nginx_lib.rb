require File.expand_path("../../../base/libraries/template_renderer", __FILE__)

SERVER_TEMPLATE =<<ERB
server {
  <% if listen %>
  listen <%= listen %>;
  <% end %>

  <% if htaccess_file %>
  auth_basic "Restricted files";
  auth_basic_user_file "<%= htaccess_file %>";
  <% end %>

  client_max_body_size 4G;
  server_name <%= server_name %> ;

  keepalive_timeout 5;

  root <%= root %>;

  <%= locations.join("\n").gsub(/^/, "  ")[2..-1] %>
}
ERB

PROXY_LOCATION_TEMPLATE =<<ERB
location <%= location %> {
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header Host $http_host;
  proxy_redirect off;

  # If you don't find the filename in the static files
  # Then request it from the unicorn server
  if (!-f $request_filename) {
    proxy_pass http://<%= upstream_server %>;
    break;
  }
}
ERB

UPSTREAM_SERVER =<<ERB
upstream <%= name %> {
  server <%= server %>;
}
ERB

class NginxConfigRenderer < TemplateRenderer
  class << self
    def upstream_server(name, server)
      render_template_with_attributes(UPSTREAM_SERVER, :name => name, :server => server)
    end

    def proxied_location(location, upstream_server)
      render_template_with_attributes(PROXY_LOCATION_TEMPLATE, :location => location, :upstream_server => upstream_server)
    end

    def server(listen, server_name, root, locations, htaccess_file = nil)
      render_template_with_attributes(SERVER_TEMPLATE, :server_name => server_name, :listen => listen, :locations => locations, :root => root, 
        :htaccess_file => htaccess_file
      ) 
    end
  end
end

def nginx_home
  "#{node.nginx.install_root}/nginx-#{node.nginx.version}"
end

def nginx_user
  node.www_user
end

def create_nginx_upstream_proxy(name, nginx_content)
  directory "/opt/nginx/conf/sites-enabled" do
    recursive true
  end

  file "/opt/nginx/conf/sites-enabled/#{name}" do
    mode "0644"
    content nginx_content
  end
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
