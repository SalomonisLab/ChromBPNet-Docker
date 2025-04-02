!/bin/bash

# Create output directories if they do not exist
# mkdir -p 2660_Ast82_38M_TEA_MPP-MEP_BIAS_MODEL
# mkdir -p 2660_Ast82_38M_TEA_MPP-MEP_BIAS_MODEL/MPP-MEP_MAIN_MODEL

BAM_PATH=2660_Ast82_38M_TEA_MAIN_split_MPP-MEP.bam

docker run -it --rm --gpus all -v `pwd`:`pwd` -w `pwd` chrombpnet chrombpnet pipeline -ibam ${BAM_PATH} -d 'ATAC' -g hg38/genome.fa -c hg38/sizes_hg38_genome.txt -p all_merged_clusterwise_peaks_no_blacklist.bed -n all_merged_clusterwise_peaks_no_blacklist_nonpeaks.bed_negatives.bed -fl splits/fold_1.json -b bias.h5 -o 2660_Ast82_38M_TEA_MPP-MEP_BIAS_MODEL/MPP-MEP_MAIN_MODEL | \
           stdbuf --output=L gawk '{ print strftime("[%Y-%m-%d %H:%M:%S]"), $0 }' | tee run.log

