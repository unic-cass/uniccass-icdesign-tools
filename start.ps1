# Variables
$PDK = "sky130A"
$SharedDir = (Resolve-Path .\shared_xserver).Path
$SharedDirHash = (Get-FileHash -Algorithm SHA256 -Path ($env:TEMP + "\hash.txt") -ErrorAction SilentlyContinue).Hash
$ContainerName = "usm-vlsi-tools-" + $SharedDirHash
$DockerImage = "akilesalreadytaken/usm-vlsi-tools:latest"

# Docker run
docker run -it --rm `
    --mount type=bind,source="$SharedDir",target=/home/designer/shared `
    --user 1000:1000 `
    -e SHELL=/bin/bash `
    -e PDK=$PDK `
    -e DISPLAY=host.docker.internal:0 `
    -e LIBGL_ALWAYS_INDIRECT=1 `
    -e XDG_RUNTIME_DIR `
    -e PULSE_SERVER `
    -p 8888:8888 `
    --name "$ContainerName" `
    $DockerImage