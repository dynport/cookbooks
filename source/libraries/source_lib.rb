def src_dir
  "#{node.source.install_dir}/src"
end

def download_file(url)
  remote_file "#{src_dir}/#{File.basename(url)}" do
    source url
    mode "644"
  end
end