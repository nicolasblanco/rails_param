require 'spec_helper'

describe RailsParam::Param::Coercion::StringParam do
  shared_examples "does not raise an error" do
    it "does not raise an error" do
      expect { subject.coerce }.to_not raise_error
    end
  end

  shared_examples "returns an String" do
    it "returns the param as an String" do
      expect(subject.coerce).to eq "bar"
    end
  end

  describe "#coerce" do
    let(:type)    { String }
    let(:options) { {} }
    subject { described_class.new(param: param, type: type, options: options) }

    context "param is a valid value" do
      let(:param) { :bar }

      it_behaves_like "does not raise an error"
      it_behaves_like "returns an String"
    end
  end
end
