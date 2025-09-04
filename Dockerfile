FROM debian:bookworm-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV NO_VNC_PORT=6080
ENV VNC_RESOLUTION=1920x1080
ENV VNC_COL_DEPTH=24

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    gnupg2 \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    supervisor \
    xfce4 \
    xfce4-goodies \
    tightvncserver \
    novnc \
    websockify \
    dbus-x11 \
    firefox-esr \
    chromium \
    git \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Install VSCode
RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg && \
    install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
    apt-get update && \
    apt-get install -y code && \
    rm -rf /var/lib/apt/lists/*

# Create VS Code wrapper script with --no-sandbox flag
RUN echo '#!/bin/bash\nexec /usr/bin/code --no-sandbox "$@"' > /usr/local/bin/code && \
    chmod +x /usr/local/bin/code

# Update VS Code desktop file to use --no-sandbox flag
RUN sed -i 's|Exec=/usr/share/code/code|Exec=/usr/share/code/code --no-sandbox|g' /usr/share/applications/code.desktop

# Create user
RUN useradd -m -s /bin/bash developer && \
    echo "developer:developer" | chpasswd && \
    usermod -aG sudo developer

# Setup VNC
USER developer
WORKDIR /home/developer

# Configure VNC server
RUN mkdir -p /home/developer/.vnc && \
    echo "developer" | vncpasswd -f > /home/developer/.vnc/passwd && \
    chmod 600 /home/developer/.vnc/passwd

# Create VNC startup script
RUN echo '#!/bin/bash\n\
xrdb $HOME/.Xresources\n\
startxfce4 &\n' > /home/developer/.vnc/xstartup && \
    chmod +x /home/developer/.vnc/xstartup

# Switch back to root for final setup
USER root

# Create supervisor configuration
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Create startup script
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Clean up any existing VNC processes\n\
su - developer -c "vncserver -kill :1" 2>/dev/null || true\n\
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1\n\
\n\
# Start VNC server\n\
su - developer -c "vncserver :1 -geometry $VNC_RESOLUTION -depth $VNC_COL_DEPTH"\n\
\n\
# Wait for VNC server to start\n\
sleep 3\n\
\n\
# Start noVNC\n\
exec websockify --web=/usr/share/novnc/ $NO_VNC_PORT localhost:$VNC_PORT\n' > /start.sh && \
    chmod +x /start.sh

# Expose ports
EXPOSE 5901 6080

# Start services
CMD ["/start.sh"]