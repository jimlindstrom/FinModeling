require 'rspec'

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), "../lib")))
require 'finmodeling'

require 'mocks/sec_query'
require 'mocks/calculation'
require 'matchers/custom_matchers'
