require "pathname"

if rvm_node_and_rubies_present?
  install_rvm(node_rvm_user_or_node_user, "/home/#{node_rvm_user_or_node_user}", node.rvm.version)
end
