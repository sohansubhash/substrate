#!/usr/bin/env zsh

# Simple Firefox CSS Theme Sync Script

set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="${0:A:h}"

# Config file
CONFIG_FILE="${SCRIPT_DIR}/.env"

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "${YELLOW}Creating .env config file...${NC}"
    cat > "$CONFIG_FILE" << 'EOF'
# Firefox Profile Path (use quotes for paths with spaces)
# Example for macOS: FIREFOX_PROFILE_PATH="/Users/username/Library/Application Support/Firefox/Profiles/xxxxxxxx.default-release"
# Example for Linux: FIREFOX_PROFILE_PATH="/home/username/.mozilla/firefox/xxxxxxxx.default-release"
FIREFOX_PROFILE_PATH=""

# Auto restart Firefox after sync (true/false)
AUTO_RESTART_FIREFOX=true
EOF
    echo -e "${RED}Please edit .env file and set your FIREFOX_PROFILE_PATH${NC}"
    exit 1
fi

# Source the config file
source "$CONFIG_FILE"

# Check if profile path is set
if [[ -z "$FIREFOX_PROFILE_PATH" ]]; then
    echo -e "${RED}FIREFOX_PROFILE_PATH not set in .env file${NC}"
    exit 1
fi

# Check if profile directory exists
if [[ ! -d "$FIREFOX_PROFILE_PATH" ]]; then
    echo -e "${RED}Firefox profile directory not found: $FIREFOX_PROFILE_PATH${NC}"
    exit 1
fi

# Check if chrome directory and userChrome.css exist in repo
if [[ ! -d "${SCRIPT_DIR}/chrome" ]]; then
    echo -e "${RED}chrome directory not found in repository${NC}"
    exit 1
fi

if [[ ! -f "${SCRIPT_DIR}/chrome/userChrome.css" ]]; then
    echo -e "${RED}userChrome.css not found in chrome directory${NC}"
    exit 1
fi

# Create chrome directory in profile if it doesn't exist
mkdir -p "${FIREFOX_PROFILE_PATH}/chrome"

# Sync the files
echo -e "${YELLOW}Syncing CSS theme...${NC}"

cp "${SCRIPT_DIR}/chrome/userChrome.css" "${FIREFOX_PROFILE_PATH}/chrome/"
echo -e "${GREEN}✓ userChrome.css synced${NC}"

# Sync modules directory
if [[ -d "${SCRIPT_DIR}/chrome/modules" ]]; then
    cp -r "${SCRIPT_DIR}/chrome/modules" "${FIREFOX_PROFILE_PATH}/chrome/"
    echo -e "${GREEN}✓ modules directory synced${NC}"
fi

# Sync userContent.css if it exists
if [[ -f "${SCRIPT_DIR}/chrome/userContent.css" ]]; then
    cp "${SCRIPT_DIR}/chrome/userContent.css" "${FIREFOX_PROFILE_PATH}/chrome/"
    echo -e "${GREEN}✓ userContent.css synced${NC}"
fi

echo -e "${GREEN}Theme sync complete!${NC}"

# Function to restart Firefox using AppleScript
restart_firefox() {
    echo -e "${BLUE}Restarting Firefox...${NC}"
    
    # Check if Firefox is running and quit it
    osascript -e '
        tell application "System Events"
            if (name of processes) contains "Firefox" then
                tell application "Firefox" to quit
                -- Wait for Firefox to fully quit
                repeat while (name of processes) contains "Firefox"
                    delay 0.5
                end repeat
                delay 1
            end if
        end tell
    ' 2>/dev/null || true
    
    # Start Firefox
    osascript -e '
        tell application "Firefox"
            activate
        end tell
    ' 2>/dev/null || {
        echo -e "${RED}Failed to restart Firefox via AppleScript${NC}"
        echo -e "${YELLOW}Please restart Firefox manually to see changes${NC}"
        return 1
    }
    
    echo -e "${GREEN}✓ Firefox restarted successfully${NC}"
}

# Handle Firefox restart
if [[ "$AUTO_RESTART_FIREFOX" == "true" ]]; then
    restart_firefox
else
    # Ask user if they want to restart Firefox
    echo -e "${YELLOW}Restart Firefox now to see changes? [y/N]${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        restart_firefox
    else
        echo -e "${YELLOW}Remember to restart Firefox to see changes${NC}"
    fi
fi
