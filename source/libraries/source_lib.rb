def src_dir
  "#{node.source.install_dir}/src"
end

def download_file(url)
  file_name = File.basename(url)
  path = "#{src_dir}/#{file_name}"

  if node[:s3_proxy]
    execute "#{url} from s3" do
      cwd src_dir
      command "wget '#{node.s3_proxy}/#{file_name}' && chmod 0644 #{path}; echo 'ok'"
      not_if "test -e #{path}"
    end
  end

  remote_file path do
    source url
    mode "0644"
    not_if "test -e #{path}"
  end
end
