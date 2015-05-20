require "cgi"
require "go_to_param/version"

module GoToParam
  def self.included(klass)
    klass.helper_method :hidden_go_to_tag, :hidden_go_to_here_tag,
      :go_to_params, :go_to_here_params,
      :go_to_path, :go_to_path_or
  end

  def hidden_go_to_tag
    view_context.hidden_field_tag :go_to, go_to_path
  end

  def hidden_go_to_here_tag(additional_query_params = {})
    view_context.hidden_field_tag :go_to, go_to_here_params(additional_query_params)[:go_to]
  end

  def go_to_params(other_params = {})
    { go_to: go_to_path }.merge(other_params)
  end

  def go_to_here_params(additional_query_params = {})
    path = go_to_here_path(additional_query_params)

    if path
      { go_to: path }
    else
      {}
    end
  end

  def go_to_path
    # Avoid phishing redirects.
    if go_to_param_value.to_s.start_with?("/")
      go_to_param_value
    else
      nil
    end
  end

  def go_to_path_or(default)
    go_to_path || default
  end

  private

  def go_to_here_path(additional_query_params = {})
    if request.get?
      _go_to_add_query_string_from_hash(request.fullpath, additional_query_params)
    else
      nil
    end
  end

  def go_to_param_value
    params[:go_to]
  end

  # Named this way to avoid conflicts. TODO: http://thepugautomatic.com/2014/02/private-api/
  def _go_to_add_query_string_from_hash(path, hash)
    if hash.empty?
      path
    else
      separator = path.include?("?") ? "&" : "?"
      query_string = hash.map { |k, v| "#{k}=#{CGI.escape v.to_s}" }.join("&")
      [ path, separator, query_string ].join
    end
  end
end
