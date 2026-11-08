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
