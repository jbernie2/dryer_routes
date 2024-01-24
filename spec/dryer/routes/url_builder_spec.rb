require_relative "../../../lib/dryer_routes.rb"

RSpec.describe Dryer::Routes::UrlBuilder do
  subject { described_class.call(url) }

  context "when the url contains no path variables" do
    let(:url) { "/foo" }
    it "returns the url unchanged" do
      expect(subject).to eq(url)
    end
  end

  context "when the url contains path variables" do
    let(:url) { "/foo/:id" }
    it "returns a function" do
      expect(subject).to be_a(Proc)
    end

    context "when a function is returned" do
      let(:url) { "/foo/:id/bar/:id" }
      it "interpolates the arguments into the url in correct order" do
        expect(subject.call(1,2)).to eq("/foo/1/bar/2")
      end

      context "when more arguments are passed in than there are variables" do
        it "ignores the extra arguments" do
          expect(subject.call(1,2,3,4,5)).to eq("/foo/1/bar/2")
        end
      end

      context "when not enough arguments are passed in" do
        it "leaves the path variables in the url" do
          expect(subject.call(1)).to eq("/foo/1/bar/:id")
        end
      end
    end
  end
end
