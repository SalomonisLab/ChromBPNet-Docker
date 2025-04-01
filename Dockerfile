# Use Anaconda3 as the base image
FROM continuumio/anaconda3

# Set working directory inside the container
WORKDIR /workspace

# Copy Conda environment file into the container
COPY environment.yml .

# Install Conda environment
RUN conda env create -f environment.yml

# Ensure Conda environment is activated automatically
RUN echo "conda activate chrombpnet_v017" >> ~/.bashrc

# Set default shell to use Conda
SHELL ["/bin/bash", "-c"]

# Clone the GitHub package (Optional: If needed separately)
RUN git clone https://github.com/kundajelab/chrombpnet.git /workspace/chrombpnet
RUN git clone https://github.com/jmschrei/tfmodisco-lite.git /workspace/tfmodisco-lite

# Ensure the package is installed in editable mode inside the Conda environment
RUN conda run -n chrombpnet_v017 pip install -e /workspace/chrombpnet
RUN conda run -n chrombpnet_v017 pip install -e /workspace/tfmodisco-lite

# Create a tar archive of the installed package
RUN tar -czvf /workspace/chrombpnet.tar.gz -C /workspace chrombpnet
RUN tar -czvf /workspace/tfmodisco-lite.tar.gz -C /workspace tfmodisco-lite

# Set entrypoint to activate Conda before running commands
ENTRYPOINT ["bash", "-c", "source activate chrombpnet_v017 && exec \"$@\"", "--"]
