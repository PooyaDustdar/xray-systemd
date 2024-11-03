# xray-systemd
run a xray service with systemd unit file

## git clone the project and cd to the directory
```bash
git clone https://github.com/PooyaDustdar/xray-systemd.git
cd xray-systemd
```
## run the install.sh file with sudoer user
```bash
sudo bash install.sh
```
## change the config file from this path:
```path
/etc/xray/config.json
```
# Change Xray Version
you can chnage the xray version from first line of install.sh:
```bash
version=v24.10.31
```