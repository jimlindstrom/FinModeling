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
require 'lib/assets_calculation'
require 'lib/liabs_and_equity_calculation'
require 'lib/income_statement_calculation'
require 'lib/income_statement_item_vectors'
require 'lib/income_statement_item'
require 'lib/net_income_calculation'
require 'lib/assets_item_vectors.rb'
require 'lib/assets_item'
require 'lib/liabs_and_equity_item_vectors.rb'
require 'lib/liabs_and_equity_item'

FinModeling::IncomeStatementItem.load_vectors_and_train(FinModeling::IncomeStatementItem::TRAINING_VECTORS)
FinModeling::AssetsItem.load_vectors_and_train(FinModeling::AssetsItem::TRAINING_VECTORS)
FinModeling::LiabsAndEquityItem.load_vectors_and_train(FinModeling::LiabsAndEquityItem::TRAINING_VECTORS)
