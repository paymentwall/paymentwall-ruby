Gem::Specification.new do |s|
  s.name        = 'paymentwall'
  s.version     = '1.1.1'
  s.summary     = "Paymentwall gem"
  s.description = "Paymentwall is the leading digital payments platform for globally monetizing digital goods and services."
  s.authors     = ["Heitor Dolinski"]
  s.email       = 'heitor@paymentwall.com'
  s.files       = Dir.glob("lib/**/*") + %w(LICENSE README.md Rakefile)
  s.homepage    = 'http://www.paymentwall.com'
  s.license     = 'MIT'

  s.add_development_dependency('rake')
  s.add_development_dependency('cucumber')
  s.add_development_dependency('hpricot')
  s.add_development_dependency('minitest')
  s.add_development_dependency('uri-query_params')
end
