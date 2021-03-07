require 'spec_helper'

describe RailsParam::Param::Validator::Required do
  let(:name)    { "foo" }
  let(:options) { { blank: false } }
  let(:type)    { String }
  let(:parameter) do
    RailsParam::Param::Parameter.new(
      name: name,
      value: value,
      options: options,
      type: type
    )
  end

  subject { described_class.new(parameter) }

  shared_examples "has a present value" do
    it "succeeds" do
      expect { subject.validate! }.to_not raise_error
    end
  end

  shared_examples "does not have present value" do
    it "raises" do
      expect { subject.validate! }.to raise_error(RailsParam::Param::InvalidParameterError)
    end
  end

  describe "#validate!" do
    context "String" do
      context "is not empty" do
        let(:value) { "bar" }

        it_behaves_like "has a present value"
      end

      context "is empty" do
        let(:value) { "" }

        it_behaves_like "does not have present value"
      end
    end

    context "Hash" do
      context "is not empty" do
        let(:value) { { foo: :bar } }

        it_behaves_like "has a present value"
      end

      context "is empty" do
        let(:value) { {} }

        it_behaves_like "does not have present value"
      end
    end

    context "Array" do
      context "is not empty" do
        let(:value) { [50] }

        it_behaves_like "has a present value"
      end

      context "is empty" do
        let(:value) { [] }

        it_behaves_like "does not have present value"
      end
    end

    context "ActiveController::Parameters" do
      context "is not empty" do
        let(:value) do
          ActionController::Parameters.new({ "price" => "50" })
        end

        it_behaves_like "has a present value"
      end

      context "is empty" do
        let(:value) { ActionController::Parameters.new() }

        it_behaves_like "does not have present value"
      end
    end
  end
end
