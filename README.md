## Overview

FinModeling is a set of tools for manipulating financial data from SEC Edgar (in [XBRL](http://en.wikipedia.org/wiki/XBRL) format).

## Features

- Pulls annual (10-k) and quarterly (10-q) financial reports from SEC
- Uses Naive Bayes Classifiers to classify financial statement items
  - trained on medium-to-large NASDAQ tech companies
- Reformulates GAAP statements to better highlight enterprise value
- Generates forecasts based on analysis of historical performance

## Example 1: Forecasting Oracle's Financials Based

    lindstro@lindstro-laptop:~/code/finmodels$ ./examples/show_reports.rb --num-forecasts 2 orcl 2011-02-01
    Forecasting 2 periods
    company name: ORACLE CORP

	                      2011-02-28    2011-05-31    2011-08-31    2011-11-30   2012-02-29E   2012-05-29E
	NOA ($MM)               28,172.0      28,282.0      25,235.0      27,055.0      27,342.0      29,107.0
	NFA ($MM)                8,445.0      11,494.0      15,657.0      14,865.0      16,899.0      17,593.0
	CSE ($MM)               36,617.0      39,776.0      40,892.0      41,920.0      44,241.0      46,700.0
	Composition Ratio         3.3359        2.4605        1.6117        1.8200        1.6179        1.6545
	NOA Growth                              0.0155       -0.3638        0.3222        0.0431        0.2888
	CSE Growth                              0.3886        0.1160        0.1047        0.2412        0.2452

		NOA growth: a:-0.1619, b:0.1533, r:0.4461, var:0.0787

	                      2011-02-28    2011-05-31    2011-08-31    2011-11-30   2012-02-29E   2012-05-29E
	Revenue ($MM)            8,764.0      10,775.0       8,374.0       8,792.0       9,360.0       9,964.0
	Core OI ($MM)            2,318.0       3,413.0       2,056.0       2,327.0       2,483.0       2,644.0
	OI ($MM)                 2,238.0       3,332.0       1,978.0       2,290.0                            
	FI ($MM)                  -122.0        -123.0        -138.0         -98.0        -163.0        -185.0
	NI ($MM)                 2,116.0       3,209.0       1,840.0       2,192.0       2,321.0       2,459.0
	Gross Margin              0.5858        0.6040        0.5679        0.5845                            
	Sales PM                  0.2644        0.3167        0.2454        0.2646        0.2653        0.2653
	Operating PM              0.2553        0.3092        0.2361        0.2604                            
	FI / Sales               -0.0139       -0.0114       -0.0164       -0.0111       -0.0173       -0.0185
	NI / Sales                0.2414        0.2978        0.2197        0.2493        0.2479        0.2467
	Sales / NOA                             1.5298        1.1843        1.3936        1.3837        1.4576
	FI / NFA                               -0.0581       -0.0479       -0.0250       -0.0437       -0.0437
	Revenue Growth                          1.2695       -0.6321        0.2157        0.2852        0.2888
	Core OI Growth                          3.6455       -0.8661        0.6443        0.2974        0.2888
	OI Growth                               3.8474       -0.8737        0.8006                            
	ReOI ($MM)                             2,647.0       1,290.0       1,683.0       1,833.0       1,993.0

		operating pm: a:0.2739, b:-0.0057, r:-0.2398, var:0.0007
		asset turnover: a:1.4374, b:-0.0681, r:-0.3914, var:0.0201
		revenue growth: a:0.8112, b:-0.5268, r:-0.5530, var:0.6050
		fi / nfa: a:-0.0602, b:0.0165, r:0.9765, var:0.0001

	                      Unknown...    2011-05-31    2011-08-31    2011-11-30
	C ($MM)                                  -17.0       5,421.0       1,255.0
	I ($MM)                               -8,380.0     -13,091.0      -9,191.0
	d ($MM)                                8,688.0       8,568.0       8,956.0
	F ($MM)                                 -291.0        -898.0      -1,020.0
	FCF ($MM)                             -8,397.0      -7,670.0      -7,936.0
	NI / C                               -188.7647        0.3394        1.7466

## Example 2: A Summary of Adobe's Filings Since 2010-11-01

    lindstro@lindstro-laptop:~/code/finmodels$ ./examples/show_reports.rb adbe 2010-11-01
    company name: ADOBE SYSTEMS INC

	                      2010-12-03    2011-03-04    2011-06-03    2011-09-02    2011-12-02
	NOA (000's)          4,269,074.0   4,374,531.0   4,334,056.0   4,428,947.0   4,458,509.0
	NFA (000's)            923,313.0   1,050,876.0   1,055,359.0   1,135,011.0   1,324,604.0
	CSE (000's)          5,192,387.0   5,425,407.0   5,389,415.0   5,563,958.0   5,783,113.0
	Composition Ratio         4.6236        4.1627        4.1067        3.9021        3.3659
	NOA Growth                              0.1028       -0.0365        0.0907        0.0270
	CSE Growth                              0.1925       -0.0263        0.1363        0.1676

		NOA growth: a:0.0610, b:-0.0100, r:-0.2006, var:0.0031

	                      Unknown...    2011-03-04    2011-06-03    2011-09-02    2011-12-02
	Revenue (000's)                    1,027,706.0   1,023,179.0   1,013,212.0   1,152,161.0
	Core OI (000's)                      251,831.0     247,172.0     215,630.0     251,253.0
	OI (000's)                           245,152.0     240,798.0     206,405.0     182,137.0
	FI (000's)                           -10,561.0     -11,362.0     -11,304.0      -8,418.0
	NI (000's)                           234,591.0     229,436.0     195,101.0     173,719.0
	Gross Margin                            0.8952        0.8932        0.8967        0.8989
	Sales PM                                0.2450        0.2415        0.2128        0.2180
	Operating PM                            0.2385        0.2353        0.2037        0.1580
	FI / Sales                             -0.0102       -0.0111       -0.0111       -0.0073
	NI / Sales                              0.2282        0.2242        0.1925        0.1507
	Sales / NOA                                           0.2338        0.2337        0.2601
	FI / NFA                                             -0.0108       -0.0107       -0.0074
	Revenue Growth                                       -0.0175       -0.0385        0.6744
	Core OI Growth                                       -0.0721       -0.4216        0.8464
	OI Growth                                            -0.0693       -0.4610       -0.3944
	ReOI (000's)                                       135,604.0     102,185.0      75,635.0

		operating pm: a:0.2498, b:-0.0273, r:-0.9434, var:0.0010
		asset turnover: a:0.2294, b:0.0131, r:0.8641, var:0.0001
		revenue growth: a:-0.1398, b:0.3459, r:0.8528, var:0.1097

	                      Unknown...    2011-03-04    2011-06-03    2011-09-02    2011-12-02
	C (000's)                            332,102.0     397,743.0     320,434.0     334,399.0
	I (000's)                           -226,787.0    -229,749.0    -391,441.0    -385,261.0
	d (000's)                            -20,966.0     196,511.0     164,509.0      48,818.0
	F (000's)                            -84,349.0    -364,505.0     -93,502.0       2,044.0
	FCF (000's)                          105,315.0     167,994.0     -71,007.0     -50,862.0
	NI / C                                  0.7063        0.5768        0.6088        0.5194

## Example 3: A Detailed View of Adobe's Second-to-Last 10-Q

    lindstro@lindstro-laptop:~/code/finmodels$ ./examples/show_report.rb adbe 10-q -2
    company name: ADOBE SYSTEMS INC
    url:          http://www.sec.gov/Archives/edgar/data/796343/000079634311000006/0000796343-11-000006-index.htm
    Balance Sheet (2011-03-04)
    Assets (loc_Assets_1)
	[fa] Cash And Cash Equivalents At Carrying Value                     900,156,000.0
	[fa] Short Term Investments                                        1,736,679,000.0
	[oa] Accounts Receivable Net Current                                 533,353,000.0
	[fa] Deferred Tax Assets Net Current                                  66,928,000.0
	[oa] Prepaid Expenses Other Assets                                   113,682,000.0
	[oa] Property Plant And Equipment Net                                453,497,000.0
	[oa] Goodwill                                                      3,686,073,000.0
	[oa] Finite Lived Intangible Assets Net                              447,616,000.0
	[fa] Investment In Lease Receivable                                  207,239,000.0
	[oa] Other Assets Noncurrent                                         164,801,000.0
	Total                                                              8,310,024,000.0

    Liabilities and Stockholders' Equity (loc_LiabilitiesAndStockholdersEquity_1)
	[ol] Accrued Restructuring Current                                     6,759,000.0
	[fl] Accrued Income Taxes Current                                     57,096,000.0
	[ol] Capital Lease Obligations Current                                 8,900,000.0
	[ol] Accrued Liabilities Current                                     458,463,000.0
	[ol] Accounts Payable Current                                         54,742,000.0
	[ol] Deferred Revenue Current                                        399,572,000.0
	[fl] Long Term Debt And Capital Lease Obligations                  1,511,553,000.0
	[ol] Deferred Revenue Noncurrent                                      43,826,000.0
	[ol] Accrued Restructuring Noncurrent                                  7,307,000.0
	[fl] Liability For Uncertain Tax Positions Noncurrent                170,721,000.0
	[fl] Deferred Tax Liabilities Noncurrent                             120,756,000.0
	[ol] Other Liabilities Noncurrent                                     44,922,000.0
	[cse] Treasury Stock Value                                        -3,178,769,000.0
	[cse] Accumulated Other Comprehensive Income Loss Net Of Tax          28,695,000.0
	[cse] Retained Earnings Accumulated Deficit                        6,045,631,000.0
	[cse] Additional Paid In Capital                                   2,529,789,000.0
	[cse] Common Stock Value                                                  61,000.0
	[fl] Preferred Stock Value                                                     0.0
	Total                                                              8,310,024,000.0

    Net Operational Assets
	OA                                                                 5,399,022,000.0
	OL                                                                -1,024,491,000.0
	Total                                                              4,374,531,000.0

    Net Financial Assets
	FA                                                                 2,911,002,000.0
	FL                                                                -1,860,126,000.0
	Total                                                              1,050,876,000.0

    Common Shareholders' Equity
	NOA                                                                4,374,531,000.0
	NFA                                                                1,050,876,000.0
	Total                                                              5,425,407,000.0

    Income Statement (2010-12-04 to 2011-03-04)
    Net Income (Loss) Attributable to Parent (loc_NetIncomeLoss_0)
	[or] Sales Revenue Goods Net                                         842,689,000.0
	[or] Sales Revenue Services Net                                       78,846,000.0
	[or] Subscription Revenue                                            106,171,000.0
	[cogs] Cost Of Goods Sold                                            -30,717,000.0
	[cogs] Cost Of Services                                              -29,044,000.0
	[cogs] Cost Of Goods Sold Subscription                               -47,878,000.0
	[oe] Research And Development Expense Software Excluding ...        -178,400,000.0
	[oe] Selling And Marketing Expense                                  -328,078,000.0
	[oe] General And Administrative Expense                             -100,979,000.0
	[oibt] Restructuring Charges                                             -41,000.0
	[oibt] Amortization Of Intangible Assets                             -10,235,000.0
	[fibt] Other Nonoperating Income                                        -817,000.0
	[fibt] Interest Expense                                              -17,020,000.0
	[fibt] Gain Loss On Investments                                        1,590,000.0
	[tax] Income Tax Expense Benefit                                     -51,496,000.0
	Total                                                                234,591,000.0

    Gross Revenue
	Operating Revenues (OR)                                            1,027,706,000.0
	Cost of Goods Sold (COGS)                                           -107,639,000.0
	Total                                                                920,067,000.0

    Operating Income from sales, before tax (OISBT)
	Gross Margin (GM)                                                    920,067,000.0
	Operating Expense (OE)                                              -607,457,000.0
	Total                                                                312,610,000.0

    Operating Income from sales, after tax (OISAT)
	Operating income from sales (before tax)                             312,610,000.0
	Reported taxes                                                       -51,496,000.0
	Taxes on net financing income                                         -5,686,450.0
	Taxes on other operating income                                       -3,596,600.0
	Total                                                                251,830,950.0

    Operating income, after tax (OI)
	Operating income after sales, after tax (OISAT)                      251,830,950.0
	Other operating income, before tax (OIBT)                            -10,276,000.0
	Tax on other operating income                                          3,596,600.0
	Other operating income, after tax (OOIAT)                                      0.0
	Total                                                                245,151,550.0

    Net financing income, after tax (NFI)
	Financing income, before tax (FIBT)                                  -16,247,000.0
	Tax effect (FIBT_TAX_EFFECT)                                           5,686,450.0
	Financing income, after tax (FIAT)                                             0.0
	Total                                                                -10,560,550.0

    Comprehensive (CI)
	Operating income, after tax (OI)                                     245,151,550.0
	Net financing income, after tax (NFI)                                -10,560,550.0
	Total                                                                234,591,000.0

    Cash Flow Statement (2010-12-04 to 2011-03-04)
    Cash and Cash Equivalents, Period Increase (Decrease) (loc_CashAndCashEquivalentsPeriodIncreaseDecrease_2)
	[c] Adjustments Noncash Items To Reconcile Net Income Los...           2,703,000.0
	[c] Net Income Loss                                                  234,591,000.0
	[c] Depreciation And Amortization                                     66,286,000.0
	[c] Share Based Compensation                                          70,992,000.0
	[c] Deferred Income Taxes And Tax Credits                             28,645,000.0
	[c] Unrealized Gain Loss On Investments                               -1,330,000.0
	[c] Increase Decrease In Receivables                                  20,605,000.0
	[c] Increase Decrease In Prepaid Deferred Expense And Oth...          -2,716,000.0
	[c] Increase Decrease In Accounts Payable                              2,310,000.0
	[c] Increase Decrease In Accrued Liabilities                        -110,084,000.0
	[c] Other Increase Decrease In Provision For Restructuring            -2,526,000.0
	[c] Increase Decrease In Accrued Income Taxes Payable                  8,905,000.0
	[c] Increase Decrease In Deferred Revenue                             13,721,000.0
	[d] Purchases Long Term Investments Other Assets                      -5,389,000.0
	[i] Payments To Acquire Short Term Investments                      -375,077,000.0
	[d] Proceeds From Maturities Of Short Term Investments               134,296,000.0
	[i] Proceeds From Sale Of Short Term Investments                     217,407,000.0
	[i] Payments To Acquire Property Plant And Equipment                 -32,421,000.0
	[i] Payments To Acquire Businesses Net Of Cash Acquired              -36,572,000.0
	[d] Proceeds From Sale Of Available For Sale Securities E...           2,755,000.0
	[i] Payments For Proceeds From Other Investing Activities               -124,000.0
	[f] Payments For Repurchase Of Common Stock                         -125,000,000.0
	[f] Proceeds From Sale Of Treasury Stock                              40,651,000.0
	[d] Repayments Of Long Term Debt And Capital Securities               -2,169,000.0
	[d] Effect Of Exchange Rate On Cash And Cash Equivalents                -194,000.0
	Total                                                                150,265,000.0

    Cash from operations
	[c] Adjustments Noncash Items To Reconcile Net Income Los...           2,703,000.0
	[c] Net Income Loss                                                  234,591,000.0
	[c] Depreciation And Amortization                                     66,286,000.0
	[c] Share Based Compensation                                          70,992,000.0
	[c] Deferred Income Taxes And Tax Credits                             28,645,000.0
	[c] Unrealized Gain Loss On Investments                               -1,330,000.0
	[c] Increase Decrease In Receivables                                  20,605,000.0
	[c] Increase Decrease In Prepaid Deferred Expense And Oth...          -2,716,000.0
	[c] Increase Decrease In Accounts Payable                              2,310,000.0
	[c] Increase Decrease In Accrued Liabilities                        -110,084,000.0
	[c] Other Increase Decrease In Provision For Restructuring            -2,526,000.0
	[c] Increase Decrease In Accrued Income Taxes Payable                  8,905,000.0
	[c] Increase Decrease In Deferred Revenue                             13,721,000.0
	Total                                                                332,102,000.0

    Cash investments in operations
	[i] Payments To Acquire Short Term Investments                      -375,077,000.0
	[i] Proceeds From Sale Of Short Term Investments                     217,407,000.0
	[i] Payments To Acquire Property Plant And Equipment                 -32,421,000.0
	[i] Payments To Acquire Businesses Net Of Cash Acquired              -36,572,000.0
	[i] Payments For Proceeds From Other Investing Activities               -124,000.0
	Total                                                               -226,787,000.0

    Payments to debtholders
	[d] Purchases Long Term Investments Other Assets                      -5,389,000.0
	[d] Proceeds From Maturities Of Short Term Investments               134,296,000.0
	[d] Proceeds From Sale Of Available For Sale Securities E...           2,755,000.0
	[d] Repayments Of Long Term Debt And Capital Securities               -2,169,000.0
	[d] Effect Of Exchange Rate On Cash And Cash Equivalents                -194,000.0
	[d] Investment in Cash and Equivalents                              -150,265,000.0
	Total                                                                -20,966,000.0

    Payments to stockholders
	[f] Payments For Repurchase Of Common Stock                         -125,000,000.0
	[f] Proceeds From Sale Of Treasury Stock                              40,651,000.0
	Total                                                                -84,349,000.0

    Free Cash Flow
	Cash from Operations (C)                                             332,102,000.0
	Cash Investment in Operations (I)                                   -226,787,000.0
	Total                                                                105,315,000.0

    Financing Flows
	Payments to debtholders (d)                                          -20,966,000.0
	Payments to stockholders (F)                                         -84,349,000.0
	Total                                                               -105,315,000.0

