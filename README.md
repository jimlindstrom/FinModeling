## Overview

FinModeling is an equity valuation framework. It can retrieve and parse [XBRL](http://en.wikipedia.org/wiki/XBRL)-based filings from SEC Edgar. As of March 2013, it can successfully parse the last 2-5 years of quarterly and annual filings from 52% of the Nasdaq 100 companies. (The remainder fail due to a long-tail distribution of filing formatting peculiarities for which I haven't yet written special-case code to handle.)

## Features

- Pulls annual (10-k) and quarterly (10-q) financial reports from SEC Edgar
- Uses Naive Bayes Classifiers to classify financial statement items
  - trained on medium-to-large NASDAQ tech companies
- Reformulates GAAP statements to better highlight enterprise value
- Generates forecasts based on analysis of historical performance
- Calculates cost of capital using either [CAPM](http://en.wikipedia.org/wiki/Capital_asset_pricing_model) or [Fama/French](http://en.wikipedia.org/wiki/Fama%E2%80%93French_three-factor_model) cost of equity, and [WACC](http://en.wikipedia.org/wiki/Weighted_average_cost_of_capital)
- Performs residual operating income-based valuation.

## Installation

    brew install gsl        # Install the GNU Scientific Library (a non-ruby dependency)
    gem install finmodeling # Install this gem from RubyGems.

## Example 1: Valuing Oracle's Common Equity, Based on 4 Quarters of History and 2 Quarters of Forecasts

    $ ./examples/show_reports.rb --num-forecasts 2 --do-valuation orcl 2012-02-01
    Forecasting 2 periods
    Doing valuation
    company name: ORACLE CORP

    	                      2012-02-29    2012-05-31    2012-08-31    2012-11-30   2013-02-28E   2013-05-28E
    	NOA ($MM)               29,250.0      32,172.0      29,172.0      31,703.0      31,072.0      33,307.0
    	NFA ($MM)               14,016.0      11,915.0      14,564.0      11,707.0      14,672.0      15,375.0
    	Minority Interest          393.0         399.0         407.0         427.0           0.0           0.0
    	 ($MM)
    	CSE ($MM)               42,873.0      43,688.0      43,329.0      42,983.0      45,743.0      48,682.0
    	Composition Ratio         2.0869        2.7001        2.0030        2.7080        2.1177        2.1663
    	NOA Growth                              0.4590       -0.3218        0.3961       -0.0783        0.3296
    	CSE Growth                              0.0775       -0.0322       -0.0316        0.2871        0.2909


    	                      2012-02-29    2012-05-31    2012-08-31    2012-11-30   2013-02-28E   2013-05-28E
    	Revenue ($MM)            9,039.0      10,916.0       8,181.0       9,094.0       9,748.0      10,450.0
    	Core OI ($MM)            2,674.0       3,636.0       2,076.0       2,712.0       2,870.0       3,076.0
    	OI ($MM)                 2,608.0       3,590.0       2,149.0       2,705.0
    	FI ($MM)                  -110.0        -138.0        -115.0        -124.0        -110.0        -137.0
    	NI ($MM)                 2,498.0       3,452.0       2,034.0       2,581.0       2,760.0       2,939.0
    	Gross Margin              0.6008        0.6238        0.5941        0.6077
    	Sales PM                  0.2958        0.3330        0.2537        0.2981        0.2943        0.2943
    	Operating PM              0.2885        0.3288        0.2626        0.2974
    	FI / Sales               -0.0121       -0.0126       -0.0140       -0.0136       -0.0112       -0.0131
    	NI / Sales                0.2763        0.3162        0.2486        0.2838        0.2831        0.2812
    	Sales / NOA                             1.4806        1.0199        1.2642        1.2610        1.3949
    	FI / NFA                               -0.0390       -0.0387       -0.0345       -0.0383       -0.0388
    	Revenue Growth                          1.1139       -0.6815        0.5286        0.3254        0.3296
    	Core OI Growth                          2.3835       -0.8918        1.9216        0.2582        0.3296
    	OI Growth                               2.5532       -0.8693        1.5169
    	ReOI ($MM)                             2,879.0       1,367.0       2,004.0       2,116.0       2,346.0


    	                      Unknown...    2012-05-31    2012-08-31    2012-11-30
    	C ($MM)                                4,057.0       5,431.0         677.0
    	I ($MM)                              -10,966.0      -7,304.0     -11,021.0
    	d ($MM)                                9,358.0       4,662.0      13,363.0
    	F ($MM)                               -2,449.0      -2,789.0      -3,019.0
    	FCF ($MM)                             -6,909.0      -1,873.0     -10,344.0
    	NI / C                                  0.8508        0.3745        3.8124

    Cost of Capital
    	                      2013-03-10
    	Market Value of        169,100.0
    	 Equity ($MM)
    	Market Value of         23,663.0
    	 Debt ($MM)
    	Cost of Equity (%)          7.30
    	Cost of Debt (%)            3.20
    	Weighted Avg Cost           6.79
    	 of Capital (%)

    ReOI Valuation
    	                      2012-11-30    2013-02-28   2013-05-28E
    	ReOI ($MM)                             2,352.0       2,574.0
    	PV(ReOI) ($MM)                         2,356.0
    	CV ($MM)                              37,886.0
    	PV(CV) ($MM)                          37,954.0
    	Book Value of           42,983.0
    	 Common Equity
    	 ($MM)
    	Enterprise Value        83,293.0
    	 ($MM)
    	NFA ($MM)               11,707.0
    	Value of Common         95,000.0
    	 Equity ($MM)
    	# Shares (MM)            4,735.0
    	Value / Share ($)          20.06

## Example 2: More Detailed Analysis of Apple's Financials Since 2012-02-01

    $ ./examples/show_reports.rb --balance-detail --income-detail --show-regressions aapl 2012-02-01
    Balance sheet detail is enabled
    Net income detail is enabled
    Showing regressions
    company name: APPLE INC

    	                      2012-03-31    2012-06-30    2012-09-29    2012-12-29
    	A ($MM)                150,934.0     162,896.0     176,064.0     196,088.0
    	L ($MM)                 48,436.0      51,150.0      57,854.0      68,742.0
    	NOA ($MM)               -9,931.0      -7,784.0      -5,624.0     -12,661.0
    	OA ($MM)                38,505.0      43,366.0      52,230.0      56,081.0
    	OL ($MM)                48,436.0      51,150.0      57,854.0      68,742.0
    	NFA ($MM)              112,429.0     119,530.0     123,834.0     140,007.0
    	FA ($MM)               112,429.0     119,530.0     123,834.0     140,007.0
    	FL ($MM)                     0.0           0.0           0.0           0.0
    	Minority Interest            0.0           0.0           0.0           0.0
    	 ($MM)
    	CSE ($MM)              102,498.0     111,746.0     118,210.0     127,346.0
    	Composition Ratio        -0.0883       -0.0651       -0.0454       -0.0904
    	NOA Δ ($MM)                            2,147.0       2,160.0      -7,037.0
    	CSE Δ ($MM)                            9,248.0       6,464.0       9,136.0
    	NOA Growth                             -0.6235       -0.7284       24.9157
    	CSE Growth                              0.4140        0.2530        0.3479

    		NOA growth: a:-4.9150, b:12.7696, r:0.8642, var:145.5436

    	                      2012-03-31    2012-06-30    2012-09-29    2012-12-29
    	Revenue ($MM)           39,186.0      35,023.0      35,966.0      54,512.0
    	COGS ($MM)             -20,622.0     -20,029.0     -21,565.0     -33,452.0
    	GM ($MM)                18,564.0      14,994.0      14,401.0      21,060.0
    	OE ($MM)                -3,180.0      -3,421.0      -3,457.0      -3,850.0
    	OISBT ($MM)             15,384.0      11,573.0      10,944.0      17,210.0
    	Core OI ($MM)           11,526.0       8,637.0       8,256.0      12,778.0
    	OI ($MM)                11,526.0       8,637.0       8,256.0      12,778.0
    	FI ($MM)                    96.0         187.0         -33.0         300.0
    	NI ($MM)                11,622.0       8,824.0       8,223.0      13,078.0
    	Gross Margin              0.4737        0.4281        0.4004        0.3863
    	Sales PM                  0.2941        0.2466        0.2295        0.2344
    	Operating PM              0.2941        0.2466        0.2295        0.2344
    	FI / Sales                0.0024        0.0053       -0.0009        0.0055
    	NI / Sales                0.2965        0.2519        0.2286        0.2399
    	Sales / NOA                           -14.3024      -18.5327      -39.3094
    	FI / NFA                                0.0067       -0.0011        0.0098
    	Revenue Growth                         -0.3626        0.1124        4.3013
    	Core OI Growth                         -0.6856       -0.1653        4.7648
    	OI Growth                              -0.6856       -0.1653        4.7648
    	ReOI ($MM)                             8,876.0       8,443.0      12,913.0

    		operating pm: a:0.2806, b:-0.0196, r:-0.8581, var:0.0006
    		sales / noa: a:-11.5447, b:-12.5035, r:-0.9341, var:119.4351
    		revenue growth: a:-0.9816, b:2.3320, r:0.9085, var:4.3917
    		fi / nfa: a:0.0036, b:0.0015, r:0.2729, var:2.1244e-05

    	                      Unknown...    2012-06-30    2012-09-29    2012-12-29
    	C ($MM)                               10,189.0       9,136.0      23,426.0
    	I ($MM)                               -2,971.0      -3,493.0      -2,791.0
    	d ($MM)                               -7,163.0      -6,109.0     -18,631.0
    	F ($MM)                                  -55.0         466.0      -2,004.0
    	FCF ($MM)                              7,218.0       5,643.0      20,635.0
    	NI / C                                  0.8660        0.9000        0.5582

## Example 3: Raw Numbers From Nike's Last 10-Q, Including Disclosures

    $ ./examples/show_report.rb --show-disclosures NKE 10-q 0
    Showing disclosures
    company name: NIKE INC
    url:          http://www.sec.gov/Archives/edgar/data/320187/000119312513008172/0001193125-13-008172-index.htm
    Balance Sheet (2012-11-30)
    Assets (us-gaap_Assets_1)
    	[fa] Cash And Cash Equivalents At Carrying Value                 2,291,000,000.0
    	[fa] Available For Sale Securities Current                       1,234,000,000.0
    	[oa] Accounts Receivable Net Current                             3,188,000,000.0
    	[oa] Inventory Finished Goods Net Of Reserves                    3,318,000,000.0
    	[fa] Deferred Tax Assets Net Current                               327,000,000.0
    	[oa] Prepaid Expense And Other Assets Current                      733,000,000.0
    	[oa] Assets Of Disposal Group Including Discontinued               344,000,000.0
    	 Operation Current
    	[oa] Property Plant And Equipment Gross                          5,310,000,000.0
    	[oa] Accumulated Depreciation Depletion And Amortization        -3,052,000,000.0
    	 Property Plant And Equipment
    	[oa] Intangible Assets Net Excluding Goodwill                      374,000,000.0
    	[oa] Goodwill                                                      131,000,000.0
    	[fa] Deferred Income Taxes And Other Assets Noncurrent             973,000,000.0
    	Total                                                           15,171,000,000.0

    Liabilities And Stockholders Equity (us-gaap_LiabilitiesAndStockholdersEquity_1)
    	[fl] Long Term Debt Current                                         58,000,000.0
    	[fl] Short Term Borrowings                                         100,000,000.0
    	[ol] Accounts Payable Current                                    1,519,000,000.0
    	[ol] Accrued Liabilities Current                                 1,879,000,000.0
    	[fl] Accrued Income Taxes Current                                   45,000,000.0
    	[ol] Liabilities Of Disposal Group Including Discontinued          198,000,000.0
    	 Operation Current
    	[fl] Long Term Debt Noncurrent                                     170,000,000.0
    	[fl] Deferred Income Taxes And Other Liabilities Noncurrent      1,188,000,000.0
    	[ol] Commitments And Contingencies                                           0.0
    	[fl] Temporary Equity Carrying Amount Attributable To Parent                 0.0
    	[cse] Stockholders Equity                                       10,014,000,000.0
    	Total                                                           15,171,000,000.0

    Net Operational Assets
    	OA                                                              10,346,000,000.0
    	OL                                                              -3,596,000,000.0
    	Total                                                            6,750,000,000.0

    Net Financial Assets
    	FA                                                               4,825,000,000.0
    	FL                                                              -1,561,000,000.0
    	Total                                                            3,264,000,000.0

    Common Shareholders' Equity
    	NOA                                                              6,750,000,000.0
    	NFA                                                              3,264,000,000.0
    	MI                                                                          -0.0
    	Total                                                           10,014,000,000.0

    Income Statement (2012-09-01 to 2012-11-30)
    Net Income Loss (us-gaap_NetIncomeLoss_3)
    	[or] Sales Revenue Net                                           5,955,000,000.0
    	[cogs] Cost Of Goods Sold                                       -3,425,000,000.0
    	[oe] Marketing And Advertising Expense                            -613,000,000.0
    	[oe] General And Administrative Expense                         -1,223,000,000.0
    	[fibt] Interest Income Expense Nonoperating Net                      1,000,000.0
    	[fibt] Other Nonoperating Income Expense                            17,000,000.0
    	[tax] Income Tax Expense Benefit                                  -191,000,000.0
    	[fiat] Income Loss From Discontinued Operations Net Of Tax        -137,000,000.0
    	Total                                                              384,000,000.0

    Gross Revenue
    	Operating Revenues (OR)                                          5,955,000,000.0
    	Cost of Goods Sold (COGS)                                       -3,425,000,000.0
    	Total                                                            2,530,000,000.0

    Operating Income from sales, before tax (OISBT)
    	Gross Margin (GM)                                                2,530,000,000.0
    	Operating Expense (OE)                                          -1,836,000,000.0
    	Total                                                              694,000,000.0

    Operating Income from sales, after tax (OISAT)
    	Operating income from sales (before tax)                           694,000,000.0
    	Reported taxes                                                    -191,000,000.0
    	Taxes on net financing income                                        6,300,000.0
    	Taxes on other operating income                                              0.0
    	Total                                                              509,300,000.0

    Operating income, after tax (OI)
    	Operating income after sales, after tax (OISAT)                    509,300,000.0
    	Other operating income, before tax (OIBT)                                    0.0
    	Tax on other operating income                                               -0.0
    	Other operating income, after tax (OOIAT)                                    0.0
    	Total                                                              509,300,000.0

    Net financing income, after tax (NFI)
    	Financing income, before tax (FIBT)                                 18,000,000.0
    	Tax effect (FIBT_TAX_EFFECT)                                        -6,300,000.0
    	Financing income, after tax (FIAT)                                -137,000,000.0
    	Total                                                             -125,300,000.0

    Comprehensive income (CI)
    	Operating income, after tax (OI)                                   509,300,000.0
    	Net financing income, after tax (NFI)                             -125,300,000.0
    	Total                                                              384,000,000.0

    WARNING: cash flow statement period is nil!
    WARNING: reformulated cash flow statement period is nil!
    Disclosures
    Disclosure Identifiable Intangible Asset Balances (http://www.nikeinc.com/taxonomy/role/DisclosureIdentifiableIntangibleAssetBalances)
    	Finite Lived Intangible Assets Gross                               169,000,000.0
    	Finite Lived Intangible Assets Accumulated Amortization             78,000,000.0
    	Indefinite Lived Trademarks                                        283,000,000.0
    	Total                                                              530,000,000.0

    Disclosure Accrued Liabilities (http://www.nikeinc.com/taxonomy/role/DisclosureAccruedLiabilities)
    	Accrued Compensation And Benefits Excluding Taxes Current          502,000,000.0
    	Accrued Taxes Other Than Income Taxes Current                      238,000,000.0
    	Accrued Endorsement Liabilities Current                            212,000,000.0
    	Dividends Payable Current                                          188,000,000.0
    	Accrued Marketing Costs Current                                    137,000,000.0
    	Accrued Import And Logistics Costs Current                         124,000,000.0
    	Derivative Liabilities Current                                      83,000,000.0
    	Other Accrued Liabilities Current                                  395,000,000.0
    	Total                                                            1,879,000,000.0

    Disclosure Financial Assets And Liabilities Measured At Fair Value On Recurring Basis (http://www.nikeinc.com/taxonomy/role/DisclosureFinancialAssetsAndLiabilitiesMeasuredAtFairValueOnRecurringBasis)
    	Derivative Fair Value Of Derivative Asset                          129,000,000.0
    	Total                                                              129,000,000.0

    Disclosure Reconciliation From Basic Earnings Per Share To Diluted Earnings Per Share (http://www.nikeinc.com/taxonomy/role/DisclosureReconciliationFromBasicEarningsPerShareToDilutedEarningsPerShare)
    	Income Loss From Continuing Operations Per Basic Share                      0.58
    	Income Loss From Discontinued Operations Net Of Tax Per                    -0.15
    	 Basic Share
    	Income Loss From Continuing Operations Per Diluted Share                    0.57
    	Income Loss From Discontinued Operations Net Of Tax Per                    -0.15
    	 Diluted Share
    	Weighted Average Number Of Shares Outstanding Basic                897,000,000.0
    	Incremental Common Shares Attributable To Share Based               16,100,000.0
    	 Payment Arrangements
    	Total                                                             913,100,000.85

    Disclosure Components Of Assets And Liabilities Classified As Held For Sale (http://www.nikeinc.com/taxonomy/role/DisclosureComponentsOfAssetsAndLiabilitiesClassifiedAsHeldForSale)
    	Disposal Group Including Discontinued Operation Accounts           129,000,000.0
    	 Notes And Loans Receivable Net
    	Disposal Group Including Discontinued Operation Inventory          130,000,000.0
    	Disposal Group Including Discontinued Operation Deferred            32,000,000.0
    	 Income Taxes And Other Assets
    	Disposal Group Including Discontinued Operation Property            53,000,000.0
    	 Plant And Equipment Net
    	Disposal Group Including Discontinued Operation Intangible                   0.0
    	 Assets Net
    	Disposal Group Including Discontinued Operation Accounts            39,000,000.0
    	 Payable
    	Disposal Group Including Discontinued Operation Accrued            127,000,000.0
    	 Liabilities
    	Disposal Group Including Discontinued Operation Deferred            32,000,000.0
    	 Income Taxes Payable And Other Liabilities
    	Total                                                              542,000,000.0

    Disclosure Information By Operating Segments (http://www.nikeinc.com/taxonomy/role/DisclosureInformationByOperatingSegments)
    	Earnings Before Interest And Taxes                                 711,000,000.0
    	Interest Income Expense Nonoperating Net                             1,000,000.0
    	Total                                                              712,000,000.0
## Installation

##### OSX Mountain Lion
- Install [Homebrew](http://brew.sh/)
- Install ImageMagick

        brew install imagemagick
- Edit gsl formula

        brew edit gsl

- Edit the file by changing:

        url 'http://ftpmirror.gnu.org/gsl/gsl-1.16.tar.gz'
        mirror 'http://ftp.gnu.org/gnu/gsl/gsl-1.16.tar.gz'
        sha1 '210af9366485f149140973700d90dc93a4b6213e'
    to:

        url 'http://ftpmirror.gnu.org/gsl/gsl-1.14.tar.gz'
        mirror 'http://ftp.gnu.org/gnu/gsl/gsl-1.14.tar.gz'
        sha1 'e1a600e4fe359692e6f0e28b7e12a96681efbe52'
- Install GSL

        brew install gsl
- Install FinModeling

        gem install finmodeling
- Reset Homebrew

        cd /usr/local/Cellar
        git reset --hard

##### Ubuntu 13.04
- Install ImageMagick

        apt-get install imagemagick
- Install MagickWand Development

        apt-get install libmagickwand-dev
- Install GSL

        apt-get install libgsl0-dev
- Install FinModeling

        gem install finmodeling
