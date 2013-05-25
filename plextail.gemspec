# encoding: utf-8
Gem::Specification.new do |spec|
  spec.name          = 'plextail'
  spec.version       = '0.0.3'
  spec.authors       = ['Pat Allan']
  spec.email         = ['pat@freelancing-gods.com']
  spec.summary       = 'Pipes tailed files to Heroku Logplex'
  spec.description   = 'Takes tailed files in a single tail call and sends them through to Heroku Logplex with custom logplex tokens.'
  spec.homepage      = 'https://github.com/flying-sphinx/plextail'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'faraday', '~> 0.8'

  spec.add_development_dependency 'fakeweb',         '~> 1.3.0'
  spec.add_development_dependency 'fakeweb-matcher', '~> 1.2.2'
  spec.add_development_dependency 'rake',            '~> 10.0.4'
  spec.add_development_dependency 'rspec',           '~> 2.13.0'
end
