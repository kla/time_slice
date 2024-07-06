require_relative "lib/time_slice/version"

Gem::Specification.new do |spec|
  spec.name        = "time_slice"
  spec.version     = TimeSlice::VERSION
  spec.platform    = Gem::Platform::RUBY
  spec.authors     = ["Kien La"]
  spec.email       = ["la.kien@gmail.com"]
  spec.description = "Time slice"
  spec.summary     = "A Ruby library for slicing time."
  spec.homepage    = "https://github.com/kla/time_slice"

  spec.files          = ::Dir.glob("{lib}/**/*")
  spec.executables    = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files     = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths  = ["lib"]

  spec.add_dependency("activesupport", "> 5.1")
  spec.add_dependency("rounding")

  spec.add_development_dependency("rake")
  spec.add_development_dependency("minitest")
  spec.add_development_dependency("mocha")
end
