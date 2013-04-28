Gem::Specification.new do |s|
  s.name         = 'xtopherus'
  s.version      = File.read('VERSION')
  s.date         = Time.now.strftime('%Y-%m-%d')
  s.summary      = 'An IRC bot that sits in #pry on Freenode.'
  s.author       = 'Kyrylo Silin'
  s.email        = 'kyrylosilin@gmail.com'
  s.homepage     = 'https://github.com/kyrylo/xtopherus'
  s.licenses     = 'zlib'

  s.require_path = 'lib'
  s.files        = `git ls-files`.split("\n")
  s.executable   = 'xtopherus'

  s.add_runtime_dependency 'cinch'
  s.add_runtime_dependency 'sequel'
  s.add_runtime_dependency 'sqlite3'

  s.add_development_dependency 'bacon'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'pry'
end
