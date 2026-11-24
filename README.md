# GlobalPay

GlobalPay is a Flutter payroll workflow demo. It supports local admin and worker
accounts, worker onboarding, payroll review, and worker-visible payroll history.
Demo data is stored on the current device using `shared_preferences`.

## Run the app

From this directory:

```shell
flutter pub get
flutter run
```

## Demo sign-in

- Admin: `admin@globalpay.demo` / `Admin123!`
- Worker: `sarah@globalpay.demo` / `Worker123!`

The admin demo account starts with four compliant sample workers whose monthly
salaries are already in USD, so you can open **Run Payroll**, review the
estimated payout, and confirm a local demo payroll immediately. Confirmation
creates visible `Paid (demo)` records only; no money is transferred.

## Admin workflow

1. Sign in with the admin demo account, or create a new admin account from the
   welcome page.
2. Select **Add Worker**. Enter the worker's name, unique email, country, role,
   engagement type, monthly salary, and a temporary password (at least 8
   characters). Attach a National ID, Tax Form, and Contract as PDF, PNG, or JPG
   files if available. Share the worker login details with them securely.
3. Enter every new worker's monthly salary in USD. Country remains worker
   information and does not change application currency.
4. Select **Run Payroll**. Only compliant workers with salaries verified in USD
   are included; totals are shown in USD.
5. Review the worker-level amounts and confirm the demo payroll.

## Worker workflow

1. Sign in with the worker demo account or the account created by the admin.
2. Use the Worker portal's **Home**, **Salary**, **Payments**, **Documents**, and
   **Profile** tabs to view the signed-in worker's available local demo data.
   Uploaded documents appear in the admin Documents Center and in that worker's
   Documents tab.
3. Salary and payment history are read-only. Payment records are filtered by the
   signed-in worker's ID. Missing profile fields and records are shown as
   unavailable or as empty states rather than being fabricated.

## Important limitations

This is a local demonstration, not a production payroll or payment service.
Payroll confirmation creates a local record marked `Paid (demo)`; it does not
send money, connect a bank account, calculate taxes, validate compliance, or
convert currencies. New workers are marked compliant for demonstration only.
Accounts and payroll records are stored on-device and are not shared across
devices or users. Password hashes are for demo sign-in only and do not replace
secure server-side authentication. Do not enter real personal, financial, or
payroll data. Before production use, connect a secured backend, enforce
server-side tenant and role authorization, implement secure password recovery,
and integrate a regulated payment provider and jurisdiction-specific payroll
and compliance services. Uploaded document bytes are stored in local app
preferences for this demo only; they are not encrypted, backed up, or protected
by server access rules. Do not upload real identity, tax, or contract files.
Secure document storage, previews/downloads, review statuses, notifications,
and editable worker profile fields require a production backend.

## USD currency policy

USD is the only currency for new salary entries and payroll records. Worker
country is retained for employment information and compliance, but does not
select a currency. Existing salary/payment amounts from older app versions keep
their stored or previously implied currency and are never automatically
converted or relabeled. Such salary records are hidden from USD totals and
payroll until an admin verifies the original value and enters the confirmed USD
salary from **Worker Details**. The pre-standard salary and its original
currency are retained on the worker record for reference. Existing payment
amounts in non-USD currencies remain in storage but are withheld from USD
displays; no exchange rate is assumed.
