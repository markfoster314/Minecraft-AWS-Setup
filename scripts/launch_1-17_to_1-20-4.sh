#!/bin/bash

# Minecraft Java Edition 1.17 – 1.20.4
# Java 17 required (Amazon Corretto 17)
# Note: 1.17 / 1.17.1 officially target Java 16, but Corretto 16 is EOL and not in
# the AL2023 yum repo. Corretto 17 is backward-compatible and the recommended pick.

# *** INSERT SERVER DOWNLOAD URL BELOW ***
# Do not add any spaces between your link and the "="


MINECRAFTSERVERURL=


# Download Java (Corretto 17 LTS — required by Minecraft 1.17 – 1.20.4)
sudo yum install -y java-17-amazon-corretto-headless
# Install MC Java server in a directory we create
adduser minecraft
mkdir /opt/minecraft/
mkdir /opt/minecraft/server/
cd /opt/minecraft/server

# Download server jar file from Minecraft official website
wget $MINECRAFTSERVERURL

# Generate Minecraft server files and create script
chown -R minecraft:minecraft /opt/minecraft/
java -Xmx2G -Xms2G -jar server.jar nogui
sleep 40
sed -i 's/false/true/p' eula.txt
touch start
printf '#!/bin/bash\njava -Xmx2G -Xms2G -jar server.jar nogui\n' >> start
chmod +x start
sleep 1
touch stop
printf '#!/bin/bash\nkill -9 $(ps -ef | pgrep -f "java")' >> stop
chmod +x stop
sleep 1

# Create SystemD Script to run Minecraft server jar on reboot
cd /etc/systemd/system/
touch minecraft.service
printf '[Unit]\nDescription=Minecraft Server on start up\nWants=network-online.target\n[Service]\nUser=minecraft\nWorkingDirectory=/opt/minecraft/server\nExecStart=/opt/minecraft/server/start\nStandardInput=null\n[Install]\nWantedBy=multi-user.target' >> minecraft.service
sudo systemctl daemon-reload
sudo systemctl enable minecraft.service
sudo systemctl start minecraft.service

# End script
