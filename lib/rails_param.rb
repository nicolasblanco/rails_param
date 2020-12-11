require 'rails_param/param'
Dir[File.join(__dir__, 'rails_param', '*.rb')].each { |file| require file }
Dir[File.join(__dir__, 'rails_param/coercions', '*.rb')].each { |file| require file }

ActiveSupport.on_load(:action_controller) do
  include RailsParam::Param
end
