lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'go_to_param/version'

Gem::Specification.new do |spec|
  spec.name          = "go_to_param"
  spec.version       = GoToParam::VERSION
  spec.authors       = ["Henrik N"]
  spec.email         = ["henrik@nyh.se"]
  spec.summary       = %q{Rails "go_to" redirection param utilities.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
