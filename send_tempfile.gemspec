$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "send_tempfile/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "send_tempfile"
  s.version     = SendTempfile::VERSION
  s.homepage    = "https://github.com/inferiorhumanorgans/send_tempfile"  # Eventually
  s.summary     = "Summary"
  s.description = "Description"
  s.authors     = ["Alex Zepeda"]

  s.files = Dir["{app,config,db,lib}/**/*", "COPYING", "COPYING.LESSER", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0.0"
end
