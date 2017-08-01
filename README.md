# jupyker
Docker image for AI: Jupyter Notebook, Keras, Tensorflow, Scikit-learn, Python, and more, on Ubuntu.

##### Warning:
requires an __Nvidia GPU__, and works on Linux & Windows, but not Mac (as of Aug 2017, because of nvidia-docker wrapper). Use alternatively the [ea167/jupyker-cpu](https://hub.docker.com/r/ea167/jupyker-cpu) Docker image instead.


##### Launch
Adjust the volume mount (`-v` option) and launch with:

```
    nvidia-docker run -it -d -p=6006:6006 -p=8888:8888 \
        -v=~/DockerShared/JupykerShared:/host  ea167/jupyker
```

###  

and then connect your browser to:
* http://localhost:8888 for Jupyter Notebook
* http://localhost:6006 for TensorBoard
