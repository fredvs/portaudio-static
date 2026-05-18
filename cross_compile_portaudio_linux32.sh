#!/bin/bash
set -e

# Define Output Folders
BASE_DIR="$(pwd)"
OUTPUT_DIR="$BASE_DIR/uos_static_libs_linux32"
mkdir -p "$OUTPUT_DIR"

echo "=========================================================="
echo ">>> CROSS-COMPILING LINUX 32-BIT STATIC LIBRARIES <<<"
echo "=========================================================="

# Force compiler flags globally for 32-bit output architecture
export CFLAGS="-m32"
export CXXFLAGS="-m32"
export LDFLAGS="-m32"

# 1. Build PortAudio (32-bit)
echo ">>> Building PortAudio (Linux 32)..."
rm -rf portaudio/build
if [ ! -d "portaudio" ]; then
git clone https://github.com/PortAudio/portaudio.git --depth 1
fi
cd portaudio && mkdir build && cd build
# Force CMake to pass -m32 to compilers and linkers
cmake .. -DCMAKE_C_FLAGS="-m32" -DCMAKE_CXX_FLAGS="-m32" \
         -DBUILD_SHARED_LIBS=OFF -DPA_BUILD_SHARED_LIBS=OFF \
         -DPA_BUILD_EXAMPLES=OFF -DPA_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
cp libportaudio.a "$OUTPUT_DIR/"
cd "$BASE_DIR"

echo "=========================================================="
echo "SUCCESS: Linux 32-bit static libraries generated at:"
echo "$OUTPUT_DIR/"
echo "=========================================================="
