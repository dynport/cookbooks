template "#{node.source.install_dir}/bundle_wrapper" do
  source "bundle_wrapper"
  mode "0755"
  cookbook "unicorn"
end