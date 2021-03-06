# GoToParam

Small set of Rails "go_to" redirection parameter utilities.

E.g. to catch a requested path and redirect to it after logging in or signing up.

## Usage

Include in some suitable base controller:

``` ruby
class ApplicationController < ActionController::Base
  include GoToParam
end
```

Now your controllers and views get some methods.

### go_to_here_params

Put the current/requested path in a `{ go_to: "/the_path" }` parameter hash.

Perhaps from a controller:

``` ruby
class ApplicationController < ActionController::Base
  include GoToParam

  before_filter :ensure_authenticated

  private

  def ensure_authenticated
    unless authenticated?
      redirect_to login_path(go_to_here_params)
    end
  end
end
```

Or a view:

``` erb
<h1>Show item</h1>
<%= link_to("Edit item", edit_item_path(@item, go_to_here_params)) %>
```

This only picks up the requested path if it's a GET, since we can't redirect back to a non-GET later. Otherwise an empty hash is returned.

You can pass additional query parameters to include, which could be suitable if you want to trigger some action after redirecting:

``` erb
<%= link_to("Add item after logging in", login_path(@item, go_to_here_params(perform_action: "add"))) %>
```

Note that these parameters always become transformed into a query string: if you're using Ruby on Rails, they won't be interpreted through your route definitions.


### hidden_go_to_tag

Pass the current `go_to` query parameter along with a form. Suitable e.g. if you're redirected from a restricted page to the login form.

``` erb
<h1>Log in</h1>

<form>
  <%= hidden_go_to_tag %>
  …
</form>
```

### hidden_go_to_here_tag

Pass the current/requested path as a `go_to` parameter along with a form. Suitable e.g. if you show a login form in a modal.

``` erb
<h1>Log in</h1>

<form>
  <%= hidden_go_to_here_tag %>
  …
</form>
```

Accepts additional query parameters just like [`go_to_here_params`](#go_to_here_params).

### go_to_params

Pass the `go_to` parameter along with a link.

``` erb
<%= link_to("Reset password", password_reset_path(go_to_params)) %>
```

You can pass in additional parameters for the given path:

``` erb
<%= link_to("Reset password", password_reset_path(go_to_params(email: @email))) %>
```

### go_to_path

Finally use the `go_to` parameter.

You probably want to provide a fallback path:

``` ruby
class SessionsController < ActionController::Base
  def create
    if logged_in?
      redirect_to(go_to_path || root_path)
    end
  end
end
```

Returns nil if the parameter value is not a relative path, to counter phishing attempts like `/login?go_to=http://evil.com/success_now_give_me_your_cc_details`.

### go_to_path_or

Syntactic sugar. These are equivalent:

``` ruby
redirect_to(go_to_path || root_path)
redirect_to go_to_path_or(root_path)
```

## Installation

Add this line to your application's Gemfile:

    gem 'go_to_param'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install go_to_param

## Configuration

If you need to redirect out of your web application, like to a ios app using a protocol, you can configure go_to_param to allow
this. Just set the allowed prefix in an initializer:

```ruby
GoToParam.add_to_allowed_redirect_prefixes("myapp://")
```

## License

Copyright (c) 2013 Henrik Nyh

MIT License

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
