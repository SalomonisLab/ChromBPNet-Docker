#!/bin/bash
#BSUB -W 48:00
#BSUB -M 32000
#BSUB -n 4
#BSUB -q gpu-a100
#BSUB -gpu "num=1"
#BSUB -e logs/chrbp_MAIN_2660_Ast82_38M_TEA_MPP-MEP_BIAS_MODEL_MPP-MEP_a100_%J.err 
#BSUB -o logs/chrbp_MAIN_2660_Ast82_38M_TEA_MPP-MEP_BIAS_MODEL_MPP-MEP_a100_%J.out
#BSUB -J chrbp_MAIN_human_MAIN_2660_Ast82_38M_TEA_MPP-MEP_BIAS_MODEL_MPP-MEP_docker_a100

# Load necessary modules
module load cuda/11.7

# Define paths and variables
#USER="sen2qb"
#BIAS_MODEL="2660_Ast82_38M_TEA_MPP-MEP_BIAS_MODEL"
#BAM_PATH="/data/salomonis-archive/FASTQs/Grimes/RNA/scRNASeq/10X-Genomics/BK_AK_black_aml/2660_Ast82_38M/TEA/2660-Ast821-38M-TEA_cellrangerARC_hg38_REDO/outs/2660_Ast82_38M_TEA_MAIN_split_bams/MPP-MEP.bam"
#SAMPLE="MPP-MEP_a100"

DOCKER_IMAGE_NAME="docker_chrombpnet"
DOCKER_TARBALL="/data/salomonis2/LabFiles/Sid/tools/create_dockers/docker_chrombpnet.tar"

# Check if Docker image exists, otherwise load from tarball and build
if [[ -z "$(docker images -q ${DOCKER_IMAGE_NAME}:latest)" ]]; then
    echo "Docker image not found locally. Loading from tarball..."
    if [[ -f "${DOCKER_TARBALL}" ]]; then
        docker load -i "${DOCKER_TARBALL}"
        echo "Docker image loaded successfully."
    else
        echo "Error: Docker tarball not found at ${DOCKER_TARBALL}. Exiting..."
        exit 1
    fi
else
    echo "Docker image ${DOCKER_IMAGE_NAME} already exists."
fi


# Create output directories if they do not exist
mkdir -p 2660_Ast82_38M_TEA_MPP-MEP_BIAS_MODEL
mkdir -p 2660_Ast82_38M_TEA_MPP-MEP_BIAS_MODEL/MPP-MEP_MAIN_MODEL

# Run Docker container with GPU access
docker create docker_chrombpnet:latest
docker cp ./passwd temp:/etc
docker commit docker_chrombpnet:latest

docker run -it --rm --gpus all -u sen2qb -v /database:/database -v /data/salomonis2:/data/salomonis2 -v /data/salomonis-archive:/data/salomonis-archive -v /scratch/sen2qb:/scratch/sen2qb -w /workspace docker_chrombpnet bash "chrombpnet pipeline -ibam ${BAM_PATH} -d 'ATAC' -g hg38/genome.fa -c hg38/sizes_hg38_genome.txt -p all_merged_clusterwise_peaks_no_blacklist.bed -n all_merged_clusterwise_peaks_no_blacklist_nonpeaks.bed_negatives.bed -fl splits/fold_1.json -b 2660_Ast82_38M_TEA_MPP-MEP_BIAS_MODEL/models/bias.h5 -o 2660_Ast82_38M_TEA_MPP-MEP_BIAS_MODEL/MPP-MEP_MAIN_MODEL"


echo "Finished..."
