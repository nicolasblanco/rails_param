require 'spec_helper'

describe RailsParam::Param::Validator::Format do
  let(:format_validation) { /[0-9]+\$/ }
  let(:name)              { "foo" }
  let(:options)           { { format: format_validation } }
  let(:type)              { String }
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
      let(:value) { "50$" }

      it "does not raise error" do
        expect { subject.validate! }.to_not raise_error
      end
    end

    context "value given is invalid" do
      let(:value) { "50" }

      it "raises" do
        expect { subject.validate! }.to raise_error(RailsParam::Param::InvalidParameterError, "Parameter foo must match format #{format_validation}")
      end
    end
  end
end
