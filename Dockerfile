# Note: Use Docker Automated Build, OR
# Run  ' docker build -t ea167/jupyker . ' to build it
# Then ' docker login '
# 	   ' docker push ea167/jupyker '

### Other great Docker images similar to this one:
### 	https://hub.docker.com/r/gw000/keras-full/
### 	https://hub.docker.com/r/waleedka/modern-deep-learning/

### TODO: Tensorflow Fold?
### Sonnet?

# 17.04 is the latest - Out on April 13, 2017
# 	As far as now, Nvidia CUDA and drivers are only for 16.04 LTS
FROM ubuntu:16.04
MAINTAINER Eric Amram <eric dot amram at gmail dot com>

# Headless front-end, remove warnings
ARG DEBIAN_FRONTEND=noninteractive

# Get most recent updates
RUN apt-get update -qq

# Utils
RUN apt-get install -y --no-install-recommends apt-utils
RUN apt-get install -y --no-install-recommends \
	ssh vim unzip less procps \
	git curl wget \
	build-essential g++ cmake


# Nvidia CuDA Toolkit (Ubuntu packages)
RUN echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/99AcquireRetries \
 && sed -i 's/main$/main contrib non-free/' /etc/apt/sources.list
RUN apt-get install --no-install-recommends -y nvidia-cuda-toolkit
# install cuda opencl -> FIXME, does not work yet
#RUN apt-get install --no-install-recommends -y \
#    nvidia-smi \
#    nvidia-opencl-icd


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
# Upgrade with latest pip
RUN pip3 install --no-cache-dir --upgrade pip setuptools
# Alias
RUN echo "alias python='python3'" >> /root/.bash_aliases
RUN echo "alias pip='pip3'" >> /root/.bash_aliases

# Pillow (with dependencies)
RUN apt-get install -y --no-install-recommends libjpeg-dev zlib1g-dev
RUN pip3 --no-cache-dir install Pillow

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
RUN pip3 --no-cache-dir install jupyter
# Jupyter config: don't open browser. Password will be set when launching, see below.
RUN mkdir /root/.jupyter
RUN echo "c.NotebookApp.ip = '*'" \
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
RUN apt-get clean && apt-get autoremove
RUN rm -rf /var/lib/apt/lists/*


# Configure console -- FIXME !!!
RUN echo 'alias ll="ls --color=auto -lA"' >> /root/.bashrc \
 && echo '"\e[5~": history-search-backward' >> /root/.inputrc \
 && echo '"\e[6~": history-search-forward' >> /root/.inputrc
# default password: keras
ENV PASSWD='sha1:98b767162d34:8da1bc3c75a0f29145769edc977375a373407824'

# dump package lists
RUN dpkg-query -l > /dpkg-query-l.txt \
 && pip3 freeze > /pip3-freeze.txt

### FIXME !!!!
WORKDIR /srv/
CMD /bin/bash -c 'jupyter notebook --no-browser --ip=* --NotebookApp.password="$PASSWD" "$@"'
