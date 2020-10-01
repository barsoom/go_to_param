require "cgi"
require "go_to_param/version"

module GoToParam
  def self.allow_redirect_prefix(prefix)
    allowed_redirect_prefixes << prefix
  end

  def self.allowed_redirect_prefixes
    reset_allowed_redirect_prefixes unless @allowed_redirect_prefixes
    @allowed_redirect_prefixes
  end

  # Mostly for tests…
  def self.reset_allowed_redirect_prefixes
    @allowed_redirect_prefixes = [ "/" ]
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
    { go_to: go_to_path }.merge(other_params)
  end

  def go_to_here_params(additional_query_params = {})
    path = go_to_here_path(**additional_query_params)

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

  def go_to_here_path(anchor: nil, **additional_query_params)
    if request.get?
      path_without_anchor = _go_to_add_query_string_from_hash(_go_to_fullpath, additional_query_params)
      anchor ? path_without_anchor + "#" + anchor : path_without_anchor
    else
      nil
    end
  end

  def go_to_param_value
    # We use `to_s` to avoid "not a string" type errors from hack attempts where a hash is passed, e.g. "go_to[foo]=bar".
    value = params[:go_to].to_s
    value == "" ? nil : value
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

  # Prevent encoding errors ("incompatible character encodings: UTF-8 and ASCII-8BIT") for certain malformed requests.
  # Inspired by https://github.com/discourse/discourse/commit/090dc80f8a23dbb3ad703efbac990aa917c06505
  def _go_to_fullpath
    path = request.fullpath
    path.dup.force_encoding("UTF-8").scrub
  end
end
