#-----------------------------------------------------------------------------
# start by building the basic container
#-----------------------------------------------------------------------------
FROM ubuntu:22.04
LABEL org.opencontainers.image.authors="Steven Smith <smith84@llnl.gov>"

# Non interactive mode
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

RUN <<APT_PACKAGES
    apt-get update
    ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
    apt-get install -y tzdata
    dpkg-reconfigure --frontend noninteractive tzdata
    apt-get install -y \
        build-essential \
        locales \
        wget \
        curl \
        libcurl4 \
        git \
        gfortran \
        libopenblas-dev \
        liblapack-dev \
        openmpi-bin \
        libopenmpi-dev \
        libhdf5-openmpi-dev \
        libhdf5-openmpi-103 \
        python3 \
        python3-pip \
        python3-venv \
        tcl-dev \
        tk-dev \
        cmake \
        libxml2 \
        libxml2-dev \
        sudo
    apt-get clean
    locale-gen en_US.UTF-8
    update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
APT_PACKAGES

#-----------------------------------------------------------------------------
# Prepare user
#-----------------------------------------------------------------------------
ARG USER=pfdev

RUN groupadd -r ${USER} && \
    useradd -r -m -d /home/${USER} -s /bin/bash -g ${USER} ${USER} && \
    adduser ${USER} sudo && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER ${USER}
ENV HOME=/home/${USER}
ENV PARFLOW_DIR=${HOME}/install \
    PARFLOW_DEP_DIR=${HOME}/dependencies \
    PATH=$PATH:${HOME}/install/bin:${HOME}/dependencies/bin

#-----------------------------------------------------------------------------
# Prepare dependency directory
#-----------------------------------------------------------------------------
RUN mkdir -p $PARFLOW_DEP_DIR
WORKDIR $PARFLOW_DEP_DIR

#-----------------------------------------------------------------------------
# Build libraries
#-----------------------------------------------------------------------------

#
# HDF5
#  New version does not work with NetCDF; use Ubunuto supplied version
#  https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.12/hdf5-1.12.2/src/hdf5-1.12.2.tar.bz2
#
# RUN <<HDF5_INSTALL
#     wget -q https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.21/src/hdf5-1.8.21.tar.gz
#     tar -xf hdf5-1.8.21.tar.gz
#     cd hdf5-1.8.21
#     CC=mpicc ./configure \
#         --prefix=$PARFLOW_DEP_DIR \
#         --enable-parallel
#     make -j$(nproc) && make install
#     cd ..
#     rm -fr hdf5-1.8.21 hdf5-1.8.21.tar.gz
# HDF5_INSTALL

#
# NetCDF
#
RUN <<NETCDF_C_INSTALL
    wget -q https://github.com/Unidata/netcdf-c/archive/v4.9.0.tar.gz
    tar -xf v4.9.0.tar.gz
    cd netcdf-c-4.9.0
    arch=$(dpkg-architecture -qDEB_HOST_MULTIARCH)
    CC=mpicc \
        CPPFLAGS=-I/usr/include/hdf5/openmpi \
        LDFLAGS=-L/usr/lib/$arch/hdf5/openmpi \
        ./configure --prefix=$PARFLOW_DEP_DIR
    make -j$(nproc) && make install
    cd ..
    rm -fr netcdf-c-4.9.0 v4.9.0.tar.gz
NETCDF_C_INSTALL

#
# NetCDF Fortran
#
RUN <<NETCDF_FORTRAN_INSTALL
    wget -q https://github.com/Unidata/netcdf-fortran/archive/v4.5.4.tar.gz
    tar -xf v4.5.4.tar.gz
    cd netcdf-fortran-4.5.4
    CC=mpicc FC=mpifort \
        CPPFLAGS=-I$PARFLOW_DEP_DIR/include \
        LDFLAGS=-L$PARFLOW_DEP_DIR/lib \
        ./configure --prefix=$PARFLOW_DEP_DIR
    make -j$(nproc) && make install
    cd ..
    rm -fr netcdf-fortran-4.5.4 v4.5.4.tar.gz
NETCDF_FORTRAN_INSTALL

#
# SILO
#
RUN <<SILO_INSTALL
    wget -q https://github.com/LLNL/Silo/archive/refs/tags/4.12.0.tar.gz
    tar -xf 4.12.0.tar.gz
    cd Silo-4.12.0
    ./configure --disable-silex \
        --disable-hzip \
        --disable-fpzip \
        --enable-shared=yes \
        --prefix=$PARFLOW_DEP_DIR
    make -j$(nproc) && make install
    cd ..
    rm -fr Silo-4.12.0 4.12.0.tar.gz
SILO_INSTALL

#
# Hypre
#
RUN <<HYPRE_INSTALL
   wget -q https://github.com/hypre-space/hypre/archive/v2.33.0.tar.gz
   tar xf v2.33.0.tar.gz
   cd hypre-2.33.0/src
   ./configure --prefix=$PARFLOW_DEP_DIR
   make -j$(nproc) && make install
   cd ../..
   rm -fr hypre-2.33.0 v2.33.0.tar.gz
HYPRE_INSTALL

#-----------------------------------------------------------------------------
# Parflow Environment Setup
#-----------------------------------------------------------------------------

WORKDIR $HOME
ENV PARFLOW_MPIEXEC_EXTRA_FLAGS="--mca mpi_yield_when_idle 1 --oversubscribe" \
    OMPI_MCA_rmaps_base_oversubscribe="1" \
    OMP_NUM_THREADS="1" \
    # Disable HWLOC warnings, this has been fixed in later OpenMPI versions
    HWLOC_HIDE_ERRORS="2"

# Copy setup script
COPY --chown=$USER:$USER --chmod=0755 build_and_test.py $HOME/build_and_test.py

# Set bash as default shell
SHELL ["/bin/bash", "-c"]

# Default command
CMD ["/bin/bash", "-l"]
