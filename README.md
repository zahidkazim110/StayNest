# StayNest

StayNest is a Flutter student-accommodation discovery and hostel-management app.

## Current app workflows

### Students
- Browse hostel listings in the discovery experience.
- Filter by city, monthly budget, room type and facilities.
- Open hostel details, review facilities and view owner-provided contact/location details.
- Select a room type and continue through the demo booking flow.
- Save favourites and recently viewed hostels.

### Hostel owners
- Create a hostel listing with name, city, full address, contact number, description and facilities.
- Add a Google Maps share URL or capture the current GPS position while at the property.
- Manage rooms, room types, monthly rent per bed, total beds and available beds.
- Review property and room counts from the owner dashboard.
- Maintain owner contact details.

## Run locally

```powershell
flutter pub get
flutter analyze
flutter run
```

## Location permissions

The app requests location permission only when an owner chooses **Use current GPS location**. Android fine/coarse permissions and the iOS when-in-use usage description are configured in the platform manifests.

Owners can also paste a Google Maps share link if they do not want to grant GPS permission.

## Current persistence and integration status

Owner hostel listings, room records and owner profile fields are currently stored locally with SharedPreferences. This is suitable for UI development and single-device testing; it does **not** publish a listing to other users or synchronize across devices.

The discovery screen can read owner-created listings stored on the same device. A production deployment still needs the StayNest API/database, authenticated owner-to-listing ownership, cloud image storage, live booking requests and server-side availability updates. Booking requests and analytics remain demo experiences until those services are connected.

Google Maps links are stored with each listing and exposed on student hostel details for copying. Native in-app map rendering/navigation still requires the Google Maps platform configuration and API key.


## Android APK release

The repository includes a GitHub Actions workflow at `.github/workflows/android-apk.yml`. It runs dependency resolution, static analysis and a release APK build when changes are pushed to `feature/play-store-polish`, when manually dispatched from the Actions tab, or when a version tag matching `v*` is pushed. Every successful build uploads the `staynest-android-apk` workflow artifact. Pushing a version tag also creates a GitHub **prerelease** and attaches `app-release.apk` to the release.

### Installable preview vs. distributable release

If no signing key is configured, Gradle uses the Android debug key to create an installable **preview APK**. This is for testing only and must not be treated as the permanent signing identity for public distribution.

For a distributable APK, create and protect a private upload/release keystore. Never commit the keystore or its passwords to this repository. Add these GitHub Actions repository secrets:

- `ANDROID_KEYSTORE_BASE64`: Base64-encoded contents of the keystore file.
- `ANDROID_KEYSTORE_PASSWORD`: Keystore password.
- `ANDROID_KEY_ALIAS`: Key alias.
- `ANDROID_KEY_PASSWORD`: Key password.

On Windows PowerShell, generate a keystore locally with `keytool`, then encode it with:

```powershell
[Convert]::ToBase64String([IO.File]::ReadAllBytes(".\\staynest-release.jks")) | Set-Clipboard
```

Paste the result into the `ANDROID_KEYSTORE_BASE64` repository secret. Keep a secure offline backup of the keystore and passwords. Losing the signing key can prevent users from installing future updates over the existing app.

### Publish a GitHub prerelease

After the workflow is committed to your branch, create and push a version tag from the commit you want to publish:

```powershell
git checkout feature/play-store-polish
git pull origin feature/play-store-polish
git tag v1.0.1
git push origin v1.0.1
```

GitHub Actions will analyze the Flutter project, build the APK, and create a prerelease under the repository's **Releases** page. If release-signing secrets are configured, the APK uses your private release key. Without them, it is a debug-signed preview APK suitable for testing only; configure the permanent signing key before distributing an updateable public app.

### Build locally

```powershell
flutter pub get
flutter analyze
flutter build apk --release
```

The APK is written to `build\\app\\outputs\\flutter-apk\\app-release.apk`.

Before public distribution, replace the template Android application ID `com.example.staynest` with a permanent package ID controlled by the app publisher. Changing it after distribution creates a different Android app identity.

### Current functional scope

This build remains a local-first demonstration. Listings, profiles, favourites and bookings are stored on the device. Payment choices are demonstrative only; the app does not collect or transfer real money. A production service still requires backend APIs, authentication, cloud synchronization, verified listing ownership, live booking workflows and payment-provider integration.
