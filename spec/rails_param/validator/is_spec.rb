require 'spec_helper'

describe RailsParam::Validator::Is do
  let(:name)    { "foo" }
  let(:options) { { is: "50" } }
  let(:type)    { String }
  let(:locale)         { :en }
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
      let(:value) { "50" }

      it_behaves_like "does not raise error"
    end

    context "value given is invalid" do
      let(:value)         { "51" }
      let(:error_message) { "Parameter foo must be 50" }

      it_behaves_like "raises InvalidParameterError"
    end

    context "is locale ar" do
      let(:locale)         { :ar }
      let(:error_message)  { "المتغير foo يجب ان يكون 50" }
      let(:value)          { "51" }

      it_behaves_like "raises InvalidParameterError"
    end
  end
end
