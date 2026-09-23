# Manajemen Logistik WMS (Warehouse Management System)

A Flutter-based Warehouse Management System (WMS) application designed to manage inventory, track inbound and outbound items, and facilitate real-time barcode scanning operations. The system provides a centralized dashboard to monitor stock levels, low-stock alerts, and weekly item movements.

## Download Application (Release)
You can directly download and use the compiled applications from the **[GitHub Releases Page](https://github.com/Haran751/Manajemen_Logistik/releases/tag/v1.0)**:
- **Android:** Download the `WMS.apk` file and install it on your Android device.
- **Windows:** Download the `WMS.exe` file, and run the application

## Quick Start

1. Ensure Flutter is installed on your local machine.
2. Clone this repository.
3. Install the required dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application on an emulator or physical device:
   ```bash
   flutter run
   ```

## Commands

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install all required dependencies |
| `flutter run` | Start the development application |
| `flutter clean` | Clean the build directory |
| `flutter build apk` | Create a production APK build for Android |
| `flutter build ios` | Create a production build for iOS |
| `flutter test` | Run unit and widget tests |

## Architecture

This project is built using Flutter and follows a structured architectural pattern to separate logic from UI.

### State Management
The application uses the `provider` package for global state management. `WmsProvider` is the core class responsible for handling data operations such as adding products, updating stock limits, managing outbound shipment item statuses, and recording scan histories.

### UI Structure
The application is organized into several key directories:
- `/lib/models/`: Contains data models such as `Product`, `InboundRecord`, and `OutboundShipment`.
- `/lib/providers/`: Contains `WmsProvider` which holds the application state.
- `/lib/screens/`: Contains the main application pages:
  - `DashboardScreen`: Shows high-level metrics and low-stock alerts.
  - `MasterBarangScreen`: Lists all inventory with search and filter capabilities.
  - `InboundScreen`: Handles the process of receiving new stock.
  - `OutboundScreen`: Manages dispatching items and marking them as picked.
  - `ScannerScreen`: Integrates the device camera for actual barcode scanning.
  - `ProfileScreen`: Displays warehouse and user information.
- `/lib/widgets/`: Contains reusable UI components, such as `BarcodeWidget` (custom painter for rendering barcodes) and `WeeklyMovementChart`.

### Navigation
The main navigation uses a `BottomNavigationBar` of type `fixed` combined with a `PageView` and a `PageController`. This ensures smooth transition animations between different application modules without unnecessarily pushing and popping screens to the navigation stack.

## Contributing

1. Create a new branch for each feature or bug fix.
2. Keep UI widgets clean and delegate business logic to `WmsProvider`.
3. If adding a new package, ensure it is necessary and document its usage.
4. Run `flutter format .` and resolve all analyzer warnings before submitting a pull request.
