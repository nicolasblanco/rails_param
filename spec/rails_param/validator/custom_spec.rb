require 'spec_helper'
require 'rails_param/validator'

describe RailsParam::Param::Validator::Custom do
  let(:custom_validation) { lambda { |v| raise RailsParam::Param::InvalidParameterError, 'Number is not even' if v % 2 != 0 } }
  let(:name)              { "foo" }
  let(:options)           { { custom: custom_validation } }
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
      let(:value) { 50 }

      it "does not raise error" do
        expect { subject.validate! }.to_not raise_error
      end
    end

    context "value given is invalid" do
      let(:value) { 51 }

      it "raises" do
        expect { subject.validate! }.to raise_error(RailsParam::Param::InvalidParameterError, 'Number is not even')
      end
    end
  end
end
