RSpec.shared_examples "does not raise error" do
  it "does not raise error" do
    expect { subject.validate! }.to_not raise_error
  end
end
