require 'spec_helper'

describe RailsParam::Param::Coercion::BooleanParam do
  describe "#coerce" do
    let(:type)    { TrueClass }
    let(:options) { {} }
    subject       { described_class.new(param: param, type: type, options: options) }

    shared_examples "coerces to true" do
      it "returns true" do
        expect(subject.coerce).to eq true
      end
    end

    shared_examples "coerces to false" do
      it "returns false" do
        expect(subject.coerce).to eq false
      end
    end

    context "given 'true'" do
      let(:param) { "true" }

      it_behaves_like "coerces to true"
    end

    context "given 'false'" do
      let(:param) { "false" }

      it_behaves_like "coerces to false"
    end

    context "given 't'" do
      let(:param) { "t" }

      it_behaves_like "coerces to true"
    end

    context "given 'f'" do
      let(:param) { "f" }

      it_behaves_like "coerces to false"
    end

    context "given 'yes'" do
      let(:param) { "yes" }

      it_behaves_like "coerces to true"
    end

    context "given 'no'" do
      let(:param) { "no" }

      it_behaves_like "coerces to false"
    end

    context "given 'y'" do
      let(:param) { "y" }

      it_behaves_like "coerces to true"
    end

    context "given 'n'" do
      let(:param) { "n" }

      it_behaves_like "coerces to false"
    end

    context "given '1'" do
      let(:param) { "1" }

      it_behaves_like "coerces to true"
    end

    context "given '0'" do
      let(:param) { "0" }

      it_behaves_like "coerces to false"
    end

    context "param not TRUTHY or FALSEY" do
      let(:param) { "foo" }

      it "raises ArgumentError" do
        expect { subject.coerce }.to raise_error ArgumentError
      end
    end
  end
end
