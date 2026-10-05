#!/bin/bash
#
# 2_quantify.sh
# Run kallisto on paired fastq files

# Our fastq files are large and stored on Staging
PREPD_DIR="/staging/fkuusisto/seqdata/2-prepd"
QUANT_DIR="/staging/fkuusisto/seqdata/3-quant"
INDEX_DIR="/staging/fkuusisto/transcript_index"

# Get the names of the fastq files we're processing
FASTQ_LIST="2_quantify_hpv.files"
FASTQ_LINE=$(($1 + 1))
FNAMES=`head -n $FASTQ_LINE $FASTQ_LIST | tail -1`
FQ1=`echo $FNAMES | cut -d "," -f 1`
FQ2=`echo $FNAMES | cut -d "," -f 2`

# determine the output location
BASENAME=${FQ1/_R[12].prepd*/}
OUTDIR="$BASENAME"
# and create the output directory if it doesn't exist
if [ ! -d $OUTDIR ]
then
    mkdir $OUTDIR
fi

# print a note on the terminal output:
echo "Running 2_quantify job $1 on `whoami`@`hostname`"
echo "Processing: $FQ1 and $FQ2"

# copy over the fastq files
echo "Copying over preprocessed fastqs..."
cp $PREPD_DIR/$FQ1 .
cp $PREPD_DIR/$FQ2 .

# copy over the appropriate index
# indices are stored in a human/mouse dir on staging
# our fastqs should be named with species first
echo "Skipping check for rna_type -just using HPV18 FASTA"
SPECIES=$(echo $BASENAME | cut -d '_' -f 1)
RNA_TYPE="hpv18"
cp $INDEX_DIR/$SPECIES/$RNA_TYPE/transcriptome.idx .
echo "Using transcriptome index for $SPECIES and $RNA_TYPE"

# download kallisto
echo "Downloading kallisto..."
wget https://github.com/pachterlab/kallisto/releases/download/v0.46.1/kallisto_linux-v0.46.1.tar.gz
tar -xzf kallisto_linux-v0.46.1.tar.gz
chmod a+x ./kallisto/kallisto
rm kallisto_linux-v0.46.1.tar.gz

# run kallisto
echo "Running kallisto..."
./kallisto/kallisto quant -i transcriptome.idx -o $OUTDIR -t 8 --bias 2>$OUTDIR/kallisto.txt $FQ1 $FQ2
echo "Everything looking good here?"
ls -lah

# copy results over to staging for retrieval
echo "Moving results to staging..."
mv $OUTDIR $QUANT_DIR

# remove our copies of the fastq files
echo "Cleaning up fastqs and kallisto files"
rm $FQ1
rm $FQ2

# cleanup kallisto and transcriptome
rm transcriptome.idx
rm -rf kallisto
