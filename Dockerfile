FROM ubuntu:22.04

# Install packages
RUN apt-get update && \
    apt-get install -y git help2man perl python3 make autoconf g++ flex bison ccache

# Install verilator
WORKDIR /work
RUN git clone https://github.com/verilator/verilator.git
WORKDIR /work/verilator
RUN git checkout v5.028 && \
    autoconf && \
    ./configure && \
    make install

# Download UVM library
WORKDIR /work
RUN git clone https://github.com/antmicro/uvm-verilator.git -b current-patches uvm

# Set variable for UVM library location
ENV UVM_HOME=/work/uvm
