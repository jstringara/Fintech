from pandas import DataFrame, Series
from typing import List, Tuple

# create the sliding window generator for the data
def sliding_window(
        target:Series,
        features:DataFrame,
        window_size:int,
        start:int = 0,
        end:int = None
    ) -> Tuple[Series, List[DataFrame]]:

    """
    This function creates a sliding window generator for the futures data.
    """

    # set the default end value
    if end is None: end = len(target)
    elif end < len(target): end += 1

    # check that the target and features have the same length and index
    if len(target) != len(features):
        raise ValueError("The target and features must have the same length.")
    if (target.index != features.index).any():
        raise ValueError("The target and features must have the same index.")

    # check validity of window size and start/end
    if window_size < 1: raise ValueError("Window size must be greater than 0.")
    if start < 0: raise ValueError("Start must be greater than or equal to 0.")
    if end > len(target): raise ValueError(
        "End must be less than or equal to the length of the target.")

    # check that the window size is less than the length of the target
    if window_size > len(target):
        raise ValueError(
            "Window size must be less than or equal to the length of the target.") 
    # check that the combination of window size and start/end is valid
    if start + window_size > end: 
        raise ValueError(
            "Start and window size must be less than or equal to end.")

    target_window = target[start+window_size-1:end]

    def feature_window_generator():
        for i in range(start, end-window_size+1):
            yield features.iloc[i:i+window_size, :]

    return target_window, feature_window_generator()

if __name__ == "__main__":
    pass
