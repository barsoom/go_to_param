require_relative "../lib/go_to_param"

class FakeController
  attr_accessor :params, :view_context, :request

  def self.helper_method(*methods)
    @helper_methods = methods
  end

  def self.helper_methods
    @helper_methods
  end

  include GoToParam
end

describe GoToParam do
  let(:controller) { FakeController.new }

  describe "#hidden_go_to_tag" do
    it "makes it a helper method" do
      FakeController.helper_methods.should include :hidden_go_to_tag
    end

    it "adds a hidden field tag" do
      controller.params = { go_to: "/example", id: "1" }
      view = double
      controller.view_context = view

      view.should_receive(:hidden_field_tag).
        with(:go_to, "/example")
      controller.hidden_go_to_tag
    end
  end

  describe "#go_to_param" do
    it "makes it a helper method" do
      FakeController.helper_methods.should include :go_to_param
    end

    it "includes the go_to parameter" do
      controller.params = { go_to: "/example", id: "1" }

      controller.go_to_param.should == { go_to: "/example" }
    end

    it "accepts additional parameters" do
      controller.params = { go_to: "/example", id: "1" }

      controller.go_to_param(a: "b").should == { go_to: "/example", a: "b" }
    end
  end

  describe "#get_go_to_param" do
    it "gets the request path as the go_to parameter" do
      controller.request = double(get?: true, fullpath: "/example")
      controller.get_go_to_param.should == { go_to: "/example" }
    end

    it "returns an empty hash for a non-GET request" do
      controller.request = double(get?: false, fullpath: "/example")
      controller.get_go_to_param.should == {}
    end
  end

  describe "#go_to_path_or" do
    it "is the go_to parameter value" do
      controller.params = { go_to: "/example", id: "1" }
      controller.go_to_path_or("/default").should == "/example"
    end

    it "falls back to the passed-in value without a parameter value" do
      controller = FakeController.new
      controller.params = { id: "1" }
      controller.go_to_path_or("/default").should == "/default"
    end

    it "only allows relative paths" do
      controller.params = { go_to: "http://evil.com", id: "1" }
      controller.go_to_path_or("/default").should == "/default"
    end
  end
end
