require 'spec_helper'

describe RailsParam::Parameter do
  let(:name)    { "foo" }
  let(:value)   { "bar" }
  let(:options) { { fizz: :buzz } }
  let(:type)    { String }

  subject { described_class.new(name: name, value: value, options: options, type: type) }

  describe "#should_set_default?" do
    context "when value is nil" do
      let(:value) { nil }

      context "and default options present" do
        let(:options) { { default: "foobar" } }

        it "returns true" do
          expect(subject.should_set_default?).to eq true
        end
      end

      context "and default options are not present" do
        it "returns false" do
          expect(subject.should_set_default?).to eq false
        end
      end
    end

    context "when value is present" do
      it "returns false" do
        expect(subject.should_set_default?).to eq false
      end
    end
  end

  describe "#set_default" do
    context "default options respond to .call" do
      let(:default_option) do
        double.tap do |dbl|
          allow(dbl).to receive(:call).and_return("foobar")
        end
      end
      let(:options) { { default: default_option } }

      it "sets the value" do
        subject.set_default
        expect(subject.value).to eq "foobar"
      end
    end

    context "default options does not respond to .call" do
      let(:options) { {default: "fizzbuzz" } }

      it "sets the value" do
        subject.set_default
        expect(subject.value).to eq "fizzbuzz"
      end
    end
  end

  describe "#transform" do
    context "with a method" do
      let(:options) { { transform: :upcase } }

      it "transforms the value" do
        subject.transform
        expect(subject.value).to eq "BAR"
      end
    end

    context "with a block" do
      let(:value)   { "BAR" }
      let(:options) { { transform: lambda { |n| n.downcase } } }

      it "transforms the value" do
        subject.transform
        expect(subject.value).to eq "bar"
      end

      context "conditional block" do
        let(:value)   { false }
        let(:options) { { transform: lambda { |n| n ? "foo" : "no foo" } } }

        it "transforms the value" do
          subject.transform
          expect(subject.value).to eq "no foo"
        end
      end
    end
  end

  describe "#validate" do
    let(:validator) { double }
    before :each do
      allow(RailsParam::Validator).to receive(:new).and_return(validator)
      allow(validator).to receive(:validate!)
    end

    it "passes self to Validator" do
      subject.validate
      expect(RailsParam::Validator).to have_received(:new).with(subject)
    end

    it "calls #validate!" do
      subject.validate
      expect(validator).to have_received(:validate!)
    end
  end
end
