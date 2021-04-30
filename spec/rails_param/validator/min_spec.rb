require 'spec_helper'

describe RailsParam::Validator::Min do
  let(:name)    { "foo" }
  let(:value)   { 50 }
  let(:options) { { min: min } }
  let(:type)    { Integer }
  let(:parameter) do
    RailsParam::Parameter.new(
      name: name,
      value: value,
      options: options,
      type: type
    )
  end

  subject { described_class.new(parameter) }

  describe "#validate!" do
    context "value given is valid" do
      let(:min) { 50 }

      it_behaves_like "does not raise error"
    end

    context "value given is invalid" do
      let(:min)           { 51 }
      let(:error_message) { "Parameter foo cannot be less than #{min}" }

      it_behaves_like "raises InvalidParameterError"
    end
  end
end
