require_relative "../../../lib/dryer_routes.rb"

RSpec.describe Dryer::Routes::Route do
  subject { described_class.new(route_config) }

  let(:route_config) do
    {
      method: 'foo',
      url: url,
      controller: nil,
      controller_action: 'bar',
      request_contract: nil,
      response_contracts: []
    }
  end

  describe "#url" do
    context "when the url field from the config is a lambda" do
      let(:url) { Dryer::Routes::UrlBuilder.call("/foo/:id/bar/:id") }
      it "forwards arguments to it" do
        expect(subject.url(1,2)).to eq("/foo/1/bar/2")
      end
    end

    context "when the url field from the config a string" do
      let(:url) { "/foo" }
      it "returns it" do
        expect(subject.url).to eq("/foo")
      end
    end
  end
end
