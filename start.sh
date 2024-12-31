#!/bin/bash

# Start Triton Server in the background
tritonserver --model-repository=/models &

# Start Jupyter Notebook
jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root
