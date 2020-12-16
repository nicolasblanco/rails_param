require 'rails_param/param'
Dir[File.join(__dir__, 'rails_param', '*.rb')].sort.each { |file| require file }
Dir[File.join(__dir__, 'rails_param/coercions', '*.rb')].sort.each { |file| require file }

ActiveSupport.on_load(:action_controller) do
  include RailsParam::Param
end
