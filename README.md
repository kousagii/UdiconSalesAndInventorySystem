<div align="center">
  <img src="program_codes/assets/uc_logo.png" alt="Udicon Trading logo" width="120">

  <h1>Udicon Sales and Inventory System</h1>

  <p>A LAN-based sales and inventory system customized for Udicon Trading.</p>

  <p>Node.js · Express · MySQL · HTML · CSS · JavaScript</p>

  <a href="#about">About</a> ·
  <a href="#features">Features</a> ·
  <a href="#getting-started">Getting Started</a> ·
  <a href="#lan-access">LAN Access</a> ·
  <a href="#project-structure">Project Structure</a>
</div>

## About

The system connects Udicon Trading's sales, inventory, and administration workflows through a shared database. One host computer runs the Node.js server and connects to MySQL; staff access the application in a browser over the same local network.

## Features

| Area | Capabilities |
| --- | --- |
| Administration | Dashboards, user management, role switching, archived records, and activity logs |
| Products and inventory | Product variants, barcodes, images, stock levels, low-stock thresholds, and reorder suggestions |
| Suppliers and purchasing | Supplier records, purchase orders, receiving, and payment tracking |
| Sales | Transactions, cash and digital payments, pay-later balances, installments, refunds, and exchanges |
| Reporting | Sales performance, stock alerts, losses, receivables, and user activity |
| Maintenance | Manual and scheduled database backups, backup listing, and restoration |

Available interfaces are **Admin**, **Sales**, and **Inventory**, according to the roles assigned to each account.

## Built With

- **Server:** Node.js, Express, and express-session
- **Database:** MySQL with mysql2
- **Authentication:** bcrypt password hashing and session cookies
- **Uploads and scheduling:** Multer and node-cron
- **Client:** HTML, CSS, and JavaScript, with bundled Poppins fonts

## Getting Started

### Requirements

- Node.js 18 or newer and npm; use a supported Node.js LTS release.
- MySQL 8.0 or newer. The supplied schema uses `utf8mb4_0900_ai_ci`; it is not directly compatible with older MySQL or MariaDB versions.
- A modern browser and a shared LAN for staff devices.
- For backup and restore features, `mysqldump` and `mysql` must be available on the server's `PATH`. True incremental backups also use `mysqlbinlog`.

### 1. Get the source and install dependencies

Clone this repository or download and extract it, then open a terminal in its root folder:

```sh
cd UdiconSalesAndInventorySystem
npm ci
```

Keep `package-lock.json` in version control so installations use the recorded dependency versions. There is no frontend build step.

### 2. Create an empty database

Connect with a MySQL administrator account:

```sh
mysql -u root -p
```

Run the following SQL, replacing the example password with your own:

```sql
CREATE DATABASE udicon CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE USER 'udicon'@'localhost' IDENTIFIED BY 'replace-with-your-database-password';
GRANT ALL PRIVILEGES ON udicon.* TO 'udicon'@'localhost';
USE udicon;
SOURCE database/schema.sql;
EXIT;
```

Run the MySQL client from the repository root so `SOURCE` can find the file. Alternatively, import `database/schema.sql` into the empty database using MySQL Workbench. The schema contains table definitions and relationships only, with no users, products, transactions, or uploaded images. Import it once into a new database.

### 3. Configure the environment

In PowerShell:

```powershell
Copy-Item .env.example .env
```

On macOS or Linux:

```sh
cp .env.example .env
```

Edit `.env` with your local values:

| Variable | Purpose | Example |
| --- | --- | --- |
| `DB_HOST` | Database host reachable from the server | `localhost` |
| `DB_PORT` | Database connection port | `3306` |
| `DB_USER` | MySQL application account | `udicon` |
| `DB_PASSWORD` | Password for that account | Your database password |
| `DB_NAME` | Database containing the imported schema | `udicon` |
| `SESSION_SECRET` | Random secret used to sign sessions | Generate using the command below |
| `PORT` | HTTP server port | `3000` |

Generate a session secret and paste the result into `.env`:

```sh
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### 4. Start the server

```sh
npm start
```

Open [the login page](http://localhost:3000/log-in.html). The terminal prints both the local URL and the detected LAN URL. Keep the server and MySQL running while staff use the application.

### 5. Create the initial administrator

For an empty development installation, the existing setup endpoint at [http://localhost:3000/api/setup-test-admin](http://localhost:3000/api/setup-test-admin) creates the following test account:

| Username | Password |
| --- | --- |
| `admin` | `admin123` |

Sign in and update the administrator details and password through User Management. Assign additional roles there if the administrator also needs Sales or Inventory access. Before operational LAN use, disable or remove the test setup endpoint in `server.js`; it is unauthenticated and uses fixed test credentials.

## LAN Access

1. Connect the host computer and staff devices to the same network.
2. Start MySQL and run `npm start` on the host computer.
3. Allow inbound TCP traffic on the configured application port through the host's firewall for the private network.
4. On each staff device, open `http://<server-lan-ip>:3000/log-in.html`, replacing the address and port with those printed by the server. `localhost` on a staff device points to that device itself.

Only the host computer needs the source code, npm dependencies, and database connection settings. A stable LAN address for the host keeps staff bookmarks usable. Sessions use the server's in-memory session store and end when it restarts.

Some pages load Tom Select, JsBarcode, and QRCode.js from public CDNs. Those features require internet access from the browser unless you host those libraries locally; the current checkout is not fully offline.

## Backups and Local Data

The server creates `backups/` and `program_codes/uploads/` automatically. Backup schedules default to a full dump at midnight and an incremental job at minute 30 of every hour, using the server's local time. Schedule changes are stored in `backup-config.json`.

Backup and restore commands currently use MySQL's default port rather than `DB_PORT`. If you use a non-default database port, update those commands in `server.js` before using maintenance features. The incremental implementation also points to a Windows-specific binary-log directory and index filename in `performIncrementalBackup`; configure these for the host. When that index file is absent, it falls back to a full dump. Scheduled backup records use user ID `1`, so create the initial administrator before relying on scheduled backups.

Generated SQL dumps, uploaded product images, local schedules, credentials, dependencies, and logs are excluded by `.gitignore`. Keep operational backups and uploads separately if you need to move an existing installation; they are not included in a fresh clone. `database/schema.sql`, `.env.example`, bundled UI assets, and the npm lockfile remain part of the source.

## Project Structure

```text
UdiconSalesAndInventorySystem/
├── database/
│   └── schema.sql                # Empty database structure
├── program_codes/
│   ├── admin-screen/             # Administration pages
│   ├── inventory-screen/         # Inventory and purchasing pages
│   ├── sales-screen/             # Sales pages and shared sales utilities
│   ├── assets/                   # Logo and local fonts
│   ├── authGuard.js              # Shared session and role UI handling
│   ├── log-in.html               # Login and password recovery
│   ├── reorder-modal.js          # Shared reorder interface
│   └── style.css                 # Shared styles
├── .env.example                  # Local configuration template
├── .gitignore
├── package.json
├── package-lock.json
├── README.md
└── server.js                     # Express server, API, and backup jobs
```

## Development Checks

```sh
npm run check
```

This checks the syntax of the server and standalone browser JavaScript files. There is no automated functional test suite. Database-backed workflows must be verified against a configured MySQL instance.
