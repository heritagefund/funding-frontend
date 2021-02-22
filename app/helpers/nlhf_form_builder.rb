class NlhfFormBuilder < ActionView::Helpers::FormBuilder

  def save_and_continue(value = 'Save and continue', options = {})
      options.with_defaults!({class:"govuk-button", role: "button", 'data-module' => 'govuk-button'})
      self.submit(value, options)
  end
  
  # Helper method to return 'name' attribute
  # e.g. f.name_for :description
  def name_for(method, options = {})
    InstanceTag.new(object_name, method, self, options) \
               .name_for(options)
  end

  # Helper method to return 'id' attribute
  # e.g. f.id_for :description
  def id_for(method, options = {})
    InstanceTag.new(object_name, method, self, options) \
               .id_for(options)
  end
end

class InstanceTag < ActionView::Helpers::Tags::Base
  def id_for(options)
    add_default_name_and_id(options)
    options['id']
  end

  def name_for(options)
    add_default_name_and_id(options)
    options['name']
  end
end