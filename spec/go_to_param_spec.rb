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
  after { GoToParam.reset_allowed_redirect_prefixes }

  let(:controller) { FakeController.new }

  describe "#hidden_go_to_tag" do
    it "becomes a helper method" do
      expect(FakeController.helper_methods).to include :hidden_go_to_tag
    end

    it "adds a hidden field tag" do
      controller.params = { go_to: "/example", id: "1" }
      view = double
      controller.view_context = view

      expect(view).to receive(:hidden_field_tag).with(:go_to, "/example")
      controller.hidden_go_to_tag
    end
  end

  describe "#hidden_go_to_here_tag" do
    it "becomes a helper method" do
      expect(FakeController.helper_methods).to include :hidden_go_to_here_tag
    end

    it "adds a hidden field tag" do
      controller.request = double(get?: true, fullpath: "/example")
      view = double
      controller.view_context = view

      expect(view).to receive(:hidden_field_tag).with(:go_to, "/example")
      controller.hidden_go_to_here_tag
    end

    # Tested in more detail in #go_to_here_params.
    it "accepts additional query parameters" do
      controller.request = double(get?: true, fullpath: "/example?a=1")
      view = double
      controller.view_context = view

      expect(view).to receive(:hidden_field_tag).with(:go_to, "/example?a=1&b=1+2")
      controller.hidden_go_to_here_tag(b: "1 2")
    end
  end

  describe "#go_to_params" do
    it "becomes a helper method" do
      expect(FakeController.helper_methods).to include :go_to_params
    end

    it "includes the go_to parameter" do
      controller.params = { go_to: "/example", id: "1" }

      expect(controller.go_to_params).to eq({ go_to: "/example" })
    end

    it "accepts additional parameters" do
      controller.params = { go_to: "/example", id: "1" }

      expect(controller.go_to_params(a: "b")).to eq({ go_to: "/example", a: "b" })
    end
  end

  describe "#go_to_here_params" do
    it "becomes a helper method" do
      expect(FakeController.helper_methods).to include :go_to_here_params
    end

    it "gets the request path as the go_to parameter" do
      controller.request = double(get?: true, fullpath: "/example")
      expect(controller.go_to_here_params).to eq({ go_to: "/example" })
    end

    it "returns an empty hash for a non-GET request" do
      controller.request = double(get?: false, fullpath: "/example")
      expect(controller.go_to_here_params).to eq({})
    end

    it "accepts additional query parameters" do
      controller.request = double(get?: true, fullpath: "/example")
      expect(controller.go_to_here_params(foo: "1 2", bar: 3)).to eq({ go_to: "/example?foo=1+2&bar=3" })

      # Handles pre-existing "?"
      controller.request = double(get?: true, fullpath: "/example?foo")
      expect(controller.go_to_here_params(bar: 3)).to eq({ go_to: "/example?foo&bar=3" })
    end

    it "accepts an anchor parameter" do
      controller.request = double(get?: true, fullpath: "/example")
      expect(controller.go_to_here_params(foo: "foo", anchor: "bar")).to eq({ go_to: "/example?foo=foo#bar" })
    end

    it "makes sure the go_to path is valid UTF-8" do
      weird_path = "\xE0\x80\x80weird\330stuff".force_encoding("ASCII-8BIT")
      replacement = "\uFFFD"  # The Unicode "Replacement Character".

      controller.request = double(get?: true, fullpath: weird_path)

      go_to_value = controller.go_to_here_params[:go_to]

      expect(go_to_value.encoding).to eq(Encoding::UTF_8)
      expect(go_to_value).to eq("#{replacement}#{replacement}#{replacement}weird#{replacement}stuff")
    end
  end

  describe "#go_to_path" do
    it "becomes a helper method" do
      expect(FakeController.helper_methods).to include :go_to_path
    end

    it "is the go_to parameter value" do
      controller.params = { go_to: "/example", id: "1" }
      expect(controller.go_to_path).to eq("/example")
    end

    it "is nil if the parameter value is not a relative path" do
      controller.params = { go_to: "http://evil.com", id: "1" }
      expect(controller.go_to_path).to be_nil
    end

    it "is nil when given a hash" do
      controller.params = { go_to: { evil: "true" }, id: "1" }
      expect(controller.go_to_path).to be_nil
    end

    it "respects custom allowed redirect prefixes" do
      GoToParam.allow_redirect_prefix("myapp://")

      controller.params = { go_to: "myapp://", id: "1" }
      expect(controller.go_to_path).to eq("myapp://")
    end
  end

  describe "#go_to_path_or" do
    it "becomes a helper method" do
      expect(FakeController.helper_methods).to include :go_to_path_or
    end

    it "is the go_to parameter value" do
      controller.params = { go_to: "/example", id: "1" }
      expect(controller.go_to_path_or("/default")).to eq("/example")
    end

    it "falls back if the go_to param is blank" do
      controller.params = { go_to: "", id: "1" }
      expect(controller.go_to_path_or("/default")).to eq("/default")
    end

    it "falls back if the go_to param is not allowed" do
      controller.params = { go_to: "http://evil.com", id: "1" }
      expect(controller.go_to_path_or("/default")).to eq("/default")
    end
  end
end
