#!/bin/sh
cd /mnt/mmc/Roms/APPS/PokeMMO/

# Set Java home and update PATH
export JAVA_HOME=/mnt/mmc/Roms/APPS/PokeMMO/java
export PATH="$JAVA_HOME/bin:$PATH"

# Function to check if X server is running
is_x_running() {
    if pgrep Xorg > /dev/null 2>&1; then
        return 0  # X server is running
    else
        return 1  # X server is not running
    fi
}

# Function to start X server
start_x_server() {
    echo "Starting X server..."

    # Create a minimal xinitrc file to run Openbox and your game
    XINITRC=$(mktemp)
    cat > "$XINITRC" << EOF
#!/bin/sh
# Start Openbox window manager
openbox &
# Run the game
cd /mnt/mmc/Roms/APPS/PokeMMO/
export JAVA_HOME=/mnt/mmc/Roms/APPS/PokeMMO/java
export PATH="\$JAVA_HOME/bin:\$PATH"
java -Xmx384M -Dfile.encoding="UTF-8" -cp PokeMMO.exe com.pokeemu.client.Client
EOF
    chmod +x "$XINITRC"

    # Start X server using xinit
    xinit "$XINITRC" -- :0 vt$(fgconsole) &

    # Wait a few seconds to ensure X server starts
    sleep 5
}

# Check if X server is running
if ! is_x_running; then
    # Start X server
    start_x_server

    # Check again if X server is running
    if ! is_x_running; then
        echo "Failed to start X server. Exiting."
        exit 1
    fi
fi

# Set DISPLAY variable if necessary
if [ -z "$DISPLAY" ]; then
    export DISPLAY=:0
fi

# Function to check if X server is running
is_x_running() {
    if pgrep Xorg > /dev/null 2>&1; then
        return 0  # X server is running
    else
        return 1  # X server is not running
    fi
}

# Start X server if not running
if ! is_x_running; then
    echo "X server not running. Attempting to start X server..."
    startx &
    sleep 5  # Give X server time to start
    if ! is_x_running; then
        echo "Failed to start X server. Exiting script."
        exit 1
    fi
else
    echo "X server is already running."
fi

# Set DISPLAY variable if necessary
if [ -z "$DISPLAY" ]; then
    echo "Setting DISPLAY variable..."
    export DISPLAY=:0
fi

# Run the game
echo "Running the game..."
java -Xmx384M -Dfile.encoding="UTF-8" -cp PokeMMO.exe com.pokeemu.client.Client \
    > /mnt/mmc/Roms/APPS/PokeMMO/log.txt 2>&1

echo "Script execution completed."
