require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new do |t|
  t.pattern = "spec/httpi/**/*_spec.rb"
end

desc "Run RSpec integration examples"
RSpec::Core::RakeTask.new "spec_integration" do |t|
  t.pattern = "spec/integration/*_spec.rb"
end

desc "Run RSpec code and integration examples"
RSpec::Core::RakeTask.new "ci" do |t|
  t.pattern = "spec/{httpi,integration}/**/*_spec.rb"
end

task :default => :spec
