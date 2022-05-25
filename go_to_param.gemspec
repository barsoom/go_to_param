lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "go_to_param/version"

Gem::Specification.new do |spec|
  spec.name          = "go_to_param"
  spec.version       = GoToParam::VERSION
  spec.authors       = [ "Henrik N" ]
  spec.email         = [ "henrik@nyh.se" ]
  spec.summary       = %q{Rails "go_to" redirection param utilities.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*.rb", "README.md", "CHANGELOG.md"]
  spec.require_paths = [ "lib" ]
  spec.metadata      = { "rubygems_mfa_required" => "true" }
end
