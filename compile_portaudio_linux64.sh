#!/bin/bash
set -e


# Setup absolute output location

BASE_DIR="$(pwd)"
OUTPUT_DIR="$BASE_DIR/uos_static_libs_unix64"
mkdir -p "$OUTPUT_DIR"

echo "=== Starting Native Unix Static Library Builder ==="

# --------------------------------------------------------------------
#Build PortAudio
# --------------------------------------------------------------------
echo ">>> Building PortAudio..."
rm -rf portaudio
git clone https://github.com/PortAudio/portaudio.git --depth 1
cd portaudio
mkdir build && cd build
cmake .. -DBUILD_SHARED_LIBS=OFF -DPA_BUILD_SHARED_LIBS=OFF -DPA_BUILD_EXAMPLES=OFF -DPA_BUILD_TESTS=OFF -DCMAKE_BUILD_TYPE=Release
make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu)
cp libportaudio.a "$OUTPUT_DIR/"

echo "=========================================================="
echo "SUCCESS: Native Unix static archives generated at:"
echo "$OUTPUT_DIR/"
echo "=========================================================="
