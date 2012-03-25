require 'fileutils'
require 'digest' 

require 'rubygems' 

require 'sec_query'
require 'edgar'
require 'xbrlware'

require 'naive_bayes'
require 'statsample'

$LOAD_PATH << "."

require 'lib/float_helpers'
require 'lib/string_helpers'
require 'lib/factory'

require 'lib/has_string_classifer'

require 'lib/xbrlware_valuemapping_vectors'
require 'lib/xbrlware_item'
require 'lib/xbrlware_linkbase'
require 'lib/xbrlware_context'
require 'lib/xbrlware_dateutil'

require 'lib/period_array'
require 'lib/rate'
require 'lib/company'

require 'lib/company_filings'
require 'lib/company_filing'
require 'lib/annual_report_filing'
require 'lib/quarterly_report_filing'

require 'lib/calculation_summary'
require 'lib/multi_column_calculation_summary'

require 'lib/can_classify_rows'
require 'lib/can_cache_classifications'
require 'lib/can_cache_summaries'

require 'lib/assets_item_vectors'
require 'lib/assets_item'
require 'lib/liabs_and_equity_item_vectors'
require 'lib/liabs_and_equity_item'
require 'lib/income_statement_item_vectors'
require 'lib/income_statement_item'
require 'lib/cash_change_item_vectors'
require 'lib/cash_change_item'

require 'lib/company_filing_calculation'
require 'lib/balance_sheet_calculation'
require 'lib/assets_calculation'
require 'lib/liabs_and_equity_calculation'
require 'lib/income_statement_calculation'
require 'lib/net_income_calculation'
require 'lib/cash_flow_statement_calculation'
require 'lib/cash_change_calculation'

require 'lib/reformulated_income_statement'
require 'lib/reformulated_balance_sheet'
require 'lib/reformulated_cash_flow_statement'

require 'lib/config'

require 'lib/classifiers'
FinModeling::Classifiers.train

require 'lib/balance_sheet_analyses'
require 'lib/income_statement_analyses'

require 'lib/forecasting_policy'
require 'lib/forecasts'

