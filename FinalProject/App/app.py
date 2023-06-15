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
Futures available on the NSE. \n
If you want more information about the tool, please visit our [GitHub](
https://github.com/jstringara/Fintech) page."""
)

#> Futures Selection <#

st.write("---")
st.write("## Futures Selection")
st.write(
"""Please, start by selecting the type of approach you want to use to replicate
your portfolio. \n"""
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

y = wHFRXGL*price2ret(data.HFRXGL) + wMXWO*price2ret(data.MXWO) + wLEGATRUU*price2ret(data.LEGATRUU)
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



