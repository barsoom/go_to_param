require "go_to_param/version"

module GoToParam
  def self.included(klass)
    klass.helper_method :hidden_go_to_tag, :go_to_param
  end

  def hidden_go_to_tag
    view_context.hidden_field_tag :go_to, go_to_value
  end

  def go_to_param(other_params = {})
    { go_to: go_to_value }.merge(other_params)
  end

  def get_go_to_param
    if request.get?
      { go_to: request.fullpath }
    else
      {}
    end
  end

  def go_to_path_or(path)
    # Avoid phishing redirects.
    if go_to_value.to_s.start_with?("/")
      go_to_value
    else
      path
    end
  end

  private

  def go_to_value
    params[:go_to]
  end
end
