require 'spec_helper'

describe RailsParam::Coercion::FloatParam do
  describe "#coerce" do
    let(:type)    { Float }
    let(:options) { {} }
    subject { described_class.new(param: param, type: type, options: options) }

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

    shared_examples "returns a Float" do
      it "returns the param as a Float" do
        expect(subject.coerce).to eq 12.34
      end
    end

    shared_examples "returns nil" do
      it "returns the param as a nil value" do
        expect(subject.coerce).to be nil
      end
    end

    context "value is valid" do
      let(:param) { "12.34" }

      it_behaves_like "does not raise an error"
      it_behaves_like "returns a Float"
    end

    context "param is blank (e.g. empty field in an HTML form)" do
      let(:param) { "" }

      it_behaves_like "does not raise an error"
      it_behaves_like "returns nil"
    end

    context "value is invalid" do
      let(:param) { "foo" }

      it_behaves_like "raises ArgumentError"
    end
  end
end
