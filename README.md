# Xray Systemd Service Manager

A comprehensive solution for managing Xray as a systemd service on Linux systems with enhanced security features.

## Features

- Automated installation and configuration of Xray
- Secure systemd service configuration with hardened security policies
- Subscription management with JSON configuration
- Automatic service recovery and logging
- Enhanced system security through kernel and process isolation

## Prerequisites

- Linux system with systemd
- Root or sudo privileges
- Required packages:
  - `curl`
  - `wget`
  - `unzip`
  - `jq` (for subscription management)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/PooyaDustdar/xray-systemd.git
cd xray-systemd
```

2. Install the service:
```bash
sudo bash install.sh
```

The installer will:
- Download and install Xray
- Create necessary directories and users
- Configure systemd service with security enhancements
- Start and enable the Xray service

## Configuration

### Basic Configuration
The main configuration file is located at:
```
/etc/xray/config.json
```

### Changing Xray Version
You can modify the Xray version in `install.sh`:
```bash
version=v24.10.31
```

### Subscription Management
The `xray-sub.sh` script provides subscription management features:

```bash
# Using with command line arguments
sudo bash xray-sub.sh -u <subscription_url> -o /etc/xray/config.json

# Or run interactively
sudo bash xray-sub.sh
```

Options:
- `-u`: Subscription URL
- `-o`: Output configuration file (default: /etc/xray/config.json)
- `-h`: Show help message

## Service Management

Common systemd commands for managing Xray:

```bash
# Check service status
sudo systemctl status xray

# Start the service
sudo systemctl start xray

# Stop the service
sudo systemctl stop xray

# Restart the service
sudo systemctl restart xray

# View logs
sudo journalctl -u xray
```

## Security Features

The service is configured with enhanced security measures:
- Process isolation and capability restrictions
- Secure memory management
- Protected system and kernel access
- Network capability controls
- Temporary directory isolation
- Restricted file system access

## Troubleshooting

1. Check service status:
```bash
sudo systemctl status xray
```

2. View logs:
```bash
sudo journalctl -u xray -n 50 --no-pager
```

3. Verify configuration:
```bash
/usr/bin/xray/xray -test -config=/etc/xray/config.json
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit pull requests.

## Support

If you encounter any issues or have questions:
1. Check the [issues](https://github.com/PooyaDustdar/xray-systemd/issues) page
2. Review the logs using journalctl
3. Open a new issue with detailed information about your problem

## Acknowledgments

- [Xray Core Project](https://github.com/XTLS/Xray-core)
- Systemd security hardening guidelines
- Linux system administration best practices