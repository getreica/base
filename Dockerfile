# Stage 1: Base image with common dependencies
FROM nvidia/cuda:12.8.1-cudnn-devel-ubuntu22.04 AS base

# Prevents prompts from packages asking for user input during installation
ENV DEBIAN_FRONTEND=noninteractive
# Prefer binary wheels over source distributions for faster pip installations
ENV PIP_PREFER_BINARY=1
# Ensures output from python is printed immediately to the terminal without buffering
ENV PYTHONUNBUFFERED=1 
# Speed up some cmake builds
ENV CMAKE_BUILD_PARALLEL_LEVEL=8

# Install Python, git and other necessary tools
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    && apt-get install -y --no-install-recommends git git-lfs zip unzip aria2 ffmpeg libxext6 libxrender1 \
    && apt-get install -y libgl1-mesa-glx libglib2.0-0 git wget libgl1 \
    && ln -sf /usr/bin/python3.10 /usr/bin/python \
    && ln -sf /usr/bin/pip3 /usr/bin/pip

# Clean up to reduce image size
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install comfy-cli
RUN pip install comfy-cli
RUN pip3 install -U gguf blend-modes matplot

# Install ComfyUI with compatible CUDA version
RUN /usr/bin/yes | comfy --workspace /comfyui install --cuda-version 12.1 --nvidia --version 0.3.45

# Change working directory to ComfyUI
WORKDIR /comfyui

# Install runpod
RUN pip install runpod requests

# Support for the network volume
ADD src/extra_model_paths.yaml ./
