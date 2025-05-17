
![Mockup](https://github.com/user-attachments/assets/2f6332c3-34e9-42a5-a3cc-d16db33497b9)
<hr/>

# SWMS Administration

<span> By **Quarista** Developers </span>

## File Structure

- **lib/**: Contains the core application code written in Dart, including the main Flutter components and business logic.
- **ios/**: Includes configuration and assets for iOS builds, such as launch screen assets and platform-specific settings.
- **android/**: Contains files and configurations for Android builds, including Gradle scripts and platform-specific resources.
- **test/**: Houses unit and widget tests to ensure the reliability of the application.
- **build/**: Generated build artifacts and outputs (may be excluded in version control).
- **assets/**: Stores static files like images, fonts, and other resources used in the application.

## Keynote

### Used Packages
The project leverages a variety of third-party Dart and Flutter packages, enhancing functionality and streamlining development. Key dependencies include:

- **UI and Animations**: 
  - `google_fonts`, `flutter_svg`, `flutter_animate`, `flutter_staggered_animations`, `shimmer`, `lottie`, `glassmorphism`, `animations`
- **Navigation**: 
  - `go_router`, `google_nav_bar`
- **Firebase Integration**: 
  - `firebase_core`, `firebase_database`, `cloud_firestore`
- **Media Handling**: 
  - `image_picker`, `cached_network_image`
- **Mapping and Geolocation**: 
  - `flutter_map`, `latlong2`, `geolocator`
- **Charts and Icons**: 
  - `fl_chart`, `lucide_icons`, `font_awesome_flutter`
- **Miscellaneous**: 
  - `auto_size_text`, `flutter_switch`, `animated_text_kit`, `url_launcher`

### External Primary Assets
The application includes custom assets, such as images and geographical data files, stored under the `assets/` directory:
- **Images**: Located in `assets/images/` (e.g., `Icon.png`, as referenced for the launch icon).
- **Geographical Data**: A file named `custom.geo.json` is also included.
