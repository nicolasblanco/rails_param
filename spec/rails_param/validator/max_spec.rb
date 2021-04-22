require 'spec_helper'

describe RailsParam::Validator::Max do
  let(:name)    { "foo" }
  let(:value)   { 50 }
  let(:options) { { max: max } }
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
      let(:max) { 50 }

      it_behaves_like "does not raise error"
    end

    context "value given is invalid" do
      let(:max)           { 49 }
      let(:error_message) { "Parameter foo cannot be greater than #{max}" }

      it_behaves_like "raises InvalidParameterError"
    end
  end
end
