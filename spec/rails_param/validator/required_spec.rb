require 'spec_helper'

describe RailsParam::Param::Validator::Required do
  let(:name)    { "foo" }
  let(:options) { { required: true } }
  let(:type)    { String }
  let(:parameter) do
    RailsParam::Param::Parameter.new(
      name: name,
      value: value,
      options: options,
      type: type
    )
  end

  subject { described_class.new(parameter) }

  describe "#validate!" do
    context "value given is present" do
      let(:value) { "bar" }

      it_behaves_like "does not raise error"
    end

    context "value is not present" do
      let(:error_message) { "Parameter foo is required" }
      let(:value)         { nil }

      it_behaves_like "raises InvalidParameterError"

      context "with a custom message" do
        let(:error_message) { "No price specified." }
        let(:options)       { { required: true, message: error_message } }

        it_behaves_like "raises InvalidParameterError"
      end
    end
  end
end
