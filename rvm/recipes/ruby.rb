include_recipe "rvm"

if node[:rvm] && node[:rvm][:rubies]
  rvm_node.rubies.each do |ruby|
    install_rvm_ruby(rvm_user, ruby)
  end
end
