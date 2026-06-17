#!/bin/bash
set -e

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [17] 📱 Building iPod emulator and assets for tinyfs-iphoneos"

if [[ "$SYSTEM_TYPE" != "tinyfs-iphoneos" ]]; then
    echo "Skipping emulator build for $SYSTEM_TYPE"
    exit 0
fi

# Install build dependencies on the host
sudo apt-get update
sudo apt-get install -y git build-essential pkg-config libssl-dev libsdl2-dev libpixman-1-dev libglib2.0-dev ninja-build python3 unzip wget

# 1. Build the binary
git clone https://github.com/devos50/qemu-ios.git qemu-ios-src
cd qemu-ios-src
mkdir build && cd build

../configure --target-list=arm-softmmu \
    --enable-sdl \
    --disable-cocoa \
    --disable-capstone \
    --disable-slirp \
    --disable-pie \
    --disable-werror

make -j$(nproc)

# Copy binary to rootfs
echo "Installing emulator binary to rootfs..."
cp arm-softmmu/qemu-system-arm ../../rootdir/usr/bin/
cd ../..
rm -rf qemu-ios-src

# 2. Install assets
echo "Installing emulator assets to /opt/ipod-emu..."
ASSETS_DIR="rootdir/opt/ipod-emu"
mkdir -p "$ASSETS_DIR"

# Links
BOOTROM_URL="https://release-assets.githubusercontent.com/github-production-release-asset/412456137/55148251-e4a4-4ec8-80e0-45e8fd016857?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-06-17T03%3A22%3A36Z&rscd=attachment%3B+filename%3Dbootrom_240_4&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-06-17T02%3A22%3A12Z&ske=2026-06-17T03%3A22%3A36Z&sks=b&skv=2018-11-09&sig=0q4SSZaZ4deJHYiX%2Ff5jmD2mV6UQsRtguuvuvOApYhQ%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4MTY2NDgxNiwibmJmIjoxNzgxNjY0NT denote-6,sS=b&skv=2018-11-09"
NAND_URL="https://release-assets.githubusercontent.com/github-production-release-asset/412456137/25501134-9ac8-4811-a9f6-ea9bedf93de7?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-06-17T03%3A25%3A52Z&rscd=attachment%3B+filename%3Dnand_n72ap.zip&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-06-17T02%3A25%3A48Z&ske=2026-06-17T03%3A25%3A52Z&sks=b&skv=2018-11-09&sig=Z%2FmEzvvQzE17rQ%2FcYnVrml9hRNBQER1UAA%2FTa1bWHYM%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4MTY2ODEzMywibmJmIjoxNzgxNjY0NTMzLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.nVxjINf0TJwUCWjgzjgu2H3B0XYXlyVQdkKWmacCDgY"
NOR_URL="https://release-assets.githubusercontent.com/github-production-release-asset/412456137/28449723-1acb-46d1-a12e-c925bfcdb76c?sp=r&sv=2018-11-09&sr=b&spr=https&se=2026-06-17T03%3A49%3A37Z&rscd=attachment%3B+filename%3Dnor_n72ap.bin&rsct=application%2Foctet-stream&skoid=96c2d410-5711-43a1-aedd-ab1947aa7ab0&sktid=398a6654-997b-47e9-b12b-9515b896b4de&skt=2026-06-17T02%3A49%3A17Z&ske=2026-06-17T03%3A49%3A37Z&sks=b&skv=2018-11-09&sig=O9m6mn9c1pn8fNjEwAcT81u9X7acb8NeFrBe3RP0S5w%3D&jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmVsZWFzZS1hc3NldHMuZ2l0aHVidXNlcmNvbnRlbnQuY29tIiwia2V5Ijoia2V5MSIsImV4cCI6MTc4MTY2NDg2MywibmJmIjoxNzgxNjY0NTYzLCJwYXRoIjoicmVsZWFzZWFzc2V0cHJvZHVjdGlvbi5ibG9iLmNvcmUud2luZG93cy5uZXQifQ.MnoJI_OSIEXOzBYGjiNkwlMEtDsXJC4WYoTJuurpwro"

# Download Bootrom
wget -O "$ASSETS_DIR/bootrom" "$BOOTROM_URL"

# Download and Extract NAND
wget -O "$ASSETS_DIR/nand.zip" "$NAND_URL"
unzip -o "$ASSETS_DIR/nand.zip" -d "$ASSETS_DIR"
rm "$ASSETS_DIR/nand.zip"

# Download NOR
wget -O "$ASSETS_DIR/nor" "$NOR_URL"

# 3. Create OpenRC service and wrapper for instant boot to screen
echo "Creating OpenRC service and wrapper for the emulator..."

# Create a wrapper script to set environment variables for SDL2
cat <<EOF > rootdir/usr/bin/start-ipod.sh
#!/bin/bash
# Force SDL to use the Linux Framebuffer/DRM for direct screen output
export SDL_VIDEODRIVER=kmsdrm
export SDL_FBDEV=/dev/fb0

# Launch emulator
exec /usr/bin/qemu-system-arm -M iPod-Touch,bootrom=/opt/ipod-emu/bootrom,nand=/opt/ipod-emu/nand,nor=/opt/ipod-emu/nor -serial mon:stdio -cpu max -m 2G -d unimp -display sdl
EOF

chmod +x rootdir/usr/bin/start-ipod.sh

# Create the OpenRC service
cat <<EOF > rootdir/etc/init.d/ipod-emu
#!/sbin/openrc-run
description="iPod Touch 2G Emulator - Direct to Screen"

command="/usr/bin/start-ipod.sh"
command_background="no"

depend() {
    need net
    after firewall
}
EOF

chmod +x rootdir/etc/init.d/ipod-emu

# Enable service in default runlevel
mkdir -p rootdir/etc/runlevels/default
ln -sf /etc/init.d/ipod-emu rootdir/etc/runlevels/default/ipod-emu

echo "[$(date +'%Y-%m-%d %H:%M:%S')] [17] ✅ Emulator binary and assets installation completed"
