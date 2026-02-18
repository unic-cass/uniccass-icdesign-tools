#!/bin/bash

echo "Starting personal configuration..."

# Xschem configuration
echo "Xschem configuration file"

# check if xschemrc file exists and remove it if it does
FILE="/home/designer/.xschem/xschemrc"
if [ -f "$FILE" ]; then
    rm $FILE
fi

# Create a new xschemrc file with personal configuration
cp /home/designer/shared/config/xschemrc /home/designer/.xschem/xschemrc

# Modifying .bashrc to add alias for xschem
echo "modifying alias in .bashrc"
echo "" >> /home/designer/.bashrc
echo "# Alias for xschem with custom configuration" >> /home/designer/.bashrc
echo "alias xschem='xschem --rcfile ~/.xschem/xschemrc'" >> /home/designer/.bashrc


exec /bin/bash -i