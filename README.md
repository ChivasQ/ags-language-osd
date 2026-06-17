# AGS X11 Language OSD
A lightweight On-Screen Display (OSD) for keyboard layout switching, specifically for X11 environments (like XFCE) using [AGS (Aylur's GTK Shell)](https://github.com/Aylur/ags).
<p align="center">
  <img src="assets/demo.gif" alt="AGS Language OSD Demo" width="256"/>
</p>
This project utilizes low-level GTK and GDK hooks to function correctly under X11, while mitigating common X-server event spam issues.

## Dependencies
Ensure the following packages are installed on your system before deployment:
* `ags` (v1)
* `xkb-switch` (for fetching and listening to layout states)
* `xdotool` (for active window heuristics)
* A compositor (e.g., `picom` or built-in XFCE compositor) for transparency support.


### **For Void Linux:**
* **With Picom**
    ```bash
    sudo xbps-install -Su xkb-switch xdotool picom
    ```
* **Without Picom(no transparency)**
    ```bash
    sudo xbps-install -Su xkb-switch xdotool
    ```
## Installation

Clone the repository and execute the deployment script. The script will automatically configure the GJS wrapper and create necessary symlinks.

```bash
git clone https://github.com/ChivasQ/ags-language-osd.git ~/.config/ags
cd ~/.config/ags
./install.sh
```
## Execution
Once installed, start the daemon manually to verify functionality:

```bash
ags -c ~/.config/ags/config.js
```

## Autostart (XFCE)
To ensure the OSD runs automatically in the background on system boot:
1. Open **Session and Startup** (`xfce4-session-settings`).
2. Go to the **Application Autostart** tab.
3. Click **Add** and use the following parameters:
    * **Name:** AGS Language OSD
    * **Command:** `ags -c /home/<YOUR_USERNAME>/.config/ags/config.js`
    * **Trigger:** on login

## Configuration

To modify the displayed language names (e.g., translating "US" to "English"), edit the `layoutNames` dictionary inside `config.js`.

To adjust visual parameters, colors, borders, or animations, modify the `.osd-container-lang` and `.osd-lang` classes within `style.css`.