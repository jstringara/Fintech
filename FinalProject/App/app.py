import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import pickle

# https://www.webfx.com/tools/emoji-cheat-sheet/
st.set_page_config(
    page_title="PortFolio replication",
    page_icon=":chart_with_upwards_trend:",
    layout="wide"
)
BASEDIR = 'FinalProject/App/'

#> Header <#
st.title("PortFolio replication")
st.write(
"""This is a tool to explore your portfolio replication options using
Futures available on the market. \n
If you want more information about the tool, please visit our [GitHub](
https://github.com/jstringara/Fintech) page."""
)

#> Futures Presentation <#
st.write("---")
st.write("## Futures")
st.write(
"""Here is a rundown of the futures that we used in our study:
- **RX1**: Fixed-income security issued by the Federal Republic of Germany.
It is considered a benchmark bond and is widely regarded as one of the safest
and most liquid government bonds. It's highly liquid, supported by active
trading, high trading volumes, and the presence of market makers.
- **CO1**: Price of Brent crude oil in the financial markets. It's a benchmark
for global oil prices. The price of Brent crude oil can be volatile due to
various factors.
- **DU1**: The German 2-year government bond, known as the "Schatz." It has a
maturity of 2 years. It's considered to be a Safe Haven asset and it is a
relatively liquid instrument.
- **ES1**: It represents a broad-based stock market index of 500 large companies
listed on U.S. stock exchanges. The S&P 500 provides diversification by
including a large number of stocks from different sectors and industries. This
diversification helps spread risk across multiple companies and industries.
- **GC1**: Price of gold. Gold is widely recognized as a store of value. It's a
safe haven asset, particularly during times of economic uncertainty or market
volatility. Investors tend to turn to gold as a hedge against inflation,
currency fluctuations, and geopolitical risks. Gold can have sharp price
movements in response to global events and market conditions. Gold is frequently
used as a diversification tool in investment portfolios. Its low correlation
with other asset classes, such as stocks and bonds, can help reduce overall
portfolio risk.
- **NQ1**: The Nasdaq 100 index. The Nasdaq 100 is an index that primarily
focuses on the technology sector. It includes a wide range of technology-related
companies. The Nasdaq 100 includes 100 of the largest non-financial companies
listed on the Nasdaq stock exchange. These companies are typically
well-established and have significant market capitalization.
- **TP1**: It's associated with the Topix index. The Topix index represents the
overall performance of the Japanese equity market. It is a broad-based stock
market index that includes a wide range of companies listed on the Tokyo Stock
Exchange (TSE).The Topix provides diversification by including companies from
various sectors and industries within the Japanese equity market. Investing in
the Topix provides exposure to the Japanese economy, which is one of the largest
economies globally.
- **TU2**: It refers to the 2-year US Treasury bond. The 2-year US Treasury bond
is a debt security issued by the United States government to finance its
operations and obligations. It is backed by the full faith and credit of the US
government, making it a relatively low-risk investment. It is a fixed income
instrument. US Treasury bonds are considered to be virtually risk-free due to
the creditworthiness of the US government. They are often used as a benchmark
for risk-free interest rates in financial markets.
- **TY1**: 10-years US Treasury bond, it's a debt security issued by the United
States government to finance its operations and obligations. It is backed by the
full faith and credit of the US government, making it a relatively low-risk
investment. US Treasury bonds are considered to be virtually risk-free due to
the creditworthiness of the US government. They are often used as a benchmark
for risk-free interest rates in financial markets. The US government actively
supports the liquidity of its debt securities, ensuring there is a robust market
for investors to transact. It's a Safe Haven Asset. 
- **VG1**: Euro Stoxx 50 index. The Euro Stoxx 50 index represents the
performance of the 50 largest and most liquid stocks across 12 Eurozone
countries. It is a widely recognized benchmark for the European equity market.
The Euro Stoxx 50 includes blue-chip companies that are considered leaders in
their respective industries. These companies are typically well-established,
large-cap entities with significant market capitalization. Market conditions and
factors specific to the European economy can contribute to fluctuations in the
index's performance."""
)

#> Futures Selection <#
st.write("---")
st.write("## Futures Selection")
st.write(
"""For your convenience, we have pre-selected three groups of futures for you to
tinker with.
- **Base Futures**: This group contains all the futures that we used in our
study and it will give you the most diversified portfolio. Furthermore, this
comprehensive approach will enable you to capitalize on opportunities in
different sector and geographic regions. You certainly can't go wrong with this.
- **Sure-Fire Futures**: This group contains the futures that we found to have
the lowest volatility. It is comprized of RX1, DU1, GC1, TU2, VG1 and ES1. This
selection of government bonds, gold and equities from different regions provides
a strong foundation for risk management and potential returns. Moreover, the
portfolio benefits from the lilquidity of the selected futures, allowing for
efficient rebalancing. We recommend this portfolio if you are looking for a
stable, low-risk portfolio.
- **Dark Horse Futures**: This group contains the futures that we found to have
the highest volatility. It is comprized of ES1, NQ1, TP1, GC1, CO1, VG1, TY1 and
RX1. This selection of equities from Japan, the US and the EU and Gold with just
a touch of short-term bonds provides exposure to major American, Asian and EU
markets as well as safe haven assets such as gold and short-term bonds. This
selection combines the potential for high returns with the potential for high
volatility. It is a high-risk, high-reward portfolio. Use at your own risk."""
)

@st.cache_data
def load_data():
    # load the futures normalized
    futures_norm = pd.read_csv(BASEDIR+'futures_norm.csv', index_col=0)

    # load the monster index
    target_norm = pd.read_csv(BASEDIR+'target_norm.csv', index_col=0)

    return futures_norm, target_norm

# load the data
futures_norm, target_norm = load_data()

# create the groups of futures
surefire_futures = [ "RX1", "DU1", "GC1", "TU2", "TY1", "VG1", "ES1"]
surefire_futures = futures_norm[surefire_futures]

daring_futures = [ "ES1", "NQ1", "TP1", "GC1", "DU1", "VG1", "TY1", "RX1"]
daring_futures = futures_norm[daring_futures]

# select the approach
approach = st.radio(
    "Select the approach you want to use to replicate your portfolio",
    ("Base", "Sure-Fire", "Dark Horse")
)

# show the graph based on the approach
plot_futures = st.empty()

# create the fig based on the selection
if approach == "Base":
    # plot all the futures
    fig = plt.figure(figsize=(10, 5))
    futures_norm.plot(ax=plt.gca())
    plt.legend(loc='best')
    plt.title("Base Futures")
    plt.xlabel("Date")
    plt.ylabel("Normalized Price")
    plt.xticks(rotation=45)
    plot_futures.pyplot(fig)

elif approach == "Sure-Fire":
    fig = plt.figure(figsize=(10, 5))
    surefire_futures.plot(ax=plt.gca())
    plt.legend(loc='best')
    plt.title("Sure-Fire Futures")
    plt.xlabel("Date")
    plt.ylabel("Normalized Price")
    plt.xticks(rotation=45)
    plot_futures.pyplot(fig)

else:
    fig = plt.figure(figsize=(10, 5))
    daring_futures.plot(ax=plt.gca())
    plt.legend(loc='best')
    plt.title("Dark Horse Futures")
    plt.xlabel("Date")
    plt.ylabel("Normalized Price")
    plt.xticks(rotation=45)
    plot_futures.pyplot(fig)

#> Portfolio replication <#

st.write("---")
st.write("## Portfolio replication")

# leave empty space for the graph
pred_plot = st.empty()

# load all the models and cache them
@st.cache_data
def load_models():
    # base model (ElasticNet)
    with open(BASEDIR+"y_pred_Enet.sav", "rb") as f:
        y_pred_Enet = pickle.load(f)
    
    # sure-fire model (ElasticNet)
    with open(BASEDIR+"y_pred_Enet_Surefire.sav", "rb") as f:
        y_pred_Enet_surefire = pickle.load(f)
    
    # daring model (ElasticNet)
    with open(BASEDIR+"y_pred_Enet_Daring.sav", "rb") as f:
        y_pred_Enet_daring = pickle.load(f)
    
    return y_pred_Enet, y_pred_Enet_surefire, y_pred_Enet_daring

y_pred_Enet, y_pred_Enet_Surefire, y_pred_Enet_daring = load_models()
y = target_norm[len(futures_norm)-len(y_pred_Enet):]
dates = futures_norm.index[len(futures_norm)-len(y_pred_Enet):]

if approach == "Base":
    # show the prediction against the target
    fig = plt.figure(figsize=(10, 5))
    plt.plot(dates, y_pred_Enet, label='Prediction')
    plt.plot(dates, y, label='Target')
    plt.legend()
    plt.title("Prediction vs Target")
    plt.xlabel("Date")
    plt.ylabel("Price")
    plt.xticks(dates[::30], rotation=45)
    pred_plot.pyplot(fig)

elif approach == "Sure-Fire":
    # show the prediction against the target
    fig = plt.figure(figsize=(10, 5))
    plt.plot(dates, y_pred_Enet_Surefire, label='Prediction')
    plt.plot(dates, y, label='Target')
    plt.legend()
    plt.title("Prediction vs Target (Sure-Fire)")
    plt.xlabel("Date")
    plt.ylabel("Price")
    plt.xticks(dates[::30], rotation=45)
    pred_plot.pyplot(fig)

else:
    # show the prediction against the target
    fig = plt.figure(figsize=(10, 5))
    plt.plot(dates, y_pred_Enet_daring, label='Prediction')
    plt.plot(dates, y, label='Target')
    plt.legend()
    plt.title("Prediction vs Target (Dark Horse)")
    plt.xlabel("Date")
    plt.ylabel("Price")
    plt.xticks(dates[::30], rotation=45)
    pred_plot.pyplot(fig)

#> Portfolio evaluation <#
st.write("---")
st.write("## Portfolio evaluation")
st.write("""Here are some key metrics to evaluate the performance of your
selected portfolio.
- **MSE**: Mean Squared Error. This is the average of the squared differences
between the predicted and the actual values. The lower the better.
- **TEV**: Tracking Error Volatility. This is the standard deviation of the
differences between the predicted and the actual values. The lower the better.
- **IR**: Information Ratio. This is the ratio of the mean of the differences
between the predicted and the actual values and the standard deviation of the
differences. The higher the better.
- **MAT**: Mean Annual Turnover. This is the average of the annual turnover
of the portfolio. It is a measure of how much the portfolio changes over time.
- **MATC**: Mean Annual Trading Costs. This is the average of the annual trading
costs of the portfolio. It is a measure of how much it costs to trade the
portfolio over time."""
)

table_metrics = st.empty()

if approach == "Base":
    table_metrics.markdown("""
    | Metric | Value |
    | --- | --- |
    | MSE | 0.000177529 |
    | Tracking Error Volatility | 0.0893928 |
    | Information Ratio | -0.0546371 |
    | Mean Annual Turnover | 0.239801 |
    | Mean Annual Trading Costs | 9.59203e-05 |
    """)

elif approach == "Sure-Fire":
    table_metrics.markdown("""
    | Metric | Value |
    | --- | --- |
    | MSE | 0.0002383323353445438 |
    | Tracking Error Volatility | 0.10840432663308824 |
    | Information Ratio | -0.032407531636239786 |
    | Mean Annual Turnover | 0.23454698549080988 |
    | Mean Annual Trading Costs | 9.381879419632396e-05 |
    """)

else:
    # table with the metrics
    
    table_metrics.markdown("""
    | Metric | Value |
    | --- | --- |
    | MSE | 0.00023566504919694437 |
    | Tracking Error Volatility | 0.10264704190340922 |
    | Information Ratio | -0.05599956074047027 |
    | Mean Annual Turnover | 0.3123969643683995 |
    | Mean Annual Trading Costs | 0.0001249587857473598 |
    """)
