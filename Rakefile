require 'rspec/core/rake_task'
require 'rspec/core/version'

task :default => [:spec]

begin
  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.pattern = 'spec/**/*_spec.rb'
    spec.rspec_opts = ['-c -f d']
  end
rescue LoadError => e
  print e
end
