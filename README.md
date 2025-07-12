# Tunnelzi - Tunnel Management Tool

Tunnelzi is a Bash script designed to create, manage, and run various types of network tunnels as systemd services on Ubuntu. It supports multiple tunneling protocols, including Backhaul, SSH, Socat, WireGuard, OpenVPN, GRE, HTTP/HTTPS (via stunnel), and V2Ray/Vmess. This script automates the installation of dependencies and ensures tunnels run reliably as services.

## Table of Contents

- [Features](#features)
- [Supported Tunnel Types](#supported-tunnel-types)
- [Dependencies and Resources](#dependencies-and-resources)
- [Installation](#installation)
- [Usage](#usage)
- [Commands](#commands)
- [Prerequisites](#prerequisites)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
- [License](#license)

## Features

- Create and manage multiple types of network tunnels.
- Automatic installation of required dependencies (e.g., `wireguard-tools`, `openvpn`, `stunnel4`).
- Automatic download of tools like Backhaul, ngrok, and V2Ray from their respective repositories if not present.
- Run tunnels as systemd services for reliability and auto-start on boot.
- Easy-to-use command-line interface with support for creating, listing, starting, stopping, enabling, disabling, and deleting tunnels.

## Supported Tunnel Types

- **Backhaul**: A lightweight tunneling tool for forwarding local ports to a remote server.
- **SSH Reverse Tunnel**: Creates a reverse SSH tunnel to expose a local service to a remote server.
- **SSH Local Tunnel**: Forwards a remote service to a local port via SSH.
- **SSH Dynamic SOCKS5 Tunnel**: Creates a SOCKS5 proxy via SSH.
- **Socat TCP Tunnel**: Forwards TCP traffic using the `socat` utility.
- **WireGuard**: A modern, fast VPN protocol for secure tunneling.
- **OpenVPN**: A popular VPN solution for secure client-server communication.
- **GRE**: A layer 3 tunneling protocol without encryption.
- **HTTP/HTTPS (stunnel)**: Secure tunneling for HTTP/HTTPS traffic using `stunnel`.
- **V2Ray/Vmess**: A modern proxy protocol with advanced features.

## Dependencies and Resources

Tunnelzi relies on several open-source tools and libraries. Below are the key dependencies and their respective repositories:

- **Backhaul**: Used for Backhaul tunnels. Downloaded from [mmarczuk/go-http-tunnel](https://github.com/mmatczuk/go-http-tunnel).
- **V2Ray**: Used for V2Ray/Vmess tunnels. Downloaded from [v2fly/v2ray-core](https://github.com/v2fly/v2ray-core).
- **ngrok**: Optionally used for HTTP/HTTPS tunnels (not used in the current script but included for future compatibility). Available at [ngrok/ngrok](https://github.com/ngrok/ngrok).
- **WireGuard**: Uses `wireguard-tools` for WireGuard tunnels. Available in Ubuntu repositories.
- **OpenVPN**: Uses `openvpn` for VPN tunnels. Available in Ubuntu repositories.
- **stunnel**: Used for HTTP/HTTPS tunnels. Available in Ubuntu repositories as `stunnel4`.
- **socat**: Used for TCP tunnels. Available in Ubuntu repositories.
- **iproute2**: Used for GRE tunnels. Available in Ubuntu repositories.

The script automatically downloads Backhaul and V2Ray if not present and installs other dependencies via `apt`.

## Installation

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/majid-rnz/Tunnelzi.git
   cd Tunnelzi
   ```

2. **Make the Script Executable**:
   ```bash
   chmod +x tunnelzi.sh
   ```

3. **Move the Script to a System Path**:
   ```bash
   sudo mv tunnelzi.sh /usr/local/bin/tunnelzi
   ```

4. **Ensure Internet Access**: The script will download dependencies like Backhaul ([mmarczuk/go-http-tunnel](https://github.com/mmatczuk/go-http-tunnel)) and V2Ray ([v2fly/v2ray-core](https://github.com/v2fly/v2ray-core)) if they are not installed. Ensure your system has internet access.

## Usage

Run the script with `sudo` as it requires root privileges to manage systemd services and install dependencies:

```bash
sudo tunnelzi <command> [options]
```

### Commands

- **`create`**: Create a new tunnel. Prompts for tunnel type and configuration details.
  ```bash
  sudo tunnelzi create
  ```
- **`list`**: List all configured tunnels and their status (active/inactive).
  ```bash
  sudo tunnelzi list
  ```
- **`delete NAME`**: Delete a tunnel and its associated files.
  ```bash
  sudo tunnelzi delete my-tunnel
  ```
- **`start NAME`**: Start a tunnel service.
  ```bash
  sudo tunnelzi start my-tunnel
  ```
- **`stop NAME`**: Stop a tunnel service.
  ```bash
  sudo tunnelzi stop my-tunnel
  ```
- **`enable NAME`**: Enable a tunnel to start on system boot.
  ```bash
  sudo tunnelzi enable my-tunnel
  ```
- **`disable NAME`**: Disable a tunnel from starting on system boot.
  ```bash
  sudo tunnelzi disable my-tunnel
  ```
- **`help`**: Display the help message with available commands.
  ```bash
  sudo tunnelzi help
  ```

## Prerequisites

- **Operating System**: Ubuntu (or a Debian-based distribution).
- **Root Access**: The script must be run with `sudo`.
- **Internet Access**: Required for downloading dependencies like Backhaul and V2Ray.
- **Specific Requirements**:
  - **WireGuard**: Generate private and public keys using `wg genkey` and `wg pubkey`.
  - **OpenVPN**: A valid `.ovpn` configuration file is required.
  - **V2Ray**: A valid UUID for the Vmess protocol (generate with `uuidgen`).
  - **GRE**: The `ip_gre` kernel module must be enabled (`modprobe ip_gre`).
  - **SSH Tunnels**: Valid SSH keys and access to the remote server.

## Troubleshooting

- **Check Service Status**:
  ```bash
  sudo systemctl status tunnelzi-<name>.service
  ```
- **View Logs**:
  ```bash
  sudo journalctl -u tunnelzi-<name>.service
  ```
- **Common Issues**:
  - **Missing Dependencies**: Ensure internet access for automatic installation of tools like Backhaul and V2Ray.
  - **Permission Errors**: Run the script with `sudo`.
  - **WireGuard/OpenVPN/V2Ray Failures**: Verify configuration details (e.g., keys, server addresses).
  - **GRE Tunnels**: Ensure the remote server is configured to accept GRE traffic.

## Contributing

Contributions are welcome! Please fork the repository, make your changes, and submit a pull request. For bug reports or feature requests, open an issue on the [GitHub repository](https://github.com/majid-rnz/Tunnelzi).

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

# Tunnelzi - ابزار مدیریت تونل

Tunnelzi یک اسکریپت Bash است که برای ایجاد، مدیریت و اجرای انواع مختلف تونل‌های شبکه به‌صورت سرویس‌های systemd در اوبونتو طراحی شده است. این اسکریپت از پروتکل‌های مختلف تونل‌سازی مانند Backhaul، SSH، Socat، WireGuard، OpenVPN، GRE، HTTP/HTTPS (از طریق stunnel) و V2Ray/Vmess پشتیبانی می‌کند. این اسکریپت نصب وابستگی‌ها را به‌صورت خودکار انجام می‌دهد و اطمینان می‌دهد که تونل‌ها به‌صورت قابل اعتماد به‌عنوان سرویس اجرا شوند.

## فهرست مطالب

- [ویژگی‌ها](#ویژگی‌ها)
- [انواع تونل‌های پشتیبانی‌شده](#انواع-تونل‌های-پشتیبانی‌شده)
- [وابستگی‌ها و منابع](#وابستگی‌ها-و-منابع)
- [نصب](#نصب)
- [نحوه استفاده](#نحوه-استفاده)
- [دستورات](#دستورات)
- [پیش‌نیازها](#پیش‌نیازها)
- [عیب‌یابی](#عیب‌یابی)
- [مشارکت](#مشارکت)
- [مجوز](#مجوز)

## ویژگی‌ها

- ایجاد و مدیریت انواع مختلف تونل‌های شبکه.
- نصب خودکار وابستگی‌های موردنیاز (مانند `wireguard-tools`، `openvpn`، `stunnel4`).
- دانلود خودکار ابزارهایی مانند Backhaul، ngrok و V2Ray در صورت عدم وجود.
- اجرای تونل‌ها به‌صورت سرویس‌های systemd برای قابلیت اطمینان و شروع خودکار در بوت.
- رابط خط فرمان ساده با پشتیبانی از ایجاد، لیست، شروع، توقف، فعال‌سازی، غیرفعال‌سازی و حذف تونل‌ها.

## انواع تونل‌های پشتیبانی‌شده

- **Backhaul**: ابزاری سبک برای فوروارد کردن پورت‌های محلی به سرور ریموت.
- **تونل معکوس SSH**: یک تونل SSH معکوس برای نمایش سرویس‌های محلی به سرور ریموت.
- **تونل محلی SSH**: فوروارد کردن سرویس‌های ریموت به پورت محلی از طریق SSH.
- **تونل دینامیک SOCKS5 SSH**: ایجاد یک پروکسی SOCKS5 از طریق SSH.
- **تونل TCP Socat**: فوروارد کردن ترافیک TCP با استفاده از ابزار `socat`.
- **WireGuard**: یک پروتکل VPN مدرن و سریع برای تونل‌سازی امن.
- **OpenVPN**: یک راه‌حل محبوب VPN برای ارتباطات امن کلاینت-سرور.
- **GRE**: یک پروتکل تونل‌سازی لایه 3 بدون رمزنگاری.
- **HTTP/HTTPS (stunnel)**: تونل‌سازی امن برای ترافیک HTTP/HTTPS با استفاده از `stunnel`.
- **V2Ray/Vmess**: یک پروتکل پروکسی مدرن با قابلیت‌های پیشرفته.

## وابستگی‌ها و منابع

Tunnelzi از چندین ابزار و کتابخانه متن‌باز استفاده می‌کند. در زیر وابستگی‌های کلیدی و ریپازیتوری‌های مربوطه آورده شده‌اند:

- **Backhaul**: برای تونل‌های Backhaul استفاده می‌شود. از [mmarczuk/go-http-tunnel](https://github.com/mmatczuk/go-http-tunnel) دانلود می‌شود.
- **V2Ray**: برای تونل‌های V2Ray/Vmess استفاده می‌شود. از [v2fly/v2ray-core](https://github.com/v2fly/v2ray-core) دانلود می‌شود.
- **ngrok**: به‌صورت اختیاری برای تونل‌های HTTP/HTTPS (در نسخه فعلی استفاده نشده، اما برای سازگاری آینده در نظر گرفته شده است). در [ngrok/ngrok](https://github.com/ngrok/ngrok) موجود است.
- **WireGuard**: از `wireguard-tools` برای تونل‌های WireGuard استفاده می‌کند. در مخازن اوبونتو موجود است.
- **OpenVPN**: از `openvpn` برای تونل‌های VPN استفاده می‌کند. در مخازن اوبونتو موجود است.
- **stunnel**: برای تونل‌های HTTP/HTTPS استفاده می‌شود. به‌عنوان `stunnel4` در مخازن اوبونتو موجود است.
- **socat**: برای تونل‌های TCP استفاده می‌شود. در مخازن اوبونتو موجود است.
- **iproute2**: برای تونل‌های GRE استفاده می‌شود. در مخازن اوبونتو موجود است.

اسکریپت به‌صورت خودکار Backhaul و V2Ray را در صورت عدم وجود دانلود می‌کند و سایر وابستگی‌ها را از طریق `apt` نصب می‌کند.

## نصب

1. **کلون کردن ریپازیتوری**:
   ```bash
   git clone https://github.com/majid-rnz/Tunnelzi.git
   cd Tunnelzi
   ```

2. **ایجاد مجوز اجرایی برای اسکریپت**:
   ```bash
   chmod +x tunnelzi.sh
   ```

3. **انتقال اسکریپت به مسیر سیستمی**:
   ```bash
   sudo mv tunnelzi.sh /usr/local/bin/tunnelzi
   ```

4. **اطمینان از دسترسی به اینترنت**: اسکریپت وابستگی‌هایی مانند Backhaul ([mmarczuk/go-http-tunnel](https://github.com/mmatczuk/go-http-tunnel)) و V2Ray ([v2fly/v2ray-core](https://github.com/v2fly/v2ray-core)) را در صورت عدم وجود دانلود می‌کند. اطمینان حاصل کنید که سیستم شما به اینترنت متصل است.

## نحوه استفاده

اسکریپت را با `sudo` اجرا کنید، زیرا نیاز به دسترسی ریشه برای مدیریت سرویس‌های systemd و نصب وابستگی‌ها دارد:

```bash
sudo tunnelzi <دستور> [گزینه‌ها]
```

### دستورات

- **`create`**: ایجاد یک تونل جدید. از کاربر نوع تونل و جزئیات تنظیمات را درخواست می‌کند.
  ```bash
  sudo tunnelzi create
  ```
- **`list`**: نمایش تمام تونل‌های پیکربندی‌شده و وضعیت آن‌ها (فعال/غیرفعال).
  ```bash
  sudo tunnelzi list
  ```
- **`delete NAME`**: حذف یک تونل و فایل‌های مرتبط با آن.
  ```bash
  sudo tunnelzi delete my-tunnel
  ```
- **`start NAME`**: شروع یک سرویس تونل.
  ```bash
  sudo tunnelzi start my-tunnel
  ```
- **`stop NAME`**: توقف یک سرویس تونل.
  ```bash
  sudo tunnelzi stop my-tunnel
  ```
- **`enable NAME`**: فعال‌سازی یک تونل برای شروع خودکار در بوت سیستم.
  ```bash
  sudo tunnelzi enable my-tunnel
  ```
- **`disable NAME`**: غیرفعال‌سازی یک تونل از شروع خودکار در بوت سیستم.
  ```bash
  sudo tunnelzi disable my-tunnel
  ```
- **`help`**: نمایش پیام راهنما با دستورات موجود.
  ```bash
  sudo tunnelzi help
  ```

## پیش‌نیازها

- **سیستم‌عامل**: اوبونتو (یا توزیع‌های مبتنی بر دبیان).
- **دسترسی ریشه**: اسکریپت باید با `sudo` اجرا شود.
- **دسترسی به اینترنت**: برای دانلود وابستگی‌ها مانند Backhaul و V2Ray موردنیاز است.
- **نیازمندی‌های خاص**:
  - **WireGuard**: تولید کلیدهای خصوصی و عمومی با استفاده از `wg genkey` و `wg pubkey`.
  - **OpenVPN**: نیاز به فایل تنظیمات `.ovpn` معتبر.
  - **V2Ray**: نیاز به UUID معتبر برای پروتکل Vmess (با `uuidgen` تولید کنید).
  - **GRE**: ماژول کرنل `ip_gre` باید فعال باشد (`modprobe ip_gre`).
  - **تونل‌های SSH**: نیاز به کلیدهای SSH معتبر و دسترسی به سرور ریموت.

## عیب‌یابی

- **بررسی وضعیت سرویس**:
  ```bash
  sudo systemctl status tunnelzi-<name>.service
  ```
- **مشاهده لاگ‌ها**:
  ```bash
  sudo journalctl -u tunnelzi-<name>.service
  ```
- **مشکلات رایج**:
  - **عدم وجود وابستگی‌ها**: اطمینان حاصل کنید که به اینترنت متصل هستید تا نصب خودکار ابزارهایی مانند Backhaul و V2Ray انجام شود.
  - **خطاهای مجوز**: اسکریپت را با `sudo` اجرا کنید.
  - **خطاهای WireGuard/OpenVPN/V2Ray**: جزئیات تنظیمات (مانند کلیدها، آدرس‌های سرور) را بررسی کنید.
  - **تونل‌های GRE**: اطمینان حاصل کنید که سرور ریموت برای پذیرش ترافیک GRE پیکربندی شده است.

## مشارکت

مشارکت‌ها استقبال می‌شوند! لطفاً ریپازیتوری را فورک کنید، تغییرات خود را اعمال کنید و یک درخواست کش (pull request) ارسال کنید. برای گزارش باگ یا درخواست ویژگی، یک مسئله (issue) در [ریپازیتوری GitHub](https://github.com/majid-rnz/Tunnelzi) باز کنید.

## مجوز

این پروژه تحت مجوز MIT منتشر شده است. برای جزئیات، فایل [LICENSE](LICENSE) را ببینید.
