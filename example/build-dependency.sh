#!/bin/bash

########################
## Configuration - Start

# The name of the dependency, as you named the git submodule.
# Example: If you git submodule is located under /lib/opencv,
# you need to set DEPENDENCY=opencv
DEPENDENCY=dependency

# Number of parallel make jobs. Be carefull, increasing this
# number may lead to massive swapping on machines with low RAM!
JOBS="1"

# Build arguments
BUILD_ARGS="-DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF"
# Add arguments as needed. For example, if you want to
# set BUILD_TESTS to "ON", add:
# BUILD_ARGS="$BUILD_ARGS -DBUILD_TESTS=ON"
# BUILD_ARGS="$BUILD_ARGS -DBUILD_DOCS=OFF"

## Configuration  -  End
########################


function usage
{
    echo "This script cross compiles a dependency in the clickable docker container (armhf or amd64) or builds it simply for your host architecture (host)."
    echo "usage: $0 [armhf|amd64|host] [clean]"
}

function clean
{
    $DOCKER_COMMAND bash <<-EOF
    #!/bin/bash
    rm -rf $BUILD_DIR
EOF
}

function build
{
    git submodule update --init --recursive
    mkdir -p $BUILD_DIR
    $DOCKER_COMMAND bash <<-EOF
    #!/bin/bash
    export MAKEFLAGS=-j$JOBS
    cd $BUILD_DIR
    cmake $BUILD_ARGS $SOURCE_DIR
    cmake --build .
EOF
}

function parse
{
    if [ $# -gt 2 ]; then
        echo "Too many parameters..."
        return 1
    fi

    if [ $# -eq 2 -a "$1" != "clean" -a "$2" != "clean" ]; then
        return 1
    fi

    ARCH="armhf"
    ARCH_TRIPLET="arm-linux-gnueabihf"
    DO_CLEAN=0
    for param in $*; do
        case $param in
            "clean")
                DO_CLEAN=1
                ;;
            "amd64")
                ARCH="amd64"
                ARCH_TRIPLET="x86_64-linux-gnu"
                ;;
            "armhf")
                ARCH="armhf"
                ARCH_TRIPLET="arm-linux-gnueabihf"
                ;;
            "host")
                ARCH="host"
                ARCH_TRIPLET=$(dpkg-architecture -q DEB_HOST_MULTIARCH)
                ;;

            *)
                return 1
        esac
    done

    return 0
}


function init
{
    if [ "$ARCH" == "host" ]; then
        DOCKER_COMMAND=""
    else
        DOCKER_COMMAND="docker run -i -v $PWD:$PWD -w $PWD clickable/ubuntu-sdk:16.04-$ARCH"
    fi

    SOURCE_DIR=$PWD/libs/$DEPENDENCY
    BUILD_DIR=build/$DEPENDENCY/$ARCH_TRIPLET

    return 0
}

# Parse arguments
set -e
parse $*
init

if [ $? -eq 1 ]; then
    usage
    exit 1
fi

if [ $DO_CLEAN -eq 1 ]; then
    echo "Cleaning..."
    clean
    echo "Done..."
else
    echo "Building..."
    build
    echo "Done..."
fi
