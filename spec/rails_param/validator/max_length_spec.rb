require 'spec_helper'

describe RailsParam::Validator::MaxLength do
  let(:name)    { "foo" }
  let(:value)   { "bar" }
  let(:options) { { max_length: max_length } }
  let(:type)    { String }
  let(:locale)    { :en }
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
    before { I18n.locale = locale }

    context "value given is valid" do
      let(:max_length) { 3 }

      it_behaves_like "does not raise error"
    end

    context "value given is invalid" do
      let(:max_length)    { 2 }
      let(:error_message) { "Parameter foo cannot have length greater than #{max_length}" }

      it_behaves_like "raises InvalidParameterError"
    end
  end
end
