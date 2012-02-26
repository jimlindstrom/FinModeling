require 'rubygems' 
require 'sec_query'
require 'edgar'
require 'xbrlware'

$LOAD_PATH << "."

require 'lib/string_helpers'
require 'lib/xbrlware_item_helpers'
require 'lib/company'
require 'lib/company_filing'
require 'lib/annual_report_filing'
require 'lib/company_filing_calculation'
require 'lib/balance_sheet_calculation'
require 'lib/income_statement_calculation'
