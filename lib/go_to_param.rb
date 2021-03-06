require "cgi"
require "go_to_param/version"

module GoToParam
  def self.add_to_allowed_redirect_prefixes(prefix)
    allowed_redirect_prefixes << prefix
  end

  def self.allowed_redirect_prefixes
    @allowed_redirect_prefixes ||= [ "/" ]
  end

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
    { go_to: go_to_path}.merge(other_params)
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
    return nil if go_to_param_value.nil?
    # Avoid phishing redirects.
    if matches_allowed_redirect_prefixes?
      go_to_param_value
    else
      nil
    end
  end

  def go_to_path_or(default)
    go_to_path || default
  end

  private

  def matches_allowed_redirect_prefixes?
    GoToParam.allowed_redirect_prefixes.any? { |prefix| go_to_param_value.start_with?(prefix) }
  end

  def go_to_here_path(additional_query_params = {})
    if request.get?
      _go_to_add_query_string_from_hash(_utf8_request_full_path, additional_query_params)
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

  # Prevent encoding errors (incompatible character encodings: UTF-8 and ASCII-8BIT...)
  # Inspired on https://github.com/discourse/discourse/commit/090dc80f8a23dbb3ad703efbac990aa917c06505
  def _utf8_request_full_path
    path = request.fullpath
    path.dup.force_encoding("UTF-8").scrub
  end
end
