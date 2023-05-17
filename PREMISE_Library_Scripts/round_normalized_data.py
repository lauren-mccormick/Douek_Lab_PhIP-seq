import os
import pandas as pd
import sys

normalized_data = pd.read_csv(sys.argv[1], sep="\t", header=0)
normalized_data_rounded = normalized_data.round()
normalized_data_rounded.iloc[:, 1] = normalized_data_rounded.iloc[:, 1].astype(str).apply(lambda x: x.replace('.0',''))
normalized_data_rounded.iloc[:, 2] = normalized_data_rounded.iloc[:, 2].astype(str).apply(lambda x: x.replace('.0',''))
normalized_data_rounded.to_csv(sys.argv[1], index=False, sep="\t")