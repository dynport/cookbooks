class TemplateRenderer
  class << self
    def render_template_with_attributes(template, attributes)
      ERB.new(template).result(new(attributes).get_binding)
    end
  end

  def initialize(attributes)
    attributes.each do |key, value|
      eigenclass.send(:define_method, key) { value }
    end
  end

  def eigenclass
    class << self
      self
    end
  end

  def get_binding
    binding
  end
end