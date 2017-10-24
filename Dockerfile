# NOTES:
#   1. You need an Nvidia GPU to run this Docker image.
#           Otherwise use the alternative ea167/jupyker-cpu
#   2. Install the nvidia-docker wrapper on your computer to launch the image
#           https://github.com/NVIDIA/nvidia-docker
#           Warning: can't be run on Mac unfortunately, only Linux and Windows (Aug 2017)
#
# To run:
# 	nvidia-docker run -it -d -p=6006:6006 -p=8888:8888 -v=~/DockerShared/JupykerShared:/host  ea167/jupyker
#
# NOTE: Due to nvidia-docker issues #112 and PR #364 not yet merged
#           (see https://github.com/NVIDIA/nvidia-docker/pull/364)
#       you need to run the first time without the -v=..., stop and relaunch (you can remove the first container)
#           nvidia-docker run -it -d -p=6006:6006 -p=8888:8888 ea167/jupyker
#
#
# http://localhost:8888 for Jupyter Notebook
# http://localhost:6006 for TensorBoard
#
# Built for Nvidia GPUs
# WARNING: you need to register and accept Nvidia license agreement to use CUDA / cuDNN
#   at https://developer.nvidia.com/cudnn
#
# To run tensorboard:
# 	tensorboard --logdir=path/to/logs
# 	where path/to/logs is typically related to
# 		file_writer = tf.summary.FileWriter('/path/to/logs', sess.graph)


### Other great Docker images similar to this one:
### 	https://hub.docker.com/r/gw000/keras-full/
### 	https://hub.docker.com/r/waleedka/modern-deep-learning/

# NOTE: to build:
# 	Use Docker Automated Build,
# 	OR
# 		Run  ' docker build -t ea167/jupyker . ' to build it
# 		Then ' docker login '
# 	   		 ' docker push ea167/jupyker '



### TODO: Tensorflow Fold?
### Sonnet?

# 17.04 is the latest - Out on April 13, 2017
# 	As far as now, Nvidia CUDA and drivers are only for 16.04 LTS
# We use the Nvidia Docker image with Ubuntu, Cuda, drivers and CNN installed.
#   The runtime version rather than developer one   :latest == :8.0-devel-ubuntu16.04
#FROM ubuntu:16.04
FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04
LABEL maintainer="Eric Amram <eric dot amram at gmail dot com>"

# Headless front-end, remove warnings
ARG DEBIAN_FRONTEND=noninteractive

# Get most recent updates
RUN apt-get update -qq

# Utils
RUN apt-get install -y --no-install-recommends apt-utils \
 && apt-get install -y --no-install-recommends \
    locales \
	ssh vim unzip less procps \
	git curl wget \
	build-essential g++ cmake \
 && echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/99AcquireRetries \
 && sed -i 's/main$/main contrib non-free/' /etc/apt/sources.list \
 && apt-get install -y --no-install-recommends linux-headers-generic initramfs-tools


# Locales
RUN locale-gen "en_US.UTF-8" \
 && update-locale LC_ALL="en_US.UTF-8" LANG="en_US.UTF-8"

ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"


# --- Nvidia CuDA already baked into the FROM docker image
# Nvidia CuDA Toolkit v8.0 (Nvidia for Ubuntu 16.04 x86_64 package)
#   See https://www.tensorflow.org/install/install_linux for instructions
# RUN mkdir -p /opt/nvidia \
#  && cd /opt/nvidia \
#  && wget --no-check-certificate http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_8.0.61-1_amd64.deb \
#  && dpkg -i cuda-repo-ubuntu1604_8.0.61-1_amd64.deb \
#  && apt-get update \
#  && apt-get install -y --no-install-recommends  cuda \
#  && rm -f cuda-repo-ubuntu1604_8.0.61-1_amd64.deb \
#  && export PATH=${PATH}:/usr/local/cuda-8.0.61/bin \
#  && export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda-8.0.61/lib64
# cuDNN v5.1 (as required by Tensorflow)
# RUN cd /opt/nvidia \
#  && wget --no-check-certificate https://developer.nvidia.com/compute/machine-learning/cudnn/secure/v5.1/prod_20161129/8.0/cudnn-8.0-linux-x64-v5.1-tgz \
#  && mv cudnn-8.0-linux-x64-v5.1-tgz cudnn-8.0-v5.1.tgz \
#  && tar xzf cudnn-8.0-v5.1.tgz \
#  && rm -f   cudnn-8.0-v5.1.tgz \
#  && export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/opt/nvidia/cudnn-8.0-v5.1 \
#  && cd /root
# libcupti-dev (as required by Tensorflow) + PATH + LD_LIBRARY_PATH
# RUN apt-get install -y --no-install-recommends  libcupti-dev \
#  && echo "export PATH=${PATH}:/usr/local/cuda-8.0.61/bin" >> /root/.bashrc \
#  && echo "export LD_LIBRARY_PATH=\${LD_LIBRARY_PATH}:/usr/local/cuda-8.0.61/lib64" >> /root/.bashrc

# OLDER Nvidia CuDA Toolkit (Ubuntu packages)
# RUN apt-get install --no-install-recommends -y nvidia-cuda-toolkit


# Python (3.5)
# Aliases (but don't sym-link) python -> python3 and pip -> pip3
RUN apt-get install -y --no-install-recommends \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-virtualenv \
    pkg-config \
    # Required for keras
    python3-h5py \
    python3-yaml \
    python3-pydot
# Upgrade with latest pip and create aliases
RUN pip3 install --no-cache-dir --upgrade pip setuptools \
 && echo "alias python='python3'" >> /root/.bash_aliases \
 && echo "alias pip='pip3'" >> /root/.bash_aliases

# Pillow (with dependencies)
RUN apt-get install -y --no-install-recommends libjpeg-dev zlib1g-dev \
 && pip3 --no-cache-dir install Pillow

# OpenBLAS
RUN apt-get install -y --no-install-recommends libopenblas-base libopenblas-dev

# Python scientific libs
RUN pip3 --no-cache-dir install \
    numpy \
    scipy \
    scikit-learn \
    scikit-image \
    statsmodels \
    pandas \
    matplotlib \
    seaborn

# Note: seaborn is high-level statistical data visualization on top of matplotlib

### We should not need old Python2. Otherwise, we'll need to install:
#RUN apt-get install -y --no-install-recommends \
#    python \
#    python-dev \
#    python-pip \
#    python-setuptools \
#    python-virtualenv \
#    python-wheel \
#    python-matplotlib \
#    python-pillow


# Jupyter notebook
RUN pip3 --no-cache-dir install jupyter \
# Jupyter config: don't open browser. Password will be set when launching, see below.
 && mkdir /root/.jupyter \
 && echo "c.NotebookApp.ip = '*'" \
         "\nc.NotebookApp.open_browser = False" \
         > /root/.jupyter/jupyter_notebook_config.py
EXPOSE 8888


# Tensorflow
RUN pip3 install --no-cache-dir --upgrade tensorflow-gpu
# Port for TensorBoard
EXPOSE 6006


# Keras
RUN pip3 --no-cache-dir install keras


# Clean-up
RUN apt-get clean && apt-get autoremove \
 && rm -rf /var/lib/apt/lists/*


# Configure console -- FIXME !!!
RUN echo 'alias ll="ls --color=auto -lA"' >> /root/.bashrc \
 && echo '"\e[5~": history-search-backward' >> /root/.inputrc \
 && echo '"\e[6~": history-search-forward' >> /root/.inputrc
# default password: keras
ENV PASSWD='sha1:98b767162d34:8da1bc3c75a0f29145769edc977375a373407824'

# dump package lists
RUN dpkg-query -l > /dpkg-query-l.txt \
 && pip3 freeze > /pip3-freeze.txt

# Volumes and folders shared with host
VOLUME ["/host"]

# Start Jupyter Notebook
#WORKDIR /root/
WORKDIR /host/

CMD jupyter notebook --allow-root --no-browser --ip=* --NotebookApp.password="$PASSWD" \
    & /bin/bash
