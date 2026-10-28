# IIUC Railway E-Ticketing and Seat Management System

PHP and MySQL project for local XAMPP. The original `home.php` and original site CSS/assets were not present in the accessible project folders when this build started. This version keeps the existing IIUC green styles and ticket card already in the project and uses the station, route, train, six-bogie, and 40-seat rules from the available IIUC database plan. No original image files were found.

## XAMPP setup

1. Place this folder at `xampp/htdocs/iiuc-railway` (on this computer it is `/Applications/XAMPP/xamppfiles/htdocs/iiuc-railway`).
2. Start **Apache** and **MySQL** in the XAMPP Manager.
3. Open `http://localhost/phpmyadmin/`, create a new database named `iiuc_railway_system`, choose it, and import this folder's `database.sql`. It creates sample stations, routes, four trains, schedules, six bogies per train, and 40 seats per bogie. It does not create sample accounts or passwords. The schema does not drop existing tables; import it into a new/empty database.
4. If your local MySQL values differ from XAMPP defaults, copy `config/local.php.example` to `config/local.php` and edit its settings. The default connection is `127.0.0.1`, database `iiuc_railway_system`, user `root`, blank local password. Keep local credentials in this PHP config or the documented environment variables, not in public page files.
5. Open `http://localhost/iiuc-railway/`.

## Create the first admin

After importing the schema and configuring MySQL, run this in Terminal from the project folder:

```sh
/Applications/XAMPP/xamppfiles/bin/php tools/create-admin.php
```

Enter an admin name, email, and a unique password of at least 12 characters when prompted. The script is CLI-only, creates an account only while the admin table is empty, and does not ship a default password. Sign in at `http://localhost/iiuc-railway/admin/login.php`. Later admins can be added/deactivated in **Admin credentials**; active admins can change their own password after verifying the current one.

## IIUC email rule

Registration checks the pattern in `config/config.php`; by default it accepts valid addresses ending in `@iiuc.ac.bd`. To change it locally, set `allowed_email_pattern` in `config/local.php` to a valid PHP regular expression, for example `'/^[A-Z0-9._%+\\-]+@iiuc\\.ac\\.bd$/i'`. You can also set the `IIUC_EMAIL_PATTERN` environment variable. This validates the address format/domain; it does not send an email verification message.

## Booking and allocation rules

- Each train has six allocations in the project-defined order: B1 Teacher/Male, B2 Teacher/Female, B3 Student/Male, B4 Student/Female, B5 Staff/Male, B6 Staff/Female. Each active bogie has 40 active seats (S01–S40 by default).
- A signed-in user is automatically assigned the lowest numbered available seat in their own category and gender bogie for the selected schedule and date. A guest is optional; guest passengers use the host's category and gender and get a separate seat in the same allocation.
- A booking group is limited to one per user, schedule, and date. Booking starts a database transaction, locks the schedule row while checking and assigning seats, and the database also enforces a unique `(schedule, date, seat)` key. The active host-trip unique key prevents duplicate bookings by one user. These checks protect concurrent requests.
- Users may cancel their own confirmed booking on or before its journey date. Cancellation marks the group and passenger records cancelled, sets active seat links to `NULL` to release seats, and preserves seat/bogie labels in history. Admins can cancel any confirmed booking.
- Schedule records can be daily or list service days as abbreviated names like `Mon,Tue,Wed`; optional valid-from/to dates are enforced.

## Important files

- `home.php`, `login.php`, `register.php`, `logout.php` — user-facing home and authentication.
- `train-information.php`, `booking.php`, `my-bookings.php`, `ticket.php`, `contact-us.php` — schedule search, booking, history, e-ticket, and contact page.
- `admin/login.php`, `admin/index.php`, `admin/bookings.php`, `admin/manage.php`, `admin/credentials.php` — protected admin sign-in, dashboard, booking controls, CRUD for stations/routes/trains/schedules/bogies/seats, and admin credential management.
- `includes/bootstrap.php`, `includes/header.php`, `includes/footer.php`, `includes/booking-functions.php` — connection, authentication/CSRF helpers, shared layout, and allocation logic.
- `config/config.php`, `config/local.php.example` — settings and local config template.
- `database.sql` — schema, indexes, constraints, and non-secret schedule seed data.
- `tools/create-admin.php` — safe one-time first admin creation from Terminal.

This is a local academic prototype. Before a public deployment, enable HTTPS, configure email verification and mail delivery, add operational logging/backups, and review institutional authorization for real passenger data and transport schedules.
