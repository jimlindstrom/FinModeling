require 'fileutils'

require 'rubygems' 

require 'sec_query'
require 'edgar'
require 'xbrlware'

require 'naive_bayes'

#require 'restclient/components'
#require 'rack/cache'

$LOAD_PATH << "."

require 'lib/string_helpers'
require 'lib/xbrlware_item_helpers'
require 'lib/period_array'
require 'lib/company'
require 'lib/company_filing'
require 'lib/annual_report_filing'
require 'lib/company_filing_calculation'
require 'lib/balance_sheet_calculation'
require 'lib/income_statement_calculation'
require 'lib/income_statement_item'
require 'lib/net_income_calculation'
