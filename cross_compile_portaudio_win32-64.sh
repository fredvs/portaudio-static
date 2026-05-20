#!/bin/bash
set -e

# Global directories
BASE_DIR="$(pwd)"
OUTPUT_WIN64="$BASE_DIR/uos_static_libs_win64"
OUTPUT_WIN32="$BASE_DIR/uos_static_libs_win32"

mkdir -p "$OUTPUT_WIN64" "$OUTPUT_WIN32"

# Pull down the ASIO headers if missing
if [ ! -d "asiosdk" ]; then 
    git clone https://github.com/audiosdk/asio asiosdk --depth 1
fi

if [ ! -d "asiosdk" ]; then
    echo "ERROR: Please place the 'asio_sdk' directory in this folder before running."
    exit 1
fi

# ====================================================================
# COMPILATION FUNCTION
# Arguments: $1 = Architecture ("win32" or "win64")
# ====================================================================
compile_all_libs() {
    local arch=$1
    local out_dir=""
    local mingw_flags=()

    if [ "$arch" == "win64" ]; then
        echo "=========================================================="
        echo ">>> STARTING WINDOWS 64-BIT STATIC COMPILATION <<<"
        echo "=========================================================="
        out_dir="$OUTPUT_WIN64"
        
        # Using bash arrays to safely handle nested quote blocks cleanly
                mingw_flags=(
            "-DCMAKE_SYSTEM_NAME=Windows"
            "-DCMAKE_C_COMPILER=x86_64-w64-mingw32-gcc"
            "-DCMAKE_CXX_COMPILER=x86_64-w64-mingw32-g++"
            "-DCMAKE_RC_COMPILER=x86_64-w64-mingw32-windres"
            "-DCMAKE_C_FLAGS=-O2 -Wl,--strip-debug"
            "-DCMAKE_CXX_FLAGS=-O2 -fexceptions -fno-rtti -Wl,--strip-debug"
            "-DBUILD_SHARED_LIBS=OFF"
        )

    else
        echo "=========================================================="
        echo ">>> STARTING WINDOWS 32-BIT STATIC COMPILATION <<<"
        echo "=========================================================="
        out_dir="$OUTPUT_WIN32"
        
        mingw_flags=(
            "-DCMAKE_SYSTEM_NAME=Windows"
            "-DCMAKE_C_COMPILER=i686-w64-mingw32-gcc"
            "-DCMAKE_CXX_COMPILER=i686-w64-mingw32-g++"
            "-DCMAKE_RC_COMPILER=i686-w64-mingw32-windres"
            "-DCMAKE_C_FLAGS=-O2 -Wl,--strip-debug -msse2"
            "-DCMAKE_CXX_FLAGS=-O2 -fexceptions -fno-rtti -Wl,--strip-debug -msse2"
            "-DBUILD_SHARED_LIBS=OFF"
        )
    fi

    # 1. PortAudio Core Pull Setup
    echo "Building PortAudio ($arch)..."
    if [ ! -d "portaudio" ]; then
        git clone https://github.com/PortAudio/portaudio.git --depth 1
    fi
    
    # Clean old build footprints completely
    rm -rf portaudio/build
    
    cd portaudio && mkdir build && cd build
    
    # Run CMake with array expansion to prevent quote splitting
    cmake .. "${mingw_flags[@]}" \
             -DPA_BUILD_SHARED_LIBS=OFF \
             -DPA_USE_ASIO=ON \
             -DPA_BUILD_EXAMPLES=OFF \
             -DPA_BUILD_TESTS=OFF \
             -DCMAKE_BUILD_TYPE=Release
             
    make -j$(nproc)
    cp libportaudio.a "$out_dir/"
    cd "$BASE_DIR"
}

# Run the compilation logic for both platforms
compile_all_libs "win64"
compile_all_libs "win32"

echo "=========================================================="
echo "ALL WINDOWS STATIC ARCHIVES GENERATED SUCCESSFULLY:"
echo "64-Bit Binaries: $OUTPUT_WIN64/"
echo "32-Bit Binaries: $OUTPUT_WIN32/"
echo "=========================================================="
