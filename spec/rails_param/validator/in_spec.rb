require 'spec_helper'

describe RailsParam::Param::Validator::In do
  let(:value)   { 50 }
  let(:name)    { "foo" }
  let(:options) { { in: in_validation } }
  let(:type)    { Integer }
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
    context "value given is valid" do
      let(:in_validation) { 1..100 }

      it "does not raise error" do
        expect { subject.validate! }.to_not raise_error
      end
    end

    context "value given is invalid" do
      let(:in_validation) { 51..100 }
      let(:error_message) { "Parameter foo must be within 51..100" }

      it "raises" do
        expect { subject.validate! }.to raise_error(RailsParam::Param::InvalidParameterError, error_message)
      end
    end
  end
end
