import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import pickle
import numpy as np

def price2ret(x):
    return x.pct_change()

def ret2price(x):
    return (1+x).cumprod()

# https://www.webfx.com/tools/emoji-cheat-sheet/
st.set_page_config(
    page_title="PortFolio replication :chart_with_upwards_trend:",
    page_icon=":chart_with_upwards_trend:",
    layout="wide"
)

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

# load the data
data = pd.read_csv("FinalProject/InvestmentReplica.CSV")

# construct the list of futures and indexes
indexes_list = ['MXWO','MXWD','LEGATRUU','HFRXGL']
indexes = data[indexes_list]

X = data[['RX1','TY1','GC1','CO1','ES1','VG1','NQ1','LLL1','TP1','DU1','TU2']]


base_futures = X[['RX1','TY1','GC1','CO1','ES1','VG1','NQ1','TP1','DU1','TU2']]  

# create the monster index
wHFRXGL = 0.5
wMXWO = 0.25
wLEGATRUU = 0.25

y = wHFRXGL*price2ret(data.HFRXGL) + \
    wMXWO*price2ret(data.MXWO) + \
    wLEGATRUU*price2ret(data.LEGATRUU)
target = (ret2price(y))
target = target.dropna()

# create the groups of futures
surefire_futures = [ "RX1", "DU1", "GC1", "TU2", "TY1", "VG1", "ES1"]
surefire_futures = base_futures[surefire_futures]

daring_futures = [ "ES1", "NQ1", "TP1", "GC1", "DU1", "VG1", "TY1",
    "RX1"]
daring_futures = base_futures[daring_futures]

# select the approach
approach = st.radio(
    "Select the approach you want to use to replicate your portfolio",
    ("Base", "Surefire", "Daring")
)

# show the graph based on the approach
plot_futures = st.empty()

# create the fig based on the selection
if approach == "Base":
    fig = plt.figure(figsize=(10, 5))
    base_futures = price2ret(base_futures)
    base_futures = base_futures.dropna()
    plt.plot(data['Date'][1:], ret2price(base_futures.RX1), label='RX1')
    plt.plot(data['Date'][1:], ret2price(base_futures.TY1), label='TY1')
    plt.plot(data['Date'][1:], ret2price(base_futures.GC1), label='GC1')
    plt.plot(data['Date'][1:], ret2price(base_futures.CO1), label='CO1')
    plt.plot(data['Date'][1:], ret2price(base_futures.ES1), label='ES1')
    plt.plot(data['Date'][1:], ret2price(base_futures.VG1), label='VG1')
    plt.plot(data['Date'][1:], ret2price(base_futures.NQ1), label='NQ1')
    plt.plot(data['Date'][1:], ret2price(base_futures.TP1), label='TP1')
    plt.plot(data['Date'][1:], ret2price(base_futures.DU1), label='DU1')
    plt.plot(data['Date'][1:], ret2price(base_futures.TU2), label='TU2')
    plt.title('base_futures')
    plt.xlabel('Date')
    plt.ylabel('Price')
    plt.legend()
    plt.xticks(data['Date'][1::30], rotation=45)
    plot_futures.pyplot(fig)
    base_futures = ret2price(base_futures)
elif approach == "Surefire":
    fig = plt.figure(figsize=(10, 5))
    surefire_futures = price2ret(surefire_futures)
    surefire_futures = surefire_futures.dropna()
    plt.plot(data['Date'][1:], ret2price(surefire_futures.RX1), label='RX1')
    plt.plot(data['Date'][1:], ret2price(surefire_futures.TY1), label='TY1')
    plt.plot(data['Date'][1:], ret2price(surefire_futures.GC1), label='GC1')
    plt.plot(data['Date'][1:], ret2price(surefire_futures.ES1), label='ES1')
    plt.plot(data['Date'][1:], ret2price(surefire_futures.VG1), label='VG1')
    plt.plot(data['Date'][1:], ret2price(surefire_futures.DU1), label='DU1')
    plt.plot(data['Date'][1:], ret2price(surefire_futures.TU2), label='TU2')
    plt.title('surefire_futures')
    plt.xlabel('Date')
    plt.ylabel('Price')
    plt.legend()
    plt.xticks(data['Date'][1::30], rotation=45)
    plot_futures.pyplot(fig)
    surefire_futures = ret2price(surefire_futures)
else:
    fig = plt.figure(figsize=(10, 5))
    daring_futures = price2ret(daring_futures)
    daring_futures = daring_futures.dropna()
    plt.plot(data['Date'][1:], ret2price(daring_futures.RX1), label='RX1')
    plt.plot(data['Date'][1:], ret2price(daring_futures.TY1), label='TY1')
    plt.plot(data['Date'][1:], ret2price(daring_futures.GC1), label='GC1')
    plt.plot(data['Date'][1:], ret2price(daring_futures.ES1), label='ES1')
    plt.plot(data['Date'][1:], ret2price(daring_futures.VG1), label='VG1')
    plt.plot(data['Date'][1:], ret2price(daring_futures.NQ1), label='NQ1')
    plt.plot(data['Date'][1:], ret2price(daring_futures.TP1), label='TP1')
    plt.plot(data['Date'][1:], ret2price(daring_futures.DU1), label='DU1')
    plt.title('daring_futures')
    plt.xlabel('Date')
    plt.ylabel('Price')
    plt.legend()
    plt.xticks(data['Date'][1::30], rotation=45)
    plot_futures.pyplot(fig)
    daring_futures = ret2price(daring_futures)

#> Portfolio replication <#

st.write("---")
st.write("## Portfolio replication")

# load the model data
import pickle

if approach == "Base":
    # load the model
    with open("FinalProject/App/y_pred_Enet.sav", "rb") as f:
        y_pred_Enet = pickle.load(f)

    # show the prediction against the target
    fig = plt.figure(figsize=(10, 5))
    plt.plot(data['Date'][len(base_futures)-len(y_pred_Enet)+1:], y_pred_Enet, label='prediction')
    plt.plot(data['Date'][len(base_futures)-len(y_pred_Enet)+1:], target[len(base_futures)-len(y_pred_Enet):], label='target')
    plt.legend()
    plt.title("Prediction vs Target")
    plt.xlabel("Date")
    plt.ylabel("Price")
    plt.xticks(data['Date'][len(X)-len(y_pred_Enet)+1::30], rotation=45)
    st.pyplot(fig)
elif approach == "Surefire":
    # load the model
    with open("FinalProject/App/y_pred_Enet_Surefire.sav", "rb") as f:
        y_pred_Enet = pickle.load(f)

    # show the prediction against the target
    fig = plt.figure(figsize=(10, 5))
    plt.plot(data['Date'][len(surefire_futures)-len(y_pred_Enet)+1:], y_pred_Enet, label='prediction')
    plt.plot(data['Date'][len(surefire_futures)-len(y_pred_Enet)+1:], target[len(surefire_futures)-len(y_pred_Enet):], label='target')
    plt.legend()
    plt.title("Prediction vs Target")
    plt.xlabel("Date")
    plt.ylabel("Price")
    plt.xticks(data['Date'][len(X)-len(y_pred_Enet)+1::30], rotation=45)
    st.pyplot(fig)
else:
    # load the model
    with open("FinalProject/App/y_pred_Enet_Daring.sav", "rb") as f:
        y_pred_Enet = pickle.load(f)

    # show the prediction against the target
    fig = plt.figure(figsize=(10, 5))
    plt.plot(data['Date'][len(daring_futures)-len(y_pred_Enet)+1:], y_pred_Enet, label='prediction')
    plt.plot(data['Date'][len(daring_futures)-len(y_pred_Enet)+1:], target[len(daring_futures)-len(y_pred_Enet):], label='target')
    plt.legend()
    plt.title("Prediction vs Target")
    plt.xlabel("Date")
    plt.ylabel("Price")
    plt.xticks(data['Date'][len(X)-len(y_pred_Enet)+1::30], rotation=45)
    st.pyplot(fig)



