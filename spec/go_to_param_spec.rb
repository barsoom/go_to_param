require_relative "../lib/go_to_param"

class FakeController
  attr_accessor :params, :view_context, :request

  def self.helper(mod)
    @helpers ||= []
    @helpers << mod
  end

  def self.helpers
    @helpers
  end

  include GoToParam
end

describe GoToParam do
  let(:controller) { FakeController.new }

  it "makes itself a helper module" do
    FakeController.helpers.should include(GoToParam)
  end

  it "can be included in a non-controller (e.g. a helpers module)" do
    helpers = Module.new
    helpers.send :include, GoToParam
  end

  describe "#hidden_go_to_tag" do
    it "adds a hidden field tag" do
      controller.params = { go_to: "/example", id: "1" }
      view = double
      controller.view_context = view

      view.should_receive(:hidden_field_tag).
        with(:go_to, "/example")
      controller.hidden_go_to_tag
    end
  end

  describe "#go_to_hash" do
    it "includes the go_to parameter" do
      controller.params = { go_to: "/example", id: "1" }

      controller.go_to_hash.should == { go_to: "/example" }
    end

    it "accepts additional parameters" do
      controller.params = { go_to: "/example", id: "1" }

      controller.go_to_hash(a: "b").should == { go_to: "/example", a: "b" }
    end
  end

  describe "#build_go_to_hash" do
    it "gets the request path as the go_to parameter" do
      controller.request = double(get?: true, fullpath: "/example")
      controller.build_go_to_hash.should == { go_to: "/example" }
    end

    it "returns an empty hash for a non-GET request" do
      controller.request = double(get?: false, fullpath: "/example")
      controller.build_go_to_hash.should == {}
    end
  end

  describe "#go_to_path" do
    it "is the go_to parameter value" do
      controller.params = { go_to: "/example", id: "1" }
      controller.go_to_path.should == "/example"
    end

    it "is nil if the parameter value is not a relative path" do
      controller.params = { go_to: "http://evil.com", id: "1" }
      controller.go_to_path.should be_nil
    end
  end

  describe "#go_to_path_or" do
    it "is the go_to parameter value" do
      controller.params = { go_to: "/example", id: "1" }
      controller.go_to_path_or("/default").should == "/example"
    end

    it "is the passed-in value if the parameter value is not a relative path" do
      controller.params = { go_to: "http://evil.com", id: "1" }
      controller.go_to_path_or("/default").should == "/default"
    end
  end
end
