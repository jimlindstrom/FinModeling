# load the implementation
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..'))
require 'finmodeling'

require 'mocks/sec_query'
require 'mocks/calculation'
require 'helpers/factory'

RSpec.configure do |c|
  c.add_setting :use_income_statement_factory, :default => true
end
