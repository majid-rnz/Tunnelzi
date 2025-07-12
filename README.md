# Tunnelzi - Tunnel Management Tool

## English

**Tunnelzi** is a Bash script designed to simplify the creation, management, and automation of various types of network tunnels on Linux systems. It supports multiple tunnel types, including Backhaul, SSH-based tunnels (Reverse, Local, and Dynamic SOCKS5), and Socat TCP tunnels. The tool integrates with `systemd` to manage tunnels as services, enabling automatic restarts and boot-time execution.

### Features
- **Create Tunnels**: Easily set up Backhaul, SSH Reverse, SSH Local, SSH Dynamic SOCKS5, or Socat TCP tunnels.
- **Manage Tunnels**: Start, stop, enable, or disable tunnels using `systemd`.
- **List Tunnels**: View all configured tunnels and their status (active/inactive).
- **Delete Tunnels**: Remove tunnels and their associated configurations and services.
- **Dependency Check**: Automatically checks and installs required dependencies (`ssh`, `socat`) if run with root privileges.
- **Systemd Integration**: Creates `systemd` service files for reliable tunnel management.
- **User-Friendly**: Interactive prompts guide users through tunnel creation and configuration.

### Prerequisites
- A Linux system with `bash` and `systemd`.
- Root privileges for installing dependencies and managing `systemd` services.
- For Backhaul tunnels, the `backhaul` binary must be installed at `/usr/local/bin/backhaul`. Source: [Musixal/Backhaul](https://github.com/Musixal/Backhaul).
- For SSH-based tunnels, an SSH server and client (`openssh-client`) are required.
- For Socat tunnels, the `socat` package is required.

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/majid-rnz/Tunnelzi.git
   cd Tunnelzi
   ```
2. Copy the script to a system-wide location and make it executable:
   ```bash
   sudo cp tunnelzi /usr/local/bin/tunnelzi
   sudo chmod +x /usr/local/bin/tunnelzi
   ```
3. Ensure the required directory exists:
   ```bash
   sudo mkdir -p /etc/tunnelzi/tunnels
   ```

### Usage
Run the `tunnelzi` command with one of the following subcommands:

```bash
tunnelzi [create | list | delete | start | stop | enable | disable | help]
```

#### Commands
- **`create`**: Create a new tunnel. Prompts for tunnel type and configuration details.
- **`list`**: List all configured tunnels and their status.
- **`delete NAME`**: Delete a tunnel and its associated `systemd` service.
- **`start NAME`**: Start a tunnel service.
- **`stop NAME`**: Stop a tunnel service.
- **`enable NAME`**: Enable a tunnel to start on boot.
- **`disable NAME`**: Disable a tunnel from starting on boot.
- **`help`**: Display the help message with usage instructions.

#### Example
To create an SSH Reverse Tunnel:
```bash
sudo tunnelzi create
```
1. Select option `2` for SSH Reverse Tunnel.
2. Enter a unique tunnel name (e.g., `my-tunnel`).
3. Provide the remote server (e.g., `user@remote.com`), remote port (e.g., `8080`), and local port (e.g., `80`).
4. The script generates a `systemd` service and configuration files in `/etc/tunnelzi/tunnels`.

To start the tunnel:
```bash
sudo tunnelzi start my-tunnel
```

To enable the tunnel on boot:
```bash
sudo tunnelzi enable my-tunnel
```

### Tunnel Types
1. **Backhaul Tunnel**: Uses the `backhaul` binary to forward traffic from a local port to a remote server. Source: [Musixal/Backhaul](https://github.com/Musixal/Backhaul).
2. **SSH Reverse Tunnel**: Exposes a local port to a remote server via SSH.
3. **SSH Local Tunnel**: Forwards a local port to a remote server's port via SSH.
4. **SSH Dynamic SOCKS5 Tunnel**: Creates a SOCKS5 proxy for dynamic port forwarding via SSH.
5. **Socat TCP Tunnel**: Uses `socat` to forward traffic between a local port and a target IP:port.

### Configuration
- **Tunnel Configurations**: Stored in `/etc/tunnelzi/tunnels/`.
  - Shell scripts (`.sh`) for tunnel execution.
  - TOML files (`.toml`) for Backhaul tunnel configurations.
- **Systemd Services**: Stored in `/etc/systemd/system/` as `tunnelzi-<name>.service`.

### Notes
- Run commands with `sudo` when root privileges are required (e.g., for installing dependencies or managing `systemd` services).
- Ensure the `backhaul` binary is installed for Backhaul tunnels. It must be located at `/usr/local/bin/backhaul`. Source: [Musixal/Backhaul](https://github.com/Musixal/Backhaul).
- SSH-based tunnels require valid SSH credentials and access to the remote server.
- Socat tunnels require the `socat` package to be installed.
- If a tunnel fails to start, check the `systemd` service logs:
  ```bash
  sudo journalctl -u tunnelzi-<name>.service
  ```

### Troubleshooting
- **Dependency Installation Fails**: Ensure you have an active internet connection and sufficient permissions (`sudo`).
- **Tunnel Not Starting**: Verify the configuration details (e.g., server address, ports) and check `systemd` logs.
- **Backhaul Binary Missing**: Install the `backhaul` binary manually from [Musixal/Backhaul](https://github.com/Musixal/Backhaul) and place it in `/usr/local/bin/backhaul`.
- **Permission Denied**: Run commands with `sudo` when prompted.

### Contributing
Contributions are welcome! Please follow these steps:
1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes and commit (`git commit -m "Add feature"`).
4. Push your changes to the branch on the remote repository (`git push origin feature-branch`).
5. Open a Pull Request.

### License
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

### Acknowledgments
- Built with Bash for simplicity and portability.
- Integrates with `systemd` for robust service management.
- Supports multiple tunnel types for flexibility in network configurations.
- Utilizes the Backhaul project for advanced tunneling capabilities: [Musixal/Backhaul](https://github.com/Musixal/Backhaul).

---

## فارسی

**تونلزی** یک اسکریپت بش است که برای ساده‌سازی ایجاد، مدیریت و خودکارسازی انواع مختلف تونل‌های شبکه در سیستم‌های لینوکس طراحی شده است. این ابزار از انواع تونل‌های متعدد، از جمله بک‌هال، تونل‌های مبتنی بر SSH (معکوس، محلی و SOCKS5 داینامیک) و تونل‌های TCP Socat پشتیبانی می‌کند. این ابزار با `systemd` یکپارچه شده است تا تونل‌ها را به عنوان سرویس مدیریت کند و امکان راه‌اندازی مجدد خودکار و اجرا در زمان بوت را فراهم آورد.

### ویژگی‌ها
- **ایجاد تونل‌ها**: به راحتی تونل‌های بک‌هال، SSH معکوس، SSH محلی، SOCKS5 داینامیک یا TCP Socat را راه‌اندازی کنید.
- **مدیریت تونل‌ها**: با استفاده از `systemd` تونل‌ها را راه‌اندازی، متوقف، فعال یا غیرفعال کنید.
- **لیست تونل‌ها**: تمام تونل‌های پیکربندی‌شده و وضعیت آنها (فعال/غیرفعال) را مشاهده کنید.
- **حذف تونل‌ها**: تونل‌ها و پیکربندی‌ها و سرویس‌های مرتبط با آنها را حذف کنید.
- **بررسی وابستگی‌ها**: در صورت اجرا با دسترسی ریشه، به طور خودکار وابستگی‌های مورد نیاز (`ssh`، `socat`) را بررسی و نصب می‌کند.
- **یکپارچگی با Systemd**: فایل‌های سرویس `systemd` را برای مدیریت قابل اعتماد تونل‌ها ایجاد می‌کند.
- **کاربرپسند**: اعلان‌های تعاملی کاربران را در ایجاد و پیکربندی تونل‌ها راهنمایی می‌کنند.

### پیش‌نیازها
- یک سیستم لینوکس با `bash` و `systemd`.
- دسترسی ریشه برای نصب وابستگی‌ها و مدیریت سرویس‌های `systemd`.
- برای تونل‌های بک‌هال، باینری `backhaul` باید در `/usr/local/bin/backhaul` نصب شود. منبع: [Musixal/Backhaul](https://github.com/Musixal/Backhaul).
- برای تونل‌های مبتنی بر SSH، سرور و کلاینت SSH (`openssh-client`) مورد نیاز است.
- برای تونل‌های Socat، بسته `socat` مورد نیاز است.

### نصب
1. کلون کردن مخزن:
   ```bash
   git clone https://github.com/majid-rnz/Tunnelzi.git
   cd Tunnelzi
   ```
2. اسکریپت را به یک مکان سیستمی کپی کرده و قابل اجرا کنید:
   ```bash
   sudo cp tunnelzi /usr/local/bin/tunnelzi
   sudo chmod +x /usr/local/bin/tunnelzi
   ```
3. اطمینان حاصل کنید که دایرکتوری مورد نیاز وجود دارد:
   ```bash
   sudo mkdir -p /etc/tunnelzi/tunnels
   ```

### استفاده
دستور `tunnelzi` را با یکی از زیرفرمان‌های زیر اجرا کنید:

```bash
tunnelzi [create | list | delete | start | stop | enable | disable | help]
```

#### دستورات
- **`create`**: یک تونل جدید ایجاد کنید. برای نوع تونل و جزئیات پیکربندی درخواست می‌دهد.
- **`list`**: تمام تونل‌های پیکربندی‌شده و وضعیت آنها را فهرست کنید.
- **`delete NAME`**: یک تونل و سرویس `systemd` مرتبط با آن را حذف کنید.
- **`start NAME`**: یک سرویس تونل را راه‌اندازی کنید.
- **`stop NAME`**: یک سرویس تونل را متوقف کنید.
- **`enable NAME`**: یک تونل را برای شروع در زمان بوت فعال کنید.
- **`disable NAME`**: یک تونل را از شروع در زمان بوت غیرفعال کنید.
- **`help`**: پیام راهنما را با دستورالعمل‌های استفاده نمایش دهید.

#### مثال
برای ایجاد یک تونل معکوس SSH:
```bash
sudo tunnelzi create
```
1. گزینه `2` را برای تونل معکوس SSH انتخاب کنید.
2. یک نام منحصر به فرد برای تونل وارد کنید (مثلاً `my-tunnel`).
3. سرور ریموت (مثلاً `user@remote.com`)، پورت ریموت (مثلاً `8080`) و پورت محلی (مثلاً `80`) را وارد کنید.
4. اسکریپت یک سرویس `systemd` و فایل‌های پیکربندی را در `/etc/tunnelzi/tunnels` تولید می‌کند.

برای راه‌اندازی تونل:
```bash
sudo tunnelzi start my-tunnel
```

برای فعال کردن تونل در زمان بوت:
```bash
sudo tunnelzi enable my-tunnel
```

### انواع تونل
1. **تونل بک‌هال**: از باینری `backhaul` برای ارسال ترافیک از یک پورت محلی به سرور ریموت استفاده می‌کند. منبع: [Musixal/Backhaul](https://github.com/Musixal/Backhaul).
2. **تونل معکوس SSH**: یک پورت محلی را از طریق SSH به سرور ریموت نمایش می‌دهد.
3. **تونل محلی SSH**: یک پورت محلی را از طریق SSH به پورت سرور ریموت هدایت می‌کند.
4. **تونل SOCKS5 داینامیک SSH**: یک پراکسی SOCKS5 برای هدایت پورت داینامیک از طریق SSH ایجاد می‌کند.
5. **تونل TCP Socat**: از `socat` برای هدایت ترافیک بین یک پورت محلی و IP:port مقصد استفاده می‌کند.

### پیکربندی
- **پیکربندی تونل‌ها**: در `/etc/tunnelzi/tunnels/` ذخیره می‌شود.
  - اسکریپت‌های شل (`.sh`) برای اجرای تونل.
  - فایل‌های TOML (`.toml`) برای پیکربندی تونل‌های بک‌هال.
- **سرویس‌های Systemd**: در `/etc/systemd/system/` به صورت `tunnelzi-<name>.service` ذخیره می‌شود.

### نکات
- دستورات را با `sudo` اجرا کنید زمانی که دسترسی ریشه مورد نیاز است (مثلاً برای نصب وابستگی‌ها یا مدیریت سرویس‌های `systemd`).
- اطمینان حاصل کنید که باینری `backhaul` برای تونل‌های بک‌هال نصب شده است. باید در `/usr/local/bin/backhaul` قرار داشته باشد. منبع: [Musixal/Backhaul](https://github.com/Musixal/Backhaul).
- تونل‌های مبتنی بر SSH به اعتبارنامه‌های SSH معتبر و دسترسی به سرور ریموت نیاز دارند.
- تونل‌های Socat به بسته `socat` نیاز دارند.
- اگر تونلی راه‌اندازی نشد، لاگ‌های سرویس `systemd` را بررسی کنید:
  ```bash
  sudo journalctl -u tunnelzi-<name>.service
  ```

### عیب‌یابی
- **خطا در نصب وابستگی‌ها**: اطمینان حاصل کنید که اتصال اینترنت فعال و دسترسی کافی (`sudo`) دارید.
- **تونل راه‌اندازی نمی‌شود**: جزئیات پیکربندی (مانند آدرس سرور، پورت‌ها) را بررسی کنید و لاگ‌های `systemd` را چک کنید.
- **باینری بک‌هال موجود نیست**: باینری `backhaul` را به صورت دستی از [Musixal/Backhaul](https://github.com/Musixal/Backhaul) نصب کنید و در `/usr/local/bin/backhaul` قرار دهید.
- **عدم دسترسی**: دستورات را با `sudo` اجرا کنید وقتی درخواست می‌شود.

### مشارکت
مشارکت‌ها استقبال می‌شوند! لطفاً این مراحل را دنبال کنید:
1. مخزن را فورک کنید.
2. یک شاخه جدید ایجاد کنید (`git checkout -b feature-branch`).
3. تغییرات خود را انجام دهید و کامیت کنید (`git commit -m "Add feature"`).
4. تغییرات خود را به شاخه مربوطه در مخزن راه دور ارسال کنید (`git push origin feature-branch`).
5. یک درخواست Pull باز کنید.

### مجوز
این پروژه تحت مجوز MIT منتشر شده است. برای جزئیات به فایل [LICENSE](LICENSE) مراجعه کنید.

### قدردانی
- با بش برای سادگی و قابلیت حمل ساخته شده است.
- با `systemd` برای مدیریت قوی سرویس‌ها یکپارچه شده است.
- از انواع تونل‌های متعدد برای انعطاف‌پذیری در پیکربندی‌های شبکه پشتیبانی می‌کند.
- از پروژه بک‌هال برای قابلیت‌های پیشرفته تونل‌سازی استفاده می‌کند: [Musixal/Backhaul](https://github.com/Musixal/Backhaul).
