include_recipe "source"

libevent_name = "libevent-#{node.libevent.version}"
libevent_file = "#{libevent_name}-stable.tar.gz"
libevent_path = "/opt/#{libevent_name}"

download_file "https://github.com/downloads/libevent/libevent/#{libevent_file}"

execute "build libevent" do
  cwd "/opt/src"
  command "tar xvfz #{libevent_file} && cd libevent-#{node.libevent.version}-stable && ./configure --prefix=#{libevent_path} && make && make install"
end

tmux_name = "tmux-#{node.tmux.version}"
tmux_file = "#{tmux_name}.tar.gz"

package "libncurses5-dev"

download_file "http://downloads.sourceforge.net/tmux/#{tmux_file}"

execute "install tmux" do
  cwd "/opt/src"
  command <<-CMD
    tar xvfz #{tmux_file} && cd #{tmux_name} && ./configure --prefix=/opt/#{tmux_name} --enable-static && make && make install
  CMD
  env(
    "CFLAGS" => "-I#{libevent_path}/include",
    "LDFLAGS" => "-L#{libevent_path}/lib"
  )
end

link "/opt/tmux" do
  to "/opt/#{tmux_name}"
end
