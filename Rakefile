require "rake"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new do |t|
  t.pattern = "spec/httpi/**/*_spec.rb"
  t.rspec_opts = %w(-fd -c)
end

desc "Run RSpec integration examples"
RSpec::Core::RakeTask.new "spec:integration" do |t|
  t.pattern = "spec/integration/*_spec.rb"
  t.rspec_opts = %w(-fd -c)
end

task :default => :spec
task :test => :spec
