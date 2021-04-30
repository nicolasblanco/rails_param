require 'spec_helper'

describe RailsParam::Coercion::FloatParam do
  describe "#coerce" do
    let(:type)    { Float }
    let(:options) { {} }
    subject { described_class.new(param: param, type: type, options: options) }

    context "value is valid" do
      let(:param) { "12.34" }

      it "returns a Float" do
        expect(subject.coerce).to eq 12.34
      end
    end

    context "value is invalid" do
      let(:param) { "foo" }

      it "raises ArgumentError" do
        expect { subject.coerce }.to raise_error ArgumentError
      end
    end
  end
end
