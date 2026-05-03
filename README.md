# Plugin Builder - Pterodactyl Egg

Premium build system for Java developers to build plugins across multiple Java versions.

## Features
- **Multi-Java Support**: Switch between Java 8, 11, 17, 21, 23, and 25 (EA).
- **Auto-Detection**: Automatically detects if the project is Maven or Gradle.
- **Smart Organization**:
  - Upload `.zip` source to `/files/file/`
  - Get built `.jar` from `/files/hasil/`
- **Detailed Logging**: Every build session is logged to `/logs/<plugin_name>.log` for easy troubleshooting.
- **Premium UI**: Interactive console with real-time status and formatted information.

## Installation
1. **Docker Image**: Build the provided `Dockerfile` and push it to your registry.
2. **Egg Import**: Import `egg-plugin-builder.json` into your Pterodactyl panel.
3. **Setup**:
   - Ensure `builder.sh` is present in the server root.
   - The installation script in the JSON will try to download it, or you can manually upload it.

## How to Build
1. Upload your project source code as a **.zip** file to the folder `files/file/`.
2. Open the server console.
3. Select **2. Build Plugin**.
4. Wait for the build to finish.
5. Download your compiled plugin from `files/hasil/`.

## Switching Java
1. Select **1. Ubah Java**.
2. Pick your desired version.
3. The console will refresh with the new environment settings.

---
Created by YuraCloud
