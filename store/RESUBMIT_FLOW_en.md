# Resubmission Flow Guide (English)

## Quick Response to Store Rejections

### Common Rejection Reasons & Quick Fixes

#### 1. Permission Usage Description Issues

**Rejection**: "App requests camera permission but doesn't explain usage clearly"

**Quick Fix**:
1. Update `Info.plist` (iOS) / `AndroidManifest.xml` (Android) descriptions
2. Add permission explanation dialog before requesting
3. Provide clear alternative if permission denied

**Files to Update**:
- `ios/Runner/Info.plist`: Update `NSCameraUsageDescription`
- `android/app/src/main/AndroidManifest.xml`: Add permission comments
- Add permission explanation dialog in app

#### 2. Privacy Policy Issues

**Rejection**: "App collects data but no privacy policy"

**Quick Fix**:
1. Verify `assets/legal/privacy-ja.md` exists
2. Ensure privacy policy is accessible in app
3. Update privacy policy to be more specific

**Files to Check**:
- `assets/legal/privacy-ja.md`
- `lib/pages/settings_page.dart` (privacy policy link)

#### 3. App Functionality Issues

**Rejection**: "App crashes or doesn't work as described"

**Quick Fix**:
1. Test on multiple devices/OS versions
2. Add error handling for edge cases
3. Improve user feedback for failures

**Testing Checklist**:
- [ ] Test on iOS 12.0+ devices
- [ ] Test on Android 6.0+ devices
- [ ] Test with poor network conditions
- [ ] Test with large images
- [ ] Test permission denial scenarios

#### 4. Premium Feature Issues

**Rejection**: "Premium features not accessible or working"

**Quick Fix**:
1. Verify in-app purchase setup
2. Test with sandbox accounts
3. Ensure restore purchases works

**Files to Check**:
- `lib/services/purchase_service.dart`
- `lib/pages/paywall_page.dart`
- Store console settings

### Rapid Resubmission Process

#### Step 1: Identify Issue (5 minutes)
1. Read rejection email carefully
2. Note specific rejection reason
3. Check if it's a documentation or code issue

#### Step 2: Quick Fix (15-30 minutes)

**For Documentation Issues**:
```bash
# Update metadata files
vim store/metadata/short_description_en.txt
vim store/metadata/long_description_ios_en.txt

# Update privacy policy
vim assets/legal/privacy-ja.md
```

**For Code Issues**:
```bash
# Make code changes
vim lib/pages/home_page.dart  # Add error handling
vim lib/services/ocr_service.dart  # Add validation

# Test locally
flutter test
flutter analyze
```

#### Step 3: Version Bump (2 minutes)
```bash
# Update version in pubspec.yaml
version: 1.0.1+2  # Increment patch version

# Commit changes
git add .
git commit -m "fix: address store review feedback - [specific issue]"
git tag v1.0.1
git push origin main --tags
```

#### Step 4: Build & Upload (10 minutes)

**iOS (App Store Connect)**:
1. Open Xcode → Archive
2. Upload to App Store Connect
3. Submit for review with explanation

**Android (Play Console)**:
1. Build release APK/AAB
2. Upload to Play Console
3. Submit for review with explanation

#### Step 5: Review Response (Template)

**Email Template**:
```
Subject: Resubmission - [App Name] v1.0.1 - [Issue Fixed]

Dear Review Team,

Thank you for your feedback. I have addressed the following issue in version 1.0.1:

[SPECIFIC ISSUE AND FIX DESCRIPTION]

Changes made:
- [Specific change 1]
- [Specific change 2]
- [Specific change 3]

The app has been tested on:
- iOS 12.0+ devices
- Android 6.0+ devices
- Various network conditions

Please let me know if you need any additional information.

Best regards,
[Your Name]
```

### Pre-Submission Checklist

Before submitting any version:

- [ ] **Code Quality**:
  - [ ] `flutter analyze` passes
  - [ ] `flutter test` passes
  - [ ] No obvious crashes in testing

- [ ] **Permissions**:
  - [ ] Permission descriptions are clear
  - [ ] App handles permission denial gracefully
  - [ ] Alternative flows work when permissions denied

- [ ] **Privacy**:
  - [ ] Privacy policy is accessible
  - [ ] No unexpected data collection
  - [ ] All data stays on device

- [ ] **Functionality**:
  - [ ] Core features work as described
  - [ ] Error handling is user-friendly
  - [ ] App works offline

- [ ] **Premium Features**:
  - [ ] Purchase flow works with test accounts
  - [ ] Restore purchases works
  - [ ] Paywall appears at correct limits

### Screenshots & Video Guidelines

#### Screenshots for Review
1. **Home Screen**: Show camera button and main interface
2. **OCR Result**: Show text extraction in action
3. **Study Cards**: Show learning interface
4. **Statistics**: Show progress tracking
5. **Settings**: Show privacy policy access

#### Video Recording Tips
1. **Keep it short**: 30-60 seconds max
2. **Show key flows**: OCR → Save → Learn → Stats
3. **Highlight unique features**: Photo-based learning
4. **Show error handling**: Permission denial, network issues
5. **Use clear captions**: Explain what's happening

#### Tools for Screenshots/Video
- **iOS**: QuickTime Player (built-in)
- **Android**: Built-in screen recorder or ADB
- **Cross-platform**: OBS Studio, Loom

### Emergency Response Plan

If app gets rejected multiple times:

1. **Document All Issues**: Keep detailed log of rejection reasons
2. **Contact Support**: Reach out to store support for clarification
3. **Consider Alternative Approach**: May need to simplify features
4. **Get External Review**: Ask other developers for feedback
5. **Prepare Fallback**: Consider alternative app stores if needed

### Resources

- **App Store Review Guidelines**: https://developer.apple.com/app-store/review/guidelines/
- **Google Play Policy**: https://support.google.com/googleplay/android-developer/answer/9859348
- **Flutter Store Deployment**: https://docs.flutter.dev/deployment
- **Privacy Policy Generator**: https://www.privacypolicygenerator.info/
