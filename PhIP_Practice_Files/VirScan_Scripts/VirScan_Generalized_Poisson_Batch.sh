#!/bin/bash -e

# Name of job
#$ -N generalized_poisson_batch

# Execute script from current working directory
#$ -cwd

# Memory requirements
#$ -l h_vmem=110G

# Send email when job is submitted and completed
#$ -m e
#$ -M lauren.mccormick@nih.gov

module load phipstat
module load samtools
module load python

# to run: qsub VirScan_Generalized_Poisson_Batch.sh 

# 3. model
mkdir -p Generalized_Poisson_P_Vals
mkdir -p Generalized_Poisson_Scores
mkdir -p Normalized_Sample_Counts

currentDirectory=$(pwd)
inputCounts=$1

python VirScan_Scripts/filter_on_reads.py $currentDirectory
python VirScan_Scripts/join_counts_to_input.py $currentDirectory $inputCounts

for file in Sample_Counts_Merged/*;
	do
    f="$(basename $file .tsv)"
    echo "$f"
    phip normalize-counts -i "Sample_Counts_Merged/"$f".tsv" -o "Normalized_Sample_Counts/"$f".tsv" -m col-sum
    normalizedData="Normalized_Sample_Counts/"$f".tsv" 
    python VirScan_Scripts/round_normalized_data.py $normalizedData
    phip compute-pvals -i "Normalized_Sample_Counts/"$f".tsv" -o "Generalized_Poisson_P_Vals/"$f".mlxp.tsv"
  done

phip merge-columns -i Generalized_Poisson_P_Vals -o Generalized_Poisson_Scores/general_mlxp.tsv -p 1
