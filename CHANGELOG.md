# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-10-12

### Release Candidate 1

#### Added
- 🎯 **Micro-interactions & Haptics**
  - Added AnimatedScale animations to major buttons (camera, gallery, OCR)
  - Added haptic feedback (lightImpact, selectionClick) for important operations
  - Enhanced button press feedback for better user experience

- 🎨 **UI Polish & Accessibility**
  - Improved text wrapping for long i18n strings
  - Enhanced Dynamic Type support with proper spacing adjustments
  - Optimized dark theme contrast for better visibility
  - Added tooltips to major icons and buttons
  - Added SemanticsService announcements for state changes (sync completion, purchase completion)

- 🐛 **Bug Fixes & Edge Cases**
  - Fixed image preview issues for large/portrait images using FittedBox and BoxFit.contain
  - Added OCR cancel double-request prevention with execution flags
  - Implemented offline sync conflict prevention with exclusive control
  - Fixed Paywall multiple push prevention with re-entry tokens

- ⚡ **Performance Optimizations**
  - Limited thumbnail generation parallelism to device CPU core count
  - Added image processing retry mechanism for large images (reduced size retry)
  - Optimized image cache settings for better memory management
  - Reduced startup preload for statistics and dictionary loading

- 🛡️ **Crash Resistance & Error Handling**
  - Added comprehensive exception handling with safe fallbacks
  - Created common error banner component for consistent error display
  - Implemented image processing failure recovery (resize and retry)
  - Added safe navigation and state recovery mechanisms

- 📱 **Store Submission Preparation**
  - Updated version to 1.0.0 (100) for production release
  - Configured Android build settings (minSdk 23, targetSdk 36)
  - Updated iOS privacy descriptions for App Store compliance
  - Added dynamic version information display in Settings
  - Enhanced Pro subscription text with store compliance requirements
  - Added legal links (Terms of Service, Privacy Policy, Legal Information)

#### Technical Improvements
- Enhanced OCR service with double-execution prevention
- Improved sync engine with conflict resolution
- Added IsolateHelper for parallel processing management
- Optimized image store with retry mechanisms
- Updated FeatureFlags for production defaults

#### Documentation
- Created comprehensive QA checklist for release testing
- Added detailed store submission procedures
- Updated release preparation documentation

---

## Previous Versions

### [0.9.0] - 2024-10-11
- Initial beta release with core OCR functionality
- Basic SRS learning system implementation
- Pro subscription features
- Offline sync capabilities

### [0.8.0] - 2024-10-10
- UI/UX improvements
- Performance optimizations
- Bug fixes and stability enhancements

### [0.7.0] - 2024-10-09
- Added multi-language support
- Implemented accessibility features
- Enhanced error handling

---

## Release Notes

### Version 1.0.0 Release Candidate 1
This is the first release candidate for the Snap JP Learn App, prepared for submission to Google Play Store and App Store. The app includes:

- **Core Features**: AI-powered OCR for Japanese text recognition, SRS learning system, Pro subscription
- **Platform Support**: Android (API 23+) and iOS (17+)
- **Accessibility**: Full screen reader support, haptic feedback, semantic announcements
- **Performance**: Optimized for various device capabilities and network conditions
- **Compliance**: Store-ready with proper privacy descriptions and legal documentation

### Known Issues
- ProGuard/R8 configuration temporarily disabled for release build
- Some test files may show linter warnings (non-blocking for release)

### Next Steps
- Final QA testing using provided checklist
- Store submission following documented procedures
- Post-release monitoring and user feedback collection
