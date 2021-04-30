RSpec.shared_examples "raises InvalidParameterError" do
  it "raises error with message" do
    expect { subject.validate! }.to raise_error(RailsParam::InvalidParameterError, error_message)
  end
end
