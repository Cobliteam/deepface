# base image
FROM nvcr.io/nvidia/cuda:11.0.3-runtime-ubuntu20.04
LABEL org.opencontainers.image.source https://github.com/serengil/deepface

# -----------------------------------
# create required folder
RUN mkdir -p /app && chown -R 1001:0 /app
RUN mkdir /app/deepface

# -----------------------------------
# switch to application directory
WORKDIR /app

RUN apt update -y && apt upgrade -y && DEBIAN_FRONTEND=noninteractive apt install -y \
    wget curl git build-essential checkinstall libreadline-gplv2-dev libncursesw5-dev libssl-dev \
    libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev liblzma-dev \
    ffmpeg libsm6 libxext6 libhdf5-dev \
    && rm -rf /var/lib/apt/lists/*

# install pyenv
RUN git clone https://github.com/pyenv/pyenv.git /root/.pyenv
ENV PYENV_ROOT=/root/.pyenv
ENV PATH="$PYENV_ROOT/bin:$PATH"
ENV PATH="$PYENV_ROOT/shims:$PATH"

# install python 3.8.12
RUN pyenv install 3.8.12  \
    && pyenv global 3.8.12

RUN apt-get update && \
    apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub && \
    echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /"  > /etc/apt/sources.list.d/tensorRT.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends libnvinfer7=7.2.2-1+cuda11.0 \
    libnvinfer-plugin7=7.2.2-1+cuda11.0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
# -----------------------------------
# Copy required files from repo into image
COPY ./deepface /app/deepface
# even though we will use local requirements, this one is required to perform install deepface from source code
COPY ./requirements.txt /app/requirements.txt
COPY ./requirements_local /app/requirements_local.txt
COPY ./package_info.json /app/
COPY ./setup.py /app/
COPY ./README.md /app/
COPY ./entrypoint.sh /app/deepface/api/src/entrypoint.sh

# -----------------------------------
# if you plan to use a GPU, you should install the 'tensorflow-gpu' package
RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org tensorflow-gpu==2.11.0

# if you plan to use face anti-spoofing, then activate this line
# RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org torch==2.1.2
# -----------------------------------
# install deepface from pypi release (might be out-of-date)
# RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org deepface
# -----------------------------------
# install dependencies - deepface with these dependency versions is working
RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org -r /app/requirements_local.txt
# install deepface from source code (always up-to-date)
RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org -e .

# -----------------------------------
# some packages are optional in deepface. activate if your task depends on one.
RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org cmake==3.24.1.1
RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org dlib==19.20.0
RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org facenet-pytorch==2.5.3
RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org mediapipe==0.10.11
RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org ultralytics==8.3.70
# RUN pip install --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host=files.pythonhosted.org lightgbm==2.3.1

# -----------------------------------
# environment variables
ENV PYTHONUNBUFFERED=1
ENV LD_LIBRARY_PATH=usr/local/cuda-11.0/lib64

# -----------------------------------
# run the app (re-configure port if necessary)
WORKDIR /app/deepface/api/src
EXPOSE 5000
# CMD ["gunicorn", "--workers=1", "--timeout=3600", "--bind=0.0.0.0:5000", "app:create_app()"]
ENTRYPOINT [ "sh", "entrypoint.sh" ]
