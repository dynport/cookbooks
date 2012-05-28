def src_dir
  "#{node.source.install_dir}/src"
end

def download_file(url)
  path = "#{src_dir}/#{File.basename(url)}"
  remote_file path do
    source url
    mode "644"
    not_if "test -e #{path}"
  end
end