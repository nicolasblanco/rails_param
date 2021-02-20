require 'spec_helper'
require 'rails_param/coercion'

describe RailsParam::Param::Coercion do
  describe ".new" do
    let(:param) { "foo" }
    let(:type) { String }
    let(:options) { { fizz: :buzz } }

    subject { described_class }

    let(:coercion_class) { RailsParam::Param::Coercion::StringParam }

    before { allow(coercion_class).to receive(:new) }

    it "initializes a coercion class based on the provided type" do
      subject.new(param, type, options)

      expect(coercion_class).to have_received(:new).with(
        param: param,
        type: type,
        options: options
      )
    end

    context "when there is no mapping for the provided type" do
      let(:type) { :foobar }

      it "raises a type error" do
        expect { subject.new(param, type, options) }.to raise_error(TypeError)
      end
    end
  end

  describe "#coerce" do
    let(:param) { rand(0...1000) }
    let(:type) { Integer }
    let(:options) { {} }

    subject { described_class.new(param, type, options) }

    let(:coercion_class) { RailsParam::Param::Coercion::IntegerParam }
    let(:coerced_param) { rand(-1000...-1) }

    before { allow_any_instance_of(coercion_class).to receive(:coerce).and_return(coerced_param) }

    it "delegates to the coercion instance" do
      expect(subject.coerce).to eq(coerced_param)
    end
  end
end
