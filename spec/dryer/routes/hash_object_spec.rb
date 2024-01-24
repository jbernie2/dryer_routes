require_relative "../../../lib/dryer_routes.rb"

RSpec.describe Dryer::Routes::HashObject do

  subject { described_class.new(hash) }

  context "when the values are literals" do
    let(:hash) { { a: 1, b: "c", c: 2.8, d: [1,2,3] } }
    it "creates methods that return those values" do
      expect(subject.a).to eq(1)
      expect(subject.b).to eq("c")
      expect(subject.c).to eq(2.8)
      expect(subject.d).to eq([1,2,3])
    end
  end

  context "when the keys are numeric" do
    let(:hash) {{ 1 => 2 }}
    it "prefixes them with _" do
      expect(subject._1).to eq(2)
    end
  end

  context "when the values are a hash" do
    let(:hash) {{ foo: { bar: "quux" } }}
    it "creates nested methods" do
      expect(subject.foo.bar).to eq("quux")
    end
  end

  context "when the values are a proc" do
    let(:hash) {{ foo: -> { "return value" } }}
    it "calls the proc when the attribute is accessed" do
      expect(subject.foo).to eq("return value")
    end

    context "when the proc has arguments" do
      let(:hash) {{ foo: -> (*args) { args.join(" and ") } }}
      it "allows the arguments to be passed in" do
        expect(subject.foo(1,2)).to eq("1 and 2")
      end
    end

    context "when the proc has keyword arguments" do
      let(:hash) {{ foo: -> (a:, b:) {"#{a} and #{b}"} }}
      it "allows the arguments to be passed in" do
        expect(subject.foo(a:1, b:2)).to eq("1 and 2")
      end
    end
  end

  context "when there are nested keys with the same names" do
    let(:hash) do
      {
        create: { url: "/foo" },
        show: { url: "/bar" }
      }
    end

    it "correctly creates the methods to return the right values" do
      expect(subject.create.url).to eq('/foo')
      expect(subject.show.url).to eq('/bar')
    end
  end
end

