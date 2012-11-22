class Icinga
  attr_reader :node, :context

  def initialize(context)
    @context = context
  end

  def node
    context.node
  end

  def version
    node.icinga.version
  end

  def name
    "icinga-#{version}"
  end

  def file_name
    "#{name}.tar.gz"
  end

  def dir
    "/opt/#{name}"
  end

  def symlink
    "/opt/icinga"
  end

  def etc_dir
    "#{dir}/etc"
  end

  def conf_d_dir
    "#{etc_dir}/conf.d"
  end

  def var_dir
    "/data/icinga"
  end

  def username
    "icinga"
  end

  def password
    node.icinga.password
  end

  def create_all_dirs!
    return if @dirs_created
    [dir, etc_dir, conf_d_dir].each do |dir_path|
      context.directory dir_path do
        mode "0755"
        owner "icinga"
        recursive true
      end
    end
    @dirs_created = true
  end

  def write_config(file_name, custom_source = nil, custom_variables = {})
    create_all_dirs!

    context.template "#{conf_d_dir}/#{file_name}.cfg" do
      mode "0644"
      owner "icinga"
      variables custom_variables
      source custom_source
      notifies :restart, "service[icinga]"
    end
  end
end

