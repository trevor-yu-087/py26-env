# Dockerfile to create environment for CS 6.01 from MIT Open Courseware
# https://ocw.mit.edu/courses/6-01sc-introduction-to-electrical-engineering-and-computer-science-i-spring-2011/pages/software-and-tools/installing-the-6-01-software-on-gnu-linux/
FROM ubuntu

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=US/Pacific
WORKDIR /root/.cache/
ARG PYTHON_VERSION=2.6.6

RUN apt-get update && apt-get install -y python2 python-tk wget curl build-essential zlib1g-dev libx11-dev tk-dev libssl-dev libffi-dev

# Build python-2.6.6 from source
RUN curl -O https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar -xvzf Python-${PYTHON_VERSION}.tgz
# Need to modify Modules/Setup; copy over custom file
COPY Setup /root/.cache/Python-${PYTHON_VERSION}/Modules
WORKDIR  /root/.cache/Python-${PYTHON_VERSION}
RUN ./configure \
    --prefix=/opt/python/${PYTHON_VERSION} \
    --enable-shared \
    --enable-optimizations \
    --enable-ipv6 \
    --with-zlib=/usr/include \
    --with-tcltk-includes="-I/usr/include/tk" \
    --with-tcltk-libs="-L/usr/lib -ltcl8.6 -L/usr/lib -ltk8.6" \
    LDFLAGS=-Wl,-rpath=/opt/python/${PYTHON_VERSION}/lib,--disable-new-dtags,-L=/usr/include \
    CPPFLAGS=-I=/usr/include && \
    make && make altinstall
ENV PATH="$PATH:/opt/python/${PYTHON_VERSION}/bin"

# # Install pip and numpy
# Doesn't work because SSL module of python won't compile and needs that to install pip
# WORKDIR /root/.cache/
# RUN wget https://bootstrap.pypa.io/pip/2.6/get-pip.py && \
#     python2.6 get-pip.py && \
#     pip install numpy

# Install numpy from source
RUN wget https://bootstrap.pypa.io/ez_setup.py -O - | python2.6
COPY numpy-1.11.2 /root/.cache/numpy-1.11.2
WORKDIR /root/.cache/numpy-1.11.2
# Missing xlocale.h, link from locale.h
RUN ln -s /usr/include/locale.h /usr/include/xlocale.h && \
    python2.6 setup.py install

# Install lib601
RUN wget https://ocw.mit.edu/courses/6-01sc-introduction-to-electrical-engineering-and-computer-science-i-spring-2011/afbbebccae39bfa42f9d071e9ed10453_lib601-3-500.tar.gz \
    -O /root/.cache/lib601-3-500.tar.gz && \
    tar -xvzf /root/.cache/lib601-3-500.tar.gz --one-top-level=/root/.cache/
WORKDIR /root/.cache/lib601-3-500
RUN python2.6 setup.py install

WORKDIR /root
CMD ["bash"]