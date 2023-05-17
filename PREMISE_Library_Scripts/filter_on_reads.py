import os
import pandas as pd
import sys

new_dir_path = os.path.join(sys.argv[1], "Passed_Sample_Counts/")
os.mkdir(new_dir_path)


for f in os.listdir(os.path.join(sys.argv[1], "Sample_Counts/")):
    if not f.startswith('.'):
        name = os.path.basename(os.path.join(sys.argv[1], "Sample_Counts/", f)).split('.')[0]
        print(name)
        sample_counts = pd.read_csv(os.path.join(sys.argv[1], "Sample_Counts/", f), sep="\t", header=0)
        MIN_READS = ((sample_counts.shape[0] * 10) / 2)
        aligned_counts = sample_counts.sum(axis = 0, skipna = True, numeric_only = True)
        print(aligned_counts[0])
        if aligned_counts[0] > MIN_READS:
            sample_counts.to_csv(os.path.join(new_dir_path, f), index=False, sep="\t")

