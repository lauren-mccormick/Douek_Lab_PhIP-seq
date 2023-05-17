#!/bin/bash

# Name of job
#$ -N trim_bowtie_batch

# Execute script from current working directory
#$ -cwd

# Memory requirements
#$ -l h_vmem=15G

# Send email when job is submitted and completed
#$ -m e
#$ -M lauren.mccormick@nih.gov

module load bowtie2
module load phipstat
module load samtools
module load python
module load fastx-toolkit/0.0.14-goolf-1.7.20

# to run: qsub VirScan_Scripts/VirScan_Bowtie_Batch.sh Demultiplexed_Data/Sample_Data VirScan_Dereplicated_bowtie_index/VIR3_dereplicated VS_B1_3_counts.tsv

mkdir -p "Sample_Counts"

##Path from cd to demultiplexed data 
demultiplexedFolder=$1

##Path from cd to bowtie index
bowtieIndex=$2

##Path from cd to input counts
inputCounts=$3

for dir in $demultiplexedFolder/*;
	do
    echo $dir
    d="$(basename "$dir")"
    mkdir -p "Trimmed_Data/"$d"/"
    shopt -s nullglob
    array=($demultiplexedFolder"/"$d"/"*)
    echo "${array[@]}"
    countFile=$d"_counts.tsv"
    read1="$(basename "${array[0]}")"
    echo "$read1"
    read2="$(basename "${array[1]}")"
    echo "$read2"
    gunzip -c "${array[0]}" | fastx_trimmer -f 30 -o "Trimmed_Data/"$d"/"$read1
    gunzip -c "${array[1]}" | fastx_trimmer -f 65 -o "Trimmed_Data/"$d"/"$read2
    echo -e "id\t"$d > Sample_Counts/$countFile
    bowtie2 -p 4 -x $bowtieIndex -1 "Trimmed_Data/"$d"/"$read1 -2 "Trimmed_Data/"$d"/"$read2 \
            | samtools sort -O BAM \
            | samtools depth -aa -m 100000000 - \
            | awk 'BEGIN {OFS="\t"} {counts[$1] = ($3 < counts[$1]) ? counts[$1] : $3} END {for (c in counts) {print c, counts[c]}}' \
            | sort -k 1 \
            >> Sample_Counts/$countFile
        done

echo "Bowtie Alignment Complete"

qsub VirScan_Scripts/VirScan_Generalized_Poisson_Batch.sh $inputCounts