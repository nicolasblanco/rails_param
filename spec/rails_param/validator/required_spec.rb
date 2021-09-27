require 'spec_helper'

describe RailsParam::Validator::Required do
  let(:name)    { "foo" }
  let(:options) { { required: true } }
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
    context "value given is present" do
      let(:value) { "bar" }

      it_behaves_like "does not raise error"
    end

    context "value given is not nil but is also not present" do
      let(:type) { Hash }
      let(:value) { {} }

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

    context "parameter is not required" do
      let(:options) { { required: false } }

      context "value is not present" do
        let(:value) { nil }

        it_behaves_like "does not raise error"
      end
    end
  end
end
