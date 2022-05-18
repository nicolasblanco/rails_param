require 'spec_helper'

describe RailsParam::Validator::In do
  let(:value)   { 50 }
  let(:name)    { "foo" }
  let(:options) { { in: in_validation } }
  let(:type)    { Integer }
  let(:locale)  { :en }
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
      let(:in_validation) { 1..100 }

      it_behaves_like "does not raise error"
    end

    context "value given is invalid" do
      let(:in_validation) { 51..100 }
      let(:error_message) { "Parameter foo must be within 51..100" }

      it_behaves_like "raises InvalidParameterError"
    end

    context "is locale ar" do
      let(:locale)         { :ar }
      let(:error_message)  { "المتغير foo يجب ان يكون من ضمن 51..100" }
      let(:in_validation)          { 51..100 }

      it_behaves_like "raises InvalidParameterError"
    end
  end
end
