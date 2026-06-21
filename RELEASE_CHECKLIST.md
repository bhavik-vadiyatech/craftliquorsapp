# Release Checklist — Craft Discount Liquors

Status of everything needed to ship to Google Play and the App Store.
Items marked ✅ were done automatically; items marked ⬜ need you (account
access, credentials, or a product decision).

---

## Done automatically (verify, don't redo)

- ✅ **Release keystore generated**: `android/app/upload-keystore.jks`, credentials
  in `android/key.properties`.
  **BACK BOTH FILES UP NOW** (password manager + offline copy). If you lose the
  keystore you can never update the app on Play again. Never commit them to git.
  - SHA-1: `0D:B6:80:B3:CB:98:E3:64:07:7E:F5:6F:CC:08:B7:2F:3F:11:DA:8E`
  - SHA-256: `F0:FF:82:B2:15:A2:7B:22:0D:06:D6:48:81:68:C5:BF:43:45:F4:09:BE:2B:CC:F0:44:B4:61:4E:9F:85:03:48`
- ✅ Release builds now signed with the release key (`android/app/build.gradle.kts`).
- ✅ Fixed malformed `AndroidManifest.xml` (stray attributes broke the XML),
  removed `usesCleartextTraffic`, app label → "Craft Discount Liquors".
- ✅ Android deep-link host set to `admin.craftdiscountliquors.com`.
- ✅ iOS app name → "Craft Liquors" (`CFBundleName`/`CFBundleDisplayName`;
  kept short because iOS truncates long names under the icon).
- ✅ iOS permission strings rewritten; placeholder `NSUserTrackingUsageDescription`
  replaced (Apple rejects placeholder text).
- ✅ Kotlin Gradle plugin bumped 2.1.20 → 2.2.20 (build was failing against
  google_maps_flutter); removed invalid `notification_icon copy.png` resource
  (backed up to project root as `notification_icon_old_backup.png`).
- ✅ **Signed release bundle built and verified**:
  `build/app/outputs/bundle/release/app-release.aab` (65.5 MB), signature
  CN=Craft Discount Liquors. Uploadable to Play Console as-is — but fix the
  branding/keys blockers below before actually submitting for review.

## Blockers you must resolve before submission

### Both platforms

- ⬜ **All branding is still the GroFresh template** — there is no Craft Discount
  Liquors artwork in the project. Both stores will see the template's green "G"
  icon, and Apple/Google can reject for misleading or placeholder branding.
  You need to supply:
  - A **1024×1024 PNG logo** — once it exists, launcher icons for both platforms
    can be generated automatically with the `flutter_launcher_icons` package.
  - Replacements for in-app logos: `assets/image/app_logo.png` (130×148),
    `web/icons/app_logo.png`, `web/icons/Icon-*.png`, and the
    `assets/image/web_bar_logo_place_holder*.png` files.
  - The iOS launch screen / Android splash if they show the logo.
- ⬜ **Google Maps API key** is still `YOUR_MAP_KEY_HERE` in two places:
  - `android/app/src/main/AndroidManifest.xml` (`com.google.android.geo.API_KEY`)
  - `ios/Runner/AppDelegate.swift` (`GMSServices.provideAPIKey`)
  Create keys in Google Cloud Console (Maps SDK for Android / iOS), restrict them
  to package `com.vadiyatech.craftdiscountliquors` + the SHA-1 above (Android) and
  the bundle id (iOS). Without this, address selection/order tracking maps are blank.
- ⬜ **Facebook login still uses the template demo app** (GroFresh, app id
  `1216934565526698`) in `android/app/src/main/res/values/string.xml`,
  `ios/Runner/Info.plist`, and `lib/main.dart:121`. Either create your own Facebook
  app at developers.facebook.com and replace the id/token/scheme in all three
  places, **or remove the Facebook login button** — shipping with a broken login
  is a common review rejection.
- ⬜ **Google Sign-In not configured**: `googleServerClientId` in
  `lib/utill/app_constants.dart:16` is `YOUR_AUTH_CLIENT_ID`, and
  `google-services.json` has no OAuth clients. In Firebase console:
  enable Google sign-in (Authentication → Sign-in method), add the SHA-1/SHA-256
  above to the Android app (Project settings), re-download `google-services.json`
  to `android/app/`, then put the **web** OAuth client id (`client_type: 3`) into
  `googleServerClientId`. Same advice as Facebook: configure it or hide the button.
- ⬜ **Apple Sign-In**: the app includes `sign_in_with_apple`. If you offer any
  third-party login on iOS, Apple REQUIRES Sign in with Apple to work — enable the
  capability in Xcode and configure it in Firebase/your backend.
- ⬜ **SECURITY — move the Firebase admin key out of the project**:
  `craft-discount-liquors-firebase-adminsdk-fbsvc-ab0eb2e559.json` in the project
  root is a service-account **private key** with admin access to your Firebase
  project. It does not belong in an app codebase at all (it's server-side only).
  Move it somewhere safe outside the project and consider rotating it in
  Google Cloud Console → IAM → Service Accounts.

### iOS only

- ⬜ **`ios/Runner/GoogleService-Info.plist` is MISSING** but referenced by the
  Xcode project — the iOS build will fail until you add it. Firebase console →
  Project settings → Add iOS app (bundle id `com.vadiyatech.craftdiscountliquors`)
  → download the plist into `ios/Runner/`.
- ⬜ Apple Developer Program membership ($99/yr) under team `7WSYLQ8Y87` (already
  set in the project) with a distribution certificate + provisioning profile
  (Xcode → Signing & Capabilities, "Automatically manage signing" is easiest).
- ⬜ Push notifications: enable the Push Notifications capability in Xcode and
  upload your APNs key (.p8) to Firebase console → Cloud Messaging.

### Android only

- ⬜ Google Play Console developer account ($25 one-time).
- ⬜ Host `https://admin.craftdiscountliquors.com/.well-known/assetlinks.json`
  with the SHA-256 above so deep links verify (App Links).

## Store listing requirements (both consoles)

- ⬜ **Privacy policy URL** — mandatory on both stores.
- ⬜ Screenshots (phone required; tablet/iPad strongly recommended), app icon
  512×512 (Play) — verify current launcher icons are your brand, not the
  GroFresh template's.
- ⬜ Description, short description, support email.
- ⬜ **Data safety form** (Play) / **App Privacy** (App Store): the app collects
  location, email, phone, purchase history; uses ATT tracking on iOS.

## Alcohol-specific policy requirements (important — common rejection cause)

- ⬜ Content rating: Apple 17+ (alcohol references); fill Play's content rating
  questionnaire honestly (alcohol sales).
- ⬜ Both stores require **age verification** for alcohol commerce. Make sure the
  app/backend has an age gate (21+ in the US) at signup or checkout, and that
  delivery requires ID check (state by your courier flow). Mention this in the
  review notes.
- ⬜ Restrict distribution to countries/states where your liquor delivery license
  is valid (set in each console's country list).
- ⬜ Provide a demo account (with a test address in your delivery zone) in both
  review consoles — reviewers must be able to reach checkout.

## Build & upload commands (after blockers are cleared)

```bash
# Android — upload the .aab at Play Console → Production → Create release
flutter build appbundle --release
# output: build/app/outputs/bundle/release/app-release.aab

# iOS — archive and upload
flutter build ipa --release
# then upload build/ios/ipa/*.ipa with Apple's "Transporter" app,
# or: xcrun altool --upload-app -f build/ios/ipa/*.ipa -t ios \
#       --apiKey <key-id> --apiIssuer <issuer-id>
```

Version bumps for future releases: edit `version:` in `pubspec.yaml`
(`1.0.0+1` → `1.0.1+2`; the `+N` build number must increase every upload).
