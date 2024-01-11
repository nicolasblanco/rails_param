module RailsParam
  attr_accessor :rails_params

  def param!(name, type, options = {}, &block)
    hierarchy = ParamEvaluator.new(params).param!(name, type, options, &block)

    @rails_params =
      if params.is_a?(ActionController::Parameters)
        params.permit(hierarchy)
      else
        params
      end
  end
end
