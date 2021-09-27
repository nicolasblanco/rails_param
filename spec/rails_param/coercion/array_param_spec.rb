require 'spec_helper'

describe RailsParam::Coercion::ArrayParam do
  let(:options) { { fizz: :buzz } }

  subject { described_class }

  shared_examples "does not raise an error" do
    it "does not raise an error" do
      expect { subject.new(param: param, type: type, options: options) }.to_not raise_error
    end
  end

  shared_examples "raises ArgumentError" do
    it "raises ArgumentError" do
      expect { subject.new(param: param, type: type, options: options) }.to raise_error ArgumentError
    end
  end

  shared_examples "returns an array" do
    it "returns the param as an array" do
      expect(subject.coerce).to eq ["foo", "bar"]
    end
  end

  describe ".new" do
    context "type is Array" do
      let(:type) { Array }

      context "param responds to #split" do
        let(:param) { "foo,bar" }

        it_behaves_like "does not raise an error"
      end

      context "param does not respond to split" do
        let(:param) { 1 }

        it_behaves_like "raises ArgumentError"
      end
    end

    context "type is not Array" do
      let(:param) { "foo" }
      let(:type)  { String }

      it_behaves_like "raises ArgumentError"
    end
  end

  describe "#coerce" do
    let(:type)    { Array }
    let(:options) { {} }
    subject { described_class.new(param: param, type: type, options: options) }

    context "param is an array" do
      let(:param) { ["foo", "bar"] }

      it_behaves_like "returns an array"
    end

    context "param is delimited by ','" do
      let(:param) { "foo,bar" }

      it_behaves_like "returns an array"
    end

    context "options delimiter provided" do
      let(:options) { {delimiter: "::"} }
      let(:param)   { "foo::bar" }

      it_behaves_like "returns an array"
    end

    context "param is nil" do
      let(:param) { nil }

      it "returns an empty array" do
        expect(subject.coerce).to eq([])
      end
    end
  end
end
