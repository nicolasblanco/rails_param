require 'spec_helper'

describe RailsParam::Param::Coercion::HashParam do
  let(:options) { {} }

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

  shared_examples "returns a hash" do
    it "returns the param as a hash" do
      expect(subject.coerce).to eq({ "foo" => "bar", "fizz" => "buzz" })
    end
  end

  describe ".new" do
    let(:param) { "foo,bar" }

    context "type is Hash" do
      let(:type) { Hash }

      context "param responds to #split" do

        it_behaves_like "does not raise an error"
      end

      context "param does not respond to split" do
        let(:param) { 1 }

        it_behaves_like "raises ArgumentError"
      end
    end

    context "type is not Hash" do
      let(:type)  { String }

      it_behaves_like "raises ArgumentError"
    end
  end

  describe "#coerce" do
    let(:type)    { Hash }
    let(:options) { {} }
    subject { described_class.new(param: param, type: type, options: options) }

    context "param is delimited by ','" do
      let(:param) { "foo:bar,fizz:buzz" }

      it_behaves_like "returns a hash"
    end

    context "options delimiter provided" do
      let(:options) { {delimiter: "::"} }
      let(:param)   { "foo:bar::fizz:buzz" }

      it_behaves_like "returns a hash"
    end

    context "options delimiter provided" do
      let(:options) { {separator: "!"} }
      let(:param)   { "foo!bar,fizz!buzz" }

      it_behaves_like "returns a hash"
    end
  end
end
