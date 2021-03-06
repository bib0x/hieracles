# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "hieracles"
  spec.version       = File.read(File.expand_path('../CHANGELOG.md', __FILE__))[/([0-9]+\.[0-9]+\.[0-9]+)/]
  spec.authors       = ["mose"]
  spec.email         = ["mose@gandi.net"]
  spec.summary       = %q{CLI tool for Hiera parameters visualization.}
  spec.description   = %q{CLI tool for Hiera parameters visualization and analysis.}
  spec.homepage      = "https://github.com/Gandi/hieracles"
  spec.metadata      = { "changelog" => "https://github.com/Gandi/hieracles/blob/master/CHANGELOG.md" }
  spec.license       = "MIT"

  spec.files         = Dir.glob("{bin,lib}/**/*") + 
                       %w(CHANGELOG.md Gemfile LICENSE README.md hc.1 ppdb.1)
  spec.executables   = ['hieracles', 'hc', 'ppdb']
  spec.test_files    = Dir.glob("spec/**/*")
  spec.require_paths = ["lib"]

  spec.add_dependency 'httparty'
  spec.add_dependency 'deep_merge'
  spec.add_dependency 'awesome_print'

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec', "~> 3.0"
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'simplecov', ">= 0.12.0"
  spec.add_development_dependency 'rubocop'

end
