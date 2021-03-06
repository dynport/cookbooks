include_recipe "source"
package "python"
package "libssl-dev"

NODE_VERSION = node[:node][:version]
NODE_PREFIX = "node-v#{NODE_VERSION}"
NODE_FILE = "#{NODE_PREFIX}.tar.gz"

download_file "http://nodejs.org/dist/v#{NODE_VERSION}/#{NODE_FILE}"

execute "install node" do
  command "tar xvfz #{NODE_FILE} && cd #{NODE_PREFIX} && ./configure --prefix=/opt/#{NODE_PREFIX} && make && make install"
  cwd src_dir
  creates "/opt/#{NODE_PREFIX}/bin/node"
end

link "/opt/node" do
  to "/opt/#{NODE_PREFIX}"
end
