# Use NVIDIA CUDA base image with Python 3.12
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Install system dependencies and Python 3.12
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get remove -y python3.10 python3.10-minimal python3.10-venv python3.10-dev python3-pip \
    && apt-get autoremove -y \
    && apt-get install -y \
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    git \
    wget \
    curl \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create symbolic links for python
RUN rm -f /usr/bin/python3 && \
    ln -s /usr/bin/python3.12 /usr/bin/python3 && \
    ln -s /usr/bin/python3.12 /usr/bin/python

# Install pip for Python 3.12
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.12

# Configure git to avoid authentication issues during build
RUN git config --global --add safe.directory /app && \
    git config --global user.name "Docker Build" && \
    git config --global user.email "build@docker.local"

# Set working directory
WORKDIR /app

# Copy project files
COPY pyproject.toml ./
COPY src/ ./src/
COPY configs/ ./configs/
COPY tests/ ./tests/
COPY README.md ./
COPY LICENSE.md ./
COPY .git/ ./.git/
COPY .project-root ./

# Install project dependencies directly in base Python
RUN python3 -m pip install --upgrade pip setuptools wheel && \
    pip3 install -e .

# Install atomworks ML dependencies with compatible versions
RUN pip3 install "einops>=0.8.0,<1" && \
    pip3 install "biotite==1.3.0" && \
    pip3 install "cython<4,>=3.0.0" && \
    pip3 install "cytoolz<1,>=0.12.3" && \
    pip3 install "fastparquet==2024.5.0" && \
    pip3 install "fire<1,>=0.6.0" && \
    pip3 install "hydride==1.2.3" && \
    pip3 install "numpy<2,>=1.25.0" && \
    pip3 install "pandas<2.3,>=2.2" && \
    pip3 install "py3dmol<3,>=2.2.1" && \
    pip3 install "pyarrow==17.0.0" && \
    pip3 install "pymol-remote>=0.0.5" && \
    pip3 install "rdkit>=2024.3.5" && \
    pip3 install "scipy<2,>=1.13.1" && \
    pip3 install "tqdm<5,>=4.65.0" && \
    pip3 install "typer<1,>=0.12.5"

# Create directory for mounted model weights
RUN mkdir -p /models

# Set default command
CMD ["/bin/bash"]
