require 'rails_param/param'
require 'rails_param/coercion'
Dir[File.join(__dir__, 'rails_param/coercions', '*.rb')].each { |file| require file }

ActiveSupport.on_load(:action_controller) do
  include RailsParam::Param
end
