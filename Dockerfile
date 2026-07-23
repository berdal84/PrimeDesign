############################################################
# Dockerfile to build PrimeDesign CLI and WebApp
############################################################

# Set the base image to anaconda
FROM continuumio/miniconda3

# File Author / Maintainer
LABEL org.opencontainers.image.authors="Jonathan Y. Hsu"
LABEL org.opencontainers.image.authors="Bérenger Dalle-Cort, berenger@42borgata.com"

ENV SHELL=bash

# Add user and group docker:docker
RUN groupadd -r docker && useradd -r -g docker -m -s /sbin/nologin docker

# Configure conda channels
RUN conda config --add channels defaults
RUN conda config --add channels conda-forge
RUN conda config --add channels bioconda

# Update packages of the docker system
RUN apt-get update
RUN apt-get install gsl-bin libgsl0-dev libgomp1 -y
RUN apt-get clean

# Install crispritz package
RUN conda create -n crispritz python=3.8 -y
RUN conda run -n crispritz conda install r-base -y
RUN conda run -n crispritz conda install biopython -y
RUN conda run -n crispritz conda install crispritz -y
RUN conda run -n crispritz conda update crispritz -y

# Add website dependencies
RUN pip install dash==1.9.1  # Dash core
RUN pip install dash-bio==0.4.8 # Dash bio
RUN pip install dash_daq
RUN pip install dash-bootstrap-components
RUN pip install seqfold
RUN pip install gunicorn
RUN pip install biopython

# Create environment structure
WORKDIR /PrimeDesign
COPY PrimeDesign .
RUN chown -R docker:docker /PrimeDesign
RUN chmod +x /PrimeDesign/web_app/start_server_docker.sh

# Reroute to enable the PrimeDesign CLI and WebApp
EXPOSE 9994
USER docker
ENTRYPOINT ["python", "/PrimeDesign/primedesign_router.py"]
