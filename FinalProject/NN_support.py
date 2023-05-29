from pandas import DataFrame, Series
from typing import List, Tuple
import numpy as np
import tensorflow as tf
from keras import backend as K
from sklearn.preprocessing import StandardScaler
from tensorflow.keras.layers import Input, Dense, SimpleRNN
from tensorflow.keras.models import Model

# define the reshaping function 
def RNN_sw_preprocess(x:DataFrame, y:DataFrame, num_steps:int = 30,
    pct_split:float = 0.8) -> Tuple[Tuple[np.ndarray, np.ndarray]]:
    """
    This function preprocesses and reshapes the data for the RNN model
    for a sliding window approach.
    It first transforms the data into numpy arrays, then normalizes the data
    using a z-score transformation, then reshapes the x data into a 3D array
    of size (num_obs_used, num_steps, num_features) and the y data into a 2D
    array of size (num_obs_used, 1).
    Finally it divides the data into training and test sets.
    """

    # convert the data into numpy arrays
    x = x.values
    y = y.values

    # normalize the data using a z-score transformation
    scaler = StandardScaler()
    x = scaler.fit_transform(x)
    y = scaler.fit_transform(y.reshape(-1, 1)).reshape(-1) # monodimensional y

    # get the number of features
    num_features = x.shape[1]

    # get the number of observations
    num_obs = x.shape[0]

    # get the number of observations that will be used
    num_obs_used = num_obs - num_steps + 1

    # create the empty arrays for the x and y data
    x_data = np.zeros((num_obs_used, num_steps, num_features))
    y_data = np.zeros((num_obs_used, 1))

    # loop through the data and create the x and y data
    for i in range(num_obs_used):
        x_data[i, :, :] = x[i:i+num_steps, :]
        # account for monodimensional y
        y_data[i, :] = y[i+num_steps-1, :] if y.ndim == 2 else y[i+num_steps-1]

    # split the data into training and test sets
    # the training set is the first pct_split percent of the data
    # the test set is the remaining data
    split_index = int(pct_split * num_obs_used)
    x_train = x_data[:split_index, :, :]
    y_train = y_data[:split_index, :]
    x_test = x_data[split_index:, :, :]
    y_test = y_data[split_index:, :] 

    return x_train, y_train, x_test, y_test

# define the custom loss function
def custom_loss(y_true:np.ndarray, y_pred:np.ndarray, input_tensor:np.ndarray) \
    -> float:
    """
    This function creates a custom loss function for the neural network that
    calculates the portfolio error.
    Since the data is 3D after the sliding window transformation, while the 
    output is 2D, we must reconstruct the data to calculate the portfolio error.
    In particular for each window we multiply the last row by the weights and
    then sum the columns.
    """

    # input is 3D (batch_size, timesteps, features)
    # output is 2D (batch_size, features)
    # target is 2D (batch_size, 1)
    # in each batch we have a matrix of timesteps x features
    # we want to multiply the last row of the matrix by the weights
    # and then sum the columns
    # we can do this by multiplying the output by the input
    # the output is 2D, the input is 3D
    # we can multiply them by using the K.batch_dot function

    # extract the prices and tranform them into a 2D tensor
    # of size (batch_size, features)
    prices = K.reshape(input_tensor[:, -1, :], (-1, input_tensor.shape[2]))

    # calculate the portfolio values as the dot product of the prices and the
    # weights
    y_estim = K.batch_dot(y_pred, prices)

    # calculate the mse
    mse = K.mean(K.square(y_true - y_estim))

    return mse

def RNN_model(lookback:int, features_list:List[str]) -> Model:
    """
    Defines the model has a RNN that sees the last 30 inputs and predicts 1 step
    ahead.
    It takes the futures prices as input and outputs the weights for the
    portfolio.
    The loss function is the custom loss function defined above which is the
    mean squared error of the portfolio and the predicted target.
    To achieve it we must add the loss function to the model using the
    `add_loss` method. This method lets us add a loss that is not directly
    associated with the target (y_true, y_pred) but also with the input.
    Therefore we pass two inputs, one is the actual target and the other is the
    input tensor. The input tensor is used to calculate the portfolio weights
    and to calculate the output.
    Closely mirros the example found at:
    https://stackoverflow.com/questions/62691100/how-to-use-model-input-in-loss-function
    """

    # define the model
    # actual input layer of size lookback x features
    input1 = Input(shape=(lookback, len(features_list)))
    # hidden layer RNN with 32 units, connected to the real input
    hidden = SimpleRNN(32, activation='relu')(input1)
    # actual output, aka the weights of the portfolio, of size features
    output = Dense(len(features_list), activation='linear')(hidden) 
    # fake input, not connected to the model to feed the custom loss function
    target = Input(shape=(1,))
    # define the model
    model = Model(inputs=[input1, target], outputs=output)

    # define the custom loss function
    model.add_loss(custom_loss(target, output, input1))

    # return the model
    return model

if __name__ == "__main__":
    pass
