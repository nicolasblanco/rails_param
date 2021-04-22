require 'spec_helper'

describe RailsParam::Coercion::BigDecimalParam do
  describe "#coerce" do
    let(:param)   { 1.234567890123456 }
    let(:type)    { BigDecimal }
    let(:options) { {} }
    subject       { described_class.new(param: param, type: type, options: options) }

    shared_examples "returns BigDecimal with default precision" do
      it "returns a BigDecimal with the default precision" do
        expect(subject.coerce).to eq 1.2345678901235
      end
    end

    it_behaves_like "returns BigDecimal with default precision"

    context "given a precision option" do
      let(:options) { {precision: 10} }

      it "returns BigDecimal using precision option" do
        expect(subject.coerce).to eq 1.234567890
      end
    end

    context "param is a String" do
      let(:param) { "1.234567890123456"}

      it_behaves_like "returns BigDecimal with default precision"

      context "param is currency String" do
        let(:param) { "$1.50" }

        it "returns the param as BigDecimal" do
          expect(subject.coerce).to eq 1.50
        end
      end
    end
  end
end
