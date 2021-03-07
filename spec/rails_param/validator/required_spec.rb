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

      it "does not raise error" do
        expect { subject.validate! }.to_not raise_error
      end
    end

    context "value is not present" do
      let(:message) { "Parameter foo is required" }
      let(:value)   { nil }

      it "raises InvalidParameterError" do
        expect { subject.validate! }.to raise_error(RailsParam::Param::InvalidParameterError, message)
      end

      context "with a custom message" do
        let(:message) { "No price specified." }
        let(:options) { { required: true, message: message } }

        it "raises custom error" do
          expect { subject.validate! }.to raise_error(RailsParam::Param::InvalidParameterError, message)
        end
      end
    end
  end
end
