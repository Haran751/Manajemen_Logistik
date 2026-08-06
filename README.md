# WMS Gudang Utama - Manajemen Logistik

A comprehensive Warehouse Management System (WMS) application built with Flutter. This application streamlines inventory management, inbound receiving, and outbound shipping processes with a modern and intuitive user interface.

## Key Features

*   **Interactive Dashboard:** Visualizes weekly goods movement (inbound versus outbound) and key operational metrics.
*   **Master Barang (Inventory):** Browse, search, and manage all registered products in the warehouse.
*   **Inbound (Penerimaan Barang):** Scan incoming products using the device's built-in camera, automatically fetching SKU data and updating stock quantities.
*   **Outbound (Pengeluaran Barang):** Manage and record outgoing products efficiently.
*   **Real Barcode Scanner:** Fully functional, hardware-accelerated barcode and QR code scanner using the `mobile_scanner` package for rapid data entry.
*   **Smooth UI Animations:** Fluid page transitions and scrolling physics for a premium user experience.

## Getting Started

### Prerequisites

*   Flutter SDK (^3.12.2 or newer)
*   Dart SDK
*   Android Studio / Xcode (for building to physical devices or emulators)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/Haran751/Manajemen_Logistik.git
    cd Manajemen_Logistik
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the application:**
    ```bash
    flutter run
    ```
    *(Note: To test the barcode scanner functionality, you must run the application on a physical device, as emulators typically do not have native camera hardware support.)*

## Technology Stack

*   **Framework:** [Flutter](https://flutter.dev/)
*   **State Management:** `provider`
*   **Barcode Scanning:** `mobile_scanner`
*   **UI/UX:** Custom Material 3 Design with `PageView` transitions.

## Building the APK

To generate a release APK for Android deployment:

```bash
flutter build apk
```
The compiled APK will be located at `build/app/outputs/flutter-apk/app-release.apk`.

---
*Developed for modern logistics and warehouse management.*
