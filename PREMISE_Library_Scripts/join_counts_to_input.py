import os
import pandas as pd
import sys

new_dir_path = os.path.join(sys.argv[1], "Sample_Counts_Merged/")
os.mkdir(new_dir_path)

dir_list = os.listdir(os.path.join(sys.argv[1], "Passed_Sample_Counts/"))
print(dir_list)

for f in os.listdir(os.path.join(sys.argv[1], "Passed_Sample_Counts/")):
    if not f.startswith('.'):
        name = os.path.basename(os.path.join(sys.argv[1], "Passed_Sample_Counts/", f)).split('.')[0]
        print(name)
        merge_file = name + "_merged.tsv"
        input_counts = pd.read_csv(os.path.join("Input_Library_Counts/", sys.argv[2]), sep="\t", header=0, names=["id", "input"])
        sample_counts = pd.read_csv(os.path.join(sys.argv[1], "Passed_Sample_Counts/", f), sep="\t", header=0)
        merged = pd.merge(input_counts, sample_counts, on='id', how='outer')
        merged.to_csv(os.path.join(new_dir_path, merge_file), index=False, sep="\t")
