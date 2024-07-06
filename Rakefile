Bundler.require
require "rake/testtask"

desc "Default: run tests"
task default: :test

Rake::TestTask.new do |t|
  t.libs = ["lib", "test"]
  t.pattern = "test/**/*_test.rb"
  t.verbose = true
end
