require 'spec_helper'

describe RailsParam::Validator::Custom do
  let(:custom_validation) { lambda { |v| raise RailsParam::InvalidParameterError, 'Number is not even' if v % 2 != 0 } }
  let(:name)              { "foo" }
  let(:options)           { { custom: custom_validation } }
  let(:type)              { String }
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
      let(:value) { 50 }

      it_behaves_like "does not raise error"
    end

    context "value given is invalid" do
      let(:value)         { 51 }
      let(:error_message) { "Number is not even" }

      it_behaves_like "raises InvalidParameterError"
    end
  end
end
