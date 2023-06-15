import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
import pickle

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
data = pd.read_csv("FinalProject/InvestmentReplica.csv")

# construct the list of futures and indexes
indexes_list = ['MXWO','MXWD','LEGATRUU','HFRXGL']
futures_list = ['RX1','TY1','GC1','CO1','ES1','VG1',
    'NQ1','LLL1','TP1','DU1', 'TU2' ]

indexes = data[indexes_list]
base_futures = data[futures_list]

# create the groups of futures
surefire_futures = [ "RX1", "DU1", "GC1", "TU2", "TY1", "VG1", "ES1"]
surefire_futures = base_futures[surefire_futures]

daring_futures = [ "ES1", "NQ1", "TP1", "GC1", "DU1", "VG1", "LLL1", "TY1",
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
    plt.plot(base_futures)
    plt.legend(base_futures.columns)
    plt.title("Base Futures")
    plt.xlabel("Time")
    plt.ylabel("Price")
    plot_futures.pyplot(fig)
elif approach == "Surefire":
    fig = plt.figure(figsize=(10, 5))
    plt.plot(surefire_futures)
    plt.legend(surefire_futures.columns)
    plt.title("Surefire Futures")
    plt.xlabel("Time")
    plt.ylabel("Price")
    plot_futures.pyplot(fig)
else:
    fig = plt.figure(figsize=(10, 5))
    plt.plot(daring_futures)
    plt.legend(daring_futures.columns)
    plt.title("Daring Futures")
    plt.xlabel("Time")
    plt.ylabel("Price")
    plot_futures.pyplot(fig)

#> Portfolio replication <#

st.write("---")
st.write("## Portfolio replication")

# load the model data
import pickle

# load the model
with open("FinalProject/ElasticNet.sav", "rb") as f:
    model = pickle.load(f)

# make the prediction
prediction = model.predict(base_futures)

# show the prediction against the target
fig = plt.figure(figsize=(10, 5))
plt.plot(prediction, label="Prediction")
plt.plot(indexes["MXWO"], label="Target")
plt.legend()
plt.title("Prediction vs Target")
plt.xlabel("Time")
plt.ylabel("Price")
st.pyplot(fig)
