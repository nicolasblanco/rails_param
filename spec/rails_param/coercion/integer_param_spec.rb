require 'spec_helper'

describe RailsParam::Param::Coercion::IntegerParam do
  shared_examples "does not raise an error" do
    it "does not raise an error" do
      expect { subject.coerce }.to_not raise_error
    end
  end

  shared_examples "raises ArgumentError" do
    it "raises ArgumentError" do
      expect { subject.coerce }.to raise_error ArgumentError
    end
  end

  shared_examples "returns an Integer" do
    it "returns the param as an Integer" do
      expect(subject.coerce).to eq 19
    end
  end

  describe "#coerce" do
    let(:type)    { Integer }
    let(:options) { {} }
    subject { described_class.new(param: param, type: type, options: options) }

    context "param is a valid value" do
      let(:param) { "19" }

      it_behaves_like "does not raise an error"
      it_behaves_like "returns an Integer"
    end

    context "param is invalid value" do
      let(:param) { "notInteger" }

      it_behaves_like "raises ArgumentError"
    end
  end
end
