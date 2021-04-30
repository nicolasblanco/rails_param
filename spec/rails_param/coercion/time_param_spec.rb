require 'spec_helper'

describe RailsParam::Coercion::TimeParam do
  describe ".new" do
    let(:param)   { "foo" }
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

    context "type is Date" do
      let(:type) { Date }

      it_behaves_like "does not raise an error"
    end

    context "type is Time" do
      let(:type) { Time }

      it_behaves_like "does not raise an error"
    end

    context "type is DateTime" do
      let(:type) { DateTime }

      it_behaves_like "does not raise an error"
    end

    context "type does not respond to parse" do
      let(:type) { Array }

      it_behaves_like "raises ArgumentError"
    end
  end

  describe "#coerce" do
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

    let(:options) { {} }
    subject { described_class.new(param: param, type: type, options: options) }

    context "type is Date" do
      let(:type) { Date }

      shared_examples "returns a date" do
        it "returns a Date" do
          expect(subject.coerce).to eq(Date.new(2015, 10, 21))
        end
      end

      context "param is a valid value" do
        let(:param) { "2015-10-21" }

        it_behaves_like "does not raise an error"
        it_behaves_like "returns a date"
      end

      context "param is an invalid value" do
        let(:param) { "notDate" }

        it_behaves_like "raises ArgumentError"
      end

      context "with format" do
        let(:options) { { format: "%F" } }

        context "param is a valid value" do
          let(:param) { "2015-10-21T11:11:00.000+06:00" }

          it_behaves_like "does not raise an error"
          it_behaves_like "returns a date"
        end

        context "param is an invalid value" do
          let(:param) { "notDate" }

          it_behaves_like "raises ArgumentError"
        end

        context "format is an invalid value" do
          let(:param)   { "2015-10-21T11:11:00.000+06:00" }
          let(:options) { { format: "%x" } }

          it_behaves_like "raises ArgumentError"
        end
      end
    end

    context "type is DateTime" do
      let(:type) { DateTime }

      context "param is valid value" do
        let(:param) { "2015-10-21T11:11:00.000+06:00" }

        it_behaves_like "does not raise an error"
        it "returns a DateTime" do
          expect(subject.coerce).to eq(DateTime.new(2015, 10, 21, 11, 11, 0, '+6'))
        end
      end

      context "param is an invalid value" do
        let(:param) { "notDateTime" }

        it_behaves_like "raises ArgumentError"
      end

      context "with format" do
        let(:options) { { format: "%F" } }

        context "param is a valid value" do
          let(:param) { "2015-10-21T11:11:00.000+06:00" }

          it_behaves_like "does not raise an error"
          it "returns a Time" do
            expect(subject.coerce).to eq(DateTime.new(2015, 10, 21))
          end
        end

        context "param is an invalid value" do
          let(:param) { "notDateTime" }

          it_behaves_like "raises ArgumentError"
        end

        context "format is an invalid value" do
          let(:param)   { "2015-10-21T11:11:00.000+06:00" }
          let(:options) { { format: "%x" } }

          it_behaves_like "raises ArgumentError"
        end
      end
    end

    context "type is Time" do
      let(:type) { Time }

      context "param is valid value" do
        let(:param) { "2015-10-21T11:11:00.000+06:00" }

        it_behaves_like "does not raise an error"
        it "returns a Time" do
          expect(subject.coerce).to eq(Time.new(2015, 10, 21, 11, 11, 0, 21600))
        end
      end

      context "param is an invalid value" do
        let(:param) { "notTime" }

        it_behaves_like "raises ArgumentError"
      end

      context "with format" do
        let(:options) { { format: "%F" } }

        context "param is a valid value" do
          let(:param) { "2015-10-21T11:11:00.000+06:00" }

          it_behaves_like "does not raise an error"
          it "returns a Time" do
            expect(subject.coerce).to eq(Time.new(2015, 10, 21))
          end
        end

        context "param is an invalid value" do
          let(:param) { "notTime" }

          it_behaves_like "raises ArgumentError"
        end

        context "format is an invalid value" do
          let(:param)   { "2015-10-21T11:11:00.000+06:00" }
          let(:options) { { format: "%x" } }

          it_behaves_like "raises ArgumentError"
        end
      end
    end
  end
end
