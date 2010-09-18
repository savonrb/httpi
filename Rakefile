begin
  require "rspec/core/rake_task"

  RSpec::Core::RakeTask.new do |t|
    t.rspec_opts = %w(-fd -c)
  end
rescue LoadError
  task :spec do
    abort "Run 'gem install rspec' to be able to run specs"
  end
end

task :default => :spec
