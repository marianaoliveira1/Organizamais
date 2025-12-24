# App Store Review Follow-up

## Guideline 4.8 – Third-party login parity
- `Sign in with Apple` is now highlighted with the native `SignInWithAppleButton` on both `lib/pages/login/login_page.dart` and `lib/pages/register/register_page.dart`.
- The iOS target includes the `Sign in with Apple` capability via `ios/Runner/Runner.entitlements` and the corresponding Xcode project updates.
- The backend flow already limited data collection to the user name and email (`AuthController.loginWithApple`) and respects Apple’s private relay emails. Reviewers can find the Apple button directly under the Google button on the login screen after accepting the privacy checkbox.

## Guideline 2.1 – App Tracking Transparency
- We added `lib/services/tracking_transparency_service.dart` and invoke it from `main.dart` before any ad or analytics SDK is initialized. This shows the ATT system dialog on first launch (or when status is `notDetermined`) as soon as the splash screen transitions to the login page.
- To verify: cold-start the app on iPadOS/iOS 14+ → the ATT sheet appears before ads or analytics run. If you need to re-test, delete the app from the device to reset the tracking status.

## Guideline 4.0 – Large-screen layout
- Login and registration screens now use a responsive layout (see `lib/pages/login/login_page.dart` and `lib/pages/register/register_page.dart`) with max-width constraints, SafeArea padding, and adaptive spacing so that the entire form (including the Apple button) stays visible on iPad Air (5th gen) in both orientations.

## Guideline 2.3.3 – Accurate 13" iPad screenshots
- Capture new screenshots directly on a 12.9" simulator/device after the above UI fixes so the frames match the target hardware.
- In App Store Connect, open **App Store > App Information > Previews and Screenshots**, click **View All Sizes in Media Manager**, and replace the 13-inch iPad set with the newly captured iPad-specific images (no iPhone frames or marketing overlays).

