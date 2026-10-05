#!/bin/bash
#
# create_kallisto_indices.sh
# Run kallisto on FASTAs to create mapping indices

# Our indices will go on staging
INDEX_DIR="/staging/fkuusisto/transcript_index"

# Get the names of the fasta files we're processing
FASTA_HPV="hpv18.fa.gz"

# print a note on the terminal output:
echo "Running create_kallisto_hpv_index job $1 on `whoami`@`hostname`"

# download kallisto
wget https://github.com/pachterlab/kallisto/releases/download/v0.46.1/kallisto_linux-v0.46.1.tar.gz
tar -xzf kallisto_linux-v0.46.1.tar.gz
chmod a+x ./kallisto/kallisto
rm kallisto_linux-v0.46.1.tar.gz

# run kallisto index
# kmer 31 (default) for HPV RNA
./kallisto/kallisto index -k 31 -i transcriptome.idx $FASTA_HPV
mv transcriptome.idx $INDEX_DIR/human/hpv18

# remove our copies of the fasta files
rm $FASTA_HPV

# cleanup kallisto
rm -rf kallisto
