#!/bin/bash

# Clear the terminal
clear

# Path to the Fastfetch configuration file
CONFIG_FILE="$HOME/.config/fastfetch/config.jsonc"

# Path to the file from which to pick a random line
SOURCE_FILE="$HOME/Nextcloud/Phone/Download/Notes Graph/pages/Obsidian Vault/splashes.md"

# Check if the source file exists
if [ ! -f "$SOURCE_FILE" ]; then
  echo "Source file not found: $SOURCE_FILE"
  exit 1
fi

# Get the random line with shuf
RANDOM_LINE=$(shuf -n 1 "$SOURCE_FILE")

# Escape any special characters in the random line for use in sed
ESCAPED_LINE=$(printf '%s\n' "$RANDOM_LINE" | sed 's/[]\/$*.^[]/\\&/g')

# Add indentation (e.g., 4 spaces) and wrap the line in quotes, ensuring it includes a comma
INDENTATION="    "
FORMATTED_LINE="${INDENTATION}\"format\": \"$ESCAPED_LINE\"," # Added escape for ending quotes

# Replace line 30 in the Fastfetch config with the formatted line
LINE_NUMBER=26                                              # Target line number for the random lin1
sed -i "${LINE_NUMBER}s/.*/$FORMATTED_LINE/" "$CONFIG_FILE" # Create a backup of the original config file

# Translate the random line to Japanese and capture the last line of the output
TRANSLATED_LINE=$(trans -b -no-auto :ja "$RANDOM_LINE" | tail -n 1 | iconv -f UTF-8 -t UTF-8)

# Escape any special characters in the translated line for use in sed
ESCAPED_TRANSLATED_LINE=$(printf '%s\n' "$TRANSLATED_LINE" | sed 's/[]\/$*.^[]/\\&/g' | tr -d '\r\n' | tr -d '\000-\037')

# Remove any control characters from the translated line
ESCAPED_TRANSLATED_LINE=$(echo "$ESCAPED_TRANSLATED_LINE" | tr -d '\r\n' | tr -d '\000-\037')

# Add indentation and wrap the translated line in quotes, ensuring it includes a comma
FORMATTED_TRANSLATED_LINE="${INDENTATION}\"format\": \"$ESCAPED_TRANSLATED_LINE\"," # Added escape for ending quotes

# Replace line 28 in the Fastfetch config with the translated line
TRANSLATED_LINE_NUMBER=22                                                         # Target line number for the Japanese translation
sed -i "${TRANSLATED_LINE_NUMBER}s/.*/$FORMATTED_TRANSLATED_LINE/" "$CONFIG_FILE" # Create a backup of the original config file

# Put the image into the fastfetch script
~/.config/fastfetch/ascii-image-converter ~/.config/fastfetch/image.jpg -b -d 40,17 >/home/simon/.config/fastfetch/image.txt

# Run Fastfetch to show the updated configuration
fastfetch
