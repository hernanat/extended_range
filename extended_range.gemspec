# frozen_string_literal: true

require_relative "lib/extended_range/version"

Gem::Specification.new do |spec|
  spec.name          = "extended_range"
  spec.version       = ExtendedRange::VERSION
  spec.authors       = ["Anthony Felix Hernandez"]
  spec.email         = ["ant@antfeedr.com"]

  spec.summary       = "Some handy methods for the `Range` class."
  spec.homepage      = "https://github.com/hernanat/extended_range"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  spec.add_development_dependency "pry"
  spec.add_development_dependency "yard", "~> 0.9"
  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
