require 'rspec-benchmark'
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'schulze_vote'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include RSpec::Benchmark::Matchers
end
