Gem::Specification.new {|g|
    g.name          = 'confparser'
    g.version       = '0.0.1.2'
    g.author        = 'shura'
    g.email         = 'shura1991@gmail.com'
    g.homepage      = 'http://github.com/shurizzle/confparser'
    g.platform      = Gem::Platform::RUBY
    g.description   = 'parses configuration files compatable with Python\'s ConfigParser, gitconfig, etc'
    g.summary       = g.description.dup
    g.files         = Dir.glob('lib/**/*')
    g.require_path  = 'lib'
    g.executables   = [ ]
    g.has_rdoc      = true
}
