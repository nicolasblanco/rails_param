require 'spec_helper'

describe RailsParam::Validator::Format do
  let(:format_validation) { /[0-9]+\$/ }
  let(:name)              { "foo" }
  let(:options)           { { format: format_validation } }
  let(:type)              { String }
  let(:locale)            { :en }
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
      let(:value) { "50$" }

      it_behaves_like "does not raise error"
    end

    context "value given is invalid" do
      let(:value)         { "50" }
      let(:error_message) { "Parameter foo must match format #{format_validation}" }

      it_behaves_like "raises InvalidParameterError"
    end

    context "is locale ar" do
      let(:locale)         { :ar }
      let(:error_message)  { "المتغير foo يجب ان يطابق التنسيق #{format_validation}" }
      let(:value)          { "50" }

      it_behaves_like "raises InvalidParameterError"
    end
  end
end
