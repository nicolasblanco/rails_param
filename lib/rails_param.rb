require 'rails_param/param'

ActiveSupport.on_load(:action_controller) do
  include RailsParam::Param
end
