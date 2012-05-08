include_recipe "rvm"

if node[:rvm] && node[:rvm][:rubies]
  node.rvm.rubies.each do |ruby|
    install_rvm_ruby(ruby)
  end
end