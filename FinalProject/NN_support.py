from pandas import DataFrame, Series
from typing import List, Tuple
import numpy as np
import tensorflow as tf
from keras import backend as K
from sklearn.preprocessing import StandardScaler
from tensorflow.keras.layers import Input, Dense, SimpleRNN
from tensorflow.keras.models import Model

# create a class to implement the RNN model
class RNN_model:

    def __init__(self, lookback:int, num_features:int) -> None:
        """
        Initializes the RNN model. It takes as input the lookback period and
        the list of features to use.
        Defines the model as a RNN that sees the last `lookback` inputs and
        predicts 1 step ahead.
        It takes the futures difference as input and outputs the weights for the
        portfolio.
        The loss function is the custom loss function defined below which is the
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

        self.lookback = lookback
        self.num_features = num_features

        # create the training model
        self.createTrainModel()

    def Preprocess(self, x:DataFrame, y:DataFrame, pct_split:float = 0.8) \
        -> Tuple[Tuple[np.ndarray, np.ndarray]]:
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

        # check that the number of features is the same as the model
        if x.shape[1] != self.num_features: 
            raise ValueError( "The number of features doesnt match")

        num_obs = x.shape[0]

        # get the number of observations that will be used
        num_obs_used = num_obs - self.lookback + 1

        # create the empty arrays for the x and y data
        x_data = np.zeros((num_obs_used, self.lookback, self.num_features))
        y_data = np.zeros((num_obs_used, 1))

        # loop through the data and create the x and y data
        for i in range(num_obs_used):
            x_data[i, :, :] = x[i:i+self.lookback, :]
            # account for monodimensional y
            y_data[i, :] = y[i+self.lookback-1, :] if y.ndim == 2 \
                else y[i+self.lookback-1]

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
    def Loss(self, y_true:np.ndarray, y_pred:np.ndarray,
        input_tensor:np.ndarray) -> float:
        """
        This function creates a custom loss function for the neural network that
        calculates the portfolio error.
        Since the data is 3D after the sliding window transformation, while the 
        output is 2D, we must reconstruct the data to calculate the portfolio error.
        In particular for each window we multiply the last row by the weights and
        then sum the columns.
        Input is 3D (batch_size, timesteps, features)
        Output is 2D (batch_size, features)
        Target is 2D (batch_size, 1)
        """

        # extract the prices and tranform them into a 2D tensor
        # of size (batch_size, features)
        prices = K.reshape(input_tensor[:, -1, :], (-1, input_tensor.shape[2]))

        # calculate the portfolio values as the dot product of the prices and
        # the weights
        y_estim = K.batch_dot(y_pred, prices)

        # calculate the mse
        mse = K.mean(K.square(y_true - y_estim))

        return mse

    def createTrainModel(self) -> Model:
        """
        This function defines the training model which has and extra input
        tensor that is not connected to the model but is used to calculate the
        loss function.
        """

        # define the model
        # actual input layer of size lookback x features
        self.input1 = Input(shape=(self.lookback, self.num_features))
        # hidden layer RNN with 32 units, connected to the real input
        self.hidden = SimpleRNN(32, activation='relu')(self.input1)
        # actual output, aka the weights of the portfolio, of size features
        self.output = Dense(self.num_features, activation='linear')(self.hidden) 
        # fake input, not connected to the model to feed the custom loss function
        self.target = Input(shape=(1,))
        # define the model
        model = Model(inputs=[self.input1, self.target], outputs=self.output)

        # define the custom loss function
        model.add_loss(self.Loss(self.target, self.output, self.input1))

        # compile the model
        model.compile(optimizer='adam', loss=None)

        # save the model
        self.training_model = model

    def createTestModel(self) -> Model:

        # use the training model to create the test model
        # the test model is the same as the training model but without the
        # fake input

        # define the model
        model = Model(inputs=self.input1, outputs=self.output)
        
        # save the model
        self.testing_model = model

    # testing functions

    def testLoss(self):
        """
        This function tests the custom loss function defined above and
        compares it to a hard-coded version.
        """
        # define the parameters for the test
        batch_size, timesteps, features, tolerance= 32, 3, 3, 1e-5
        # create a test tensor of size (batch_size, timesteps, features)
        test_tensor = np.random.rand(batch_size, timesteps, features)
        # create a test output of size (batch_size, features)
        test_output = np.random.rand(batch_size, features)
        # create a test target of size (batch_size, 1)
        test_target = np.random.rand(batch_size, 1)

        # extract the last row of the tensor and reshape it to be 2D
        test_prices = K.reshape(test_tensor[:, -1, :],
            (-1, test_tensor.shape[2]))
        # calculate the portfolio values as the dot product of the prices and
        # the weights
        test_estim = K.batch_dot(test_output, test_prices)

        # check that the rows of the test_estim are the same as sum of the rows
        # element-wise multiplication of the test_output and test_prices
        for i in range(batch_size):
            sum = 0
            for j in range(features):
                sum += test_output[i, j] * test_prices[i, j]
            if sum - test_estim[i] > tolerance:
                raise ValueError("The portfolio values are not the same")

        # check that the mse is the same as the mean of the square of test_estim
        test_mse = K.mean(K.square(test_target - test_estim))
        hard_mse = 0
        for i in range(batch_size):
            hard_mse += (test_target[i] - test_estim[i])**2
        hard_mse /= batch_size
        if test_mse - hard_mse > tolerance:
            raise ValueError("The mse is not the same")

        print("The test was passed \u2713")

    def testModelPermanence(self):
        """
        This functions creates a training and testing model and trains the
        training model on some dummy data.
        Then it check if the weights of the training and testing models are the
        same.
        """
        # set the test parameters
        batch_size, epochs = 32, 100
        pct_split = 0.8
        self.lookback = 3
        self.num_features = 3

        # create the dummy data
        x = DataFrame(np.random.rand(100, 3), columns=['a', 'b', 'c'])
        y = DataFrame(np.random.rand(100, 1), columns=['d'])

        # preprocess the data
        x_train, y_train, _, _ = self.Preprocess(x, y, pct_split)

        # train the model
        self.createTrainModel()
        self.training_model.fit([x_train, y_train], epochs=epochs,
            batch_size=batch_size, verbose=0)

        # create the testing model
        self.createTestModel()

        # check that the weights of the training and testing models are the same
        # we only need to check the weights of the RNN layer and the Dense layer
        # since the input layer is different
        self.training_model.summary()
        self.testing_model.summary()

        # get the weights of the RNN layer and the Dense layer of the training
        # model
        rnn_weights_train = self.training_model.layers[1].get_weights()
        dense_weights_train = self.training_model.layers[3].get_weights()

        # get the weights of the RNN layer and the Dense layer of the testing
        # model
        rnn_weights_test = self.testing_model.layers[1].get_weights()
        dense_weights_test = self.testing_model.layers[2].get_weights()

        # check that the weights of the RNN layer are the same
        for i in range(len(rnn_weights_train)):
            if not np.array_equal(rnn_weights_train[i], rnn_weights_test[i]):
                raise ValueError("The weights of the RNN layer are not the same")
            
        # check that the weights of the Dense layer are the same
        for i in range(len(dense_weights_train)):
            if not np.array_equal(dense_weights_train[i], dense_weights_test[i]):
                raise ValueError("The weights of the Dense layer are not the same")
            
        print("The permanence test was passed \u2713")


if __name__ == "__main__":

    # create a dummy model
    model = RNN_model(lookback=3, num_features=3)

    # test the loss function
    model.testLoss()

    # test the model permanence
    model.testModelPermanence()

