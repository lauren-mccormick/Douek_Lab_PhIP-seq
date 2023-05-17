#!/bin/bash

# Name of job
#$ -N input_trim_bowtie

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

# to run: qsub PREMISE_Library_Scripts/PREMISE_Input_Library_Bowtie.sh [1] [2]

mkdir -p "Input_Library_Counts"
mkdir -p "Trimmed_Data"

##Path from cd to demultiplexed data 
demultiplexedFolder=$1

##Path from cd to bowtie index
bowtieIndex=$2

for dir in $demultiplexedFolder/Input_Library/*;
	do
    echo $dir
    d="$(basename "$dir")"
    mkdir -p "Trimmed_Data/"$d"/"
    shopt -s nullglob
    array=($demultiplexedFolder"/Input_Library/"$d"/"*)
    echo "${array[@]}"
    countFile=$d"_counts.tsv"
    read1="$(basename "${array[0]}")"
    echo "$read1"
    read2="$(basename "${array[1]}")"
    echo "$read2"
    gunzip -c "${array[0]}" | fastx_trimmer -f 21 -o "Trimmed_Data/"$d"/"$read1
    gunzip -c "${array[1]}" | fastx_trimmer -f 28 -o "Trimmed_Data/"$d"/"$read2
    echo -e "id\tInput" > Input_Library_Counts/$countFile
    bowtie2 -p 4 -x $bowtieIndex -1 "Trimmed_Data/"$d"/"$read1 -2 "Trimmed_Data/"$d"/"$read2 \
            | samtools sort -O BAM \
            | samtools depth -aa -m 100000000 - \
            | awk 'BEGIN {OFS="\t"} {counts[$1] = ($3 < counts[$1]) ? counts[$1] : $3} END {for (c in counts) {print c, counts[c]}}' \
            | sort -k 1 \
            >> Input_Library_Counts/$countFile
        done

echo "Bowtie Alignment Complete"