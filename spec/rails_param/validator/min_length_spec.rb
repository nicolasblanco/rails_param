require 'spec_helper'

describe RailsParam::Validator::MinLength do
  let(:name)    { "foo" }
  let(:value)   { "bar" }
  let(:options) { { min_length: min_length } }
  let(:type)    { String }
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
      let(:min_length) { 3 }

      it_behaves_like "does not raise error"
    end

    context "value given is invalid" do
      let(:min_length)    { 44 }
      let(:error_message) { "Parameter foo cannot have length less than #{min_length}" }

      it_behaves_like "raises InvalidParameterError"
    end
  end
end
