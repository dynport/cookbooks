include_recipe "nginx"

file "/opt/nginx/conf/sites-enabled/empty.conf" do
  content <<-CONFIG
  server {
    listen 80 default_server;
    server_name _;
    return 444;
  }
  CONFIG
end
