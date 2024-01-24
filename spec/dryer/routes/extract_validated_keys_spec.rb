require_relative "../../../lib/dryer/routes/extract_validated_keys.rb"
require 'dry-validation'

RSpec.describe Dryer::Routes::ExtractValidatedKeys do
  before do
    stub_const("SimpleContract", Class.new(Dry::Validation::Contract) do
      params do
        required(:foo).filled(:string)
      end
    end)

    stub_const("NestedContract", Class.new(Dry::Validation::Contract) do
      params do
        required(:foo).hash do
          required(:bar).filled(:string)
          required(:wat).hash do
            required(:blah).filled(:string)
          end
        end
      end
    end)
  end

  let(:simple_response) do { foo: "bar" } end
  let(:nested_response) do { foo: { bar: 'quux', wat: { blah: "grr" } } } end

  context "when there are keys in the payload that are not in the contract" do
    context "when the payload is flat" do
      it "excludes them from the results" do
        expect(
          described_class.call(payload: { foo: "bar", baz: "quux"}, contract: SimpleContract)
        ).to eq(simple_response)
      end
    end
        
    context "when the payload is flat" do
      it "excludes them from the results" do
        expect(
          described_class.call(
            payload: { blue: "green", foo: { a: [], bar: 'quux', wat: { blah: "grr", z: ["c"] } } },
            contract: NestedContract
          )
        ).to eq(nested_response)
      end
    end
  end

  context "when the payload argument is nil" do
    it "returns an empty hash" do
      expect(
        described_class.call(payload: nil, contract: SimpleContract)
      ).to eq({})
    end
  end

  context "when the contract argument is nil" do
    it "returns an empty hash" do
      expect(
        described_class.call(payload: {foo: "bar"}, contract: nil)
      ).to eq({})
    end
  end

  context "when payloads with string keys are passed in" do
    it "still works" do
      expect(
        described_class.call(payload: { "foo" => "bar", "baz" => "quux"}, contract: SimpleContract)
      ).to eq(simple_response)
      expect(
        described_class.call(
          payload: { "blue": "green", "foo": { "a": [], "bar": 'quux', "wat": { "blah": "grr", "z": ["c"] } } },
          contract: NestedContract
        )
      ).to eq(nested_response)
    end
  end
end
