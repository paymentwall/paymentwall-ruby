# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'paymentwall'
  spec.version       = '1.0.0'
  spec.authors       = %w(paymentwall-dev ivan-kovalyov saks mihai-aupeo)
  spec.email         = %w(devsupport@paymentwall.com)
  spec.description   = %q{PaymentWall Ruby}
  spec.summary       = %q{This library allows developers to use Paymentwall APIs (Virtual Currency, Digital Goods featuring recurring billing, and Virtual Cart)}
  spec.homepage      = %q{http://www.paymentwall.com}
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*.rb'] #`git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = %w(lib)

  spec.add_development_dependency 'bundler', '~> 1.3'
  # spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov'
  #
  # spec.add_development_dependency 'yard'
  # spec.add_development_dependency 'redcarpet'
  # spec.add_development_dependency 'github-markup'
end