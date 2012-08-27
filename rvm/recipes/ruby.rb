include_recipe "rvm"

#  install_rvm(rvm_user, rvm_user_home, rvm_version)
if rvm_node_and_rubies_present?
  node.rvm.rubies.each do |ruby|
    install_rvm_ruby(node_rvm_user_or_node_user, ruby)
  end
end
