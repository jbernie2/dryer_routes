require_relative "../../../lib/dryer_routes.rb"

RSpec.describe Dryer::Routes do
  it "returns the current gem version" do
    expect(Dryer::Routes.version).to be_truthy
  end
end
