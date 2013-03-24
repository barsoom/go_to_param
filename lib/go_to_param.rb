require "go_to_param/version"

module GoToParam
  def self.included(klass)
    klass.helper_method :hidden_go_to_tag, :go_to_param
  end

  def hidden_go_to_tag
    view_context.hidden_field_tag :go_to, go_to_path
  end

  def go_to_param(other_params = {})
    { go_to: go_to_path }.merge(other_params)
  end

  def get_go_to_param
    if request.get?
      { go_to: request.fullpath }
    else
      {}
    end
  end

  def go_to_path
    # Avoid phishing redirects.
    if raw_go_to_param_value.to_s.start_with?("/")
      raw_go_to_param_value
    else
      nil
    end
  end

  private

  def go_to_param_value
    params[:go_to]
  end
end
