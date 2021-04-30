module RailsParam
  def param!(name, type, options = {}, &block)
    ParamEvaluator.new(params).param!(name, type, options, &block)
  end
end
