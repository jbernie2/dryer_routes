require_relative "../../../lib/dryer_routes.rb"

RSpec.describe Dryer::Routes::ResourceAccessors do
  before do
    stub_const("FooController", Class.new do
      def self.controller_name
        "foo"
      end
    end)

    stub_const("FooCreateRequestContract", Class.new() do
    end)

    stub_const("FooCreateResponseContract", Class.new() do
    end)

    stub_const("FooShowResponseContract", Class.new() do
    end)
  end

  subject do 
    described_class.call(
      object: object,
      resources: resources
    )
  end

  let(:object) { Object.new }
  let(:resources) do
    [
      {
        controller: FooController,
        url: "/foo",
        actions: {
          create: {
            method: :post,
            request_contract: FooCreateRequestContract,
            response_contracts: {
              200 => FooCreateResponseContract,
            }
          },
          show: {
            method: :get,
            url: "/foo/:id",
            response_contracts: {
              200 => FooShowResponseContract,
            }
          }
        }
      }
    ]
  end

  it "adds methods to object to access the resource" do
    expect(subject.foo).to be_truthy
  end

  it "adds methods that return information about the resource" do
    expect(subject.foo.controller).to equal(FooController)

    expect(subject.foo.create.request_contract).to eq(FooCreateRequestContract)
    expect(subject.foo.create.response_contracts._200).to eq(FooCreateResponseContract)
    expect(subject.foo.create.url).to eq("/foo")

    expect(subject.foo.show.response_contracts._200).to eq(FooShowResponseContract)
    expect(subject.foo.show.url).to eq("/foo/:id")
    expect(subject.foo.show.url(2)).to eq("/foo/2")
  end
end
