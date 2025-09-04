# BookWorm VNC Container

A Docker container based on Debian Bookworm with VNC server, noVNC web interface, VSCode, and Chromium browser.

## Features

- **Base**: Debian Bookworm (slim)
- **Desktop Environment**: XFCE4
- **VNC Server**: TightVNC
- **Web Interface**: noVNC (browser-based VNC client)
- **Applications**:
  - Visual Studio Code
  - Chromium browser
  - Firefox ESR
  - Git, Vim, Nano

## System Requirements

**Recommended Memory**: 1GB RAM minimum
- VSCode requires 650-700MB RAM
- Firefox browser uses 80-150MB RAM
- Additional memory needed for XFCE desktop and other processes

## Build and Run

### Using Docker Compose (Recommended)

```bash
docker-compose up -d --build
```

### Using Docker directly

```bash
# Build the image
docker build -t bookworm-vnc .

# Run the container
docker run -d \
  --name bookworm-vnc \
  -p 5901:5901 \
  -p 6080:6080 \
  -v $(pwd)/workspace:/home/developer/workspace \
  bookworm-vnc
```

## Access

### noVNC Web Interface
Open your browser and go to: `http://localhost:6080/vnc.html`

### VNC Client
- **Host**: `localhost`
- **Port**: `5901`
- **Password**: `developer`

## User Credentials

- **Username**: `developer`
- **Password**: `developer`

## Ports

- **5901**: VNC server port
- **6080**: noVNC web interface port

## Workspace

The `./workspace` directory is mounted to `/home/developer/workspace` inside the container for persistent file storage.

## Environment Variables

- `VNC_RESOLUTION`: Screen resolution (default: 1920x1080)
- `VNC_COL_DEPTH`: Color depth (default: 24)
- `VNC_PORT`: VNC server port (default: 5901)
- `NO_VNC_PORT`: noVNC web port (default: 6080)