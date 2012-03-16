require 'fileutils'
require 'digest' 

require 'rubygems' 

require 'sec_query'
require 'edgar'
require 'xbrlware'

require 'naive_bayes'

$LOAD_PATH << "."

require 'lib/string_helpers'
require 'lib/factory'

require 'lib/xbrlware_valuemapping_vectors'
require 'lib/xbrlware_item'
require 'lib/xbrlware_linkbase'
require 'lib/xbrlware_context'
require 'lib/xbrlware_dateutil'

require 'lib/period_array'
require 'lib/rate'
require 'lib/company'
require 'lib/company_filing'
require 'lib/annual_report_filing'
require 'lib/quarterly_report_filing'
require 'lib/calculation_summary'
require 'lib/multi_column_calculation_summary'
require 'lib/company_filing_calculation'
require 'lib/balance_sheet_calculation'
require 'lib/assets_calculation'
require 'lib/liabs_and_equity_calculation'
require 'lib/income_statement_calculation'
require 'lib/income_statement_item_vectors'
require 'lib/income_statement_item'
require 'lib/net_income_calculation'
require 'lib/cash_flow_statement_calculation'
require 'lib/cash_change_calculation'
require 'lib/assets_item_vectors'
require 'lib/assets_item'
require 'lib/liabs_and_equity_item_vectors'
require 'lib/liabs_and_equity_item'
require 'lib/reformulated_income_statement'
require 'lib/reformulated_balance_sheet'

# FIXME: move this into some kind of initializer...
FinModeling::IncomeStatementItem.load_vectors_and_train(FinModeling::IncomeStatementItem::TRAINING_VECTORS)
FinModeling::AssetsItem.load_vectors_and_train(FinModeling::AssetsItem::TRAINING_VECTORS)
FinModeling::LiabsAndEquityItem.load_vectors_and_train(FinModeling::LiabsAndEquityItem::TRAINING_VECTORS)
Xbrlware::ValueMappingWithClassifier.load_vectors_and_train(Xbrlware::ValueMapping::TRAINING_VECTORS)

