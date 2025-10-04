# Billing Implementation Notes

## Overview

This document provides technical notes and testing procedures for the billing implementation in Snap JP Learn App.

## Product Configuration

### Product IDs
- **Monthly Subscription**: `pro_monthly`
- **Lifetime Purchase**: `pro_lifetime`

### Pricing Strategy
- Monthly: Competitive monthly subscription for regular users
- Lifetime: One-time purchase for dedicated learners
- Both products unlock unlimited card creation and advanced features

## Testing Procedures

### Google Play Console Testing

#### 1. License Testing Setup
1. Go to Google Play Console → App → License testing
2. Add test accounts (email addresses)
3. Set license response to "RESPOND_NORMALLY" or "RESPOND_WITH_LICENSED"
4. Upload APK with test track

#### 2. Test Purchase Flow
1. Install app on test device
2. Sign in with test account
3. Navigate to Settings → Pro features
4. Tap "Upgrade Now" → Select monthly or lifetime
5. Complete test purchase (no real money charged)
6. Verify Pro features unlock immediately
7. Test restore purchases functionality

#### 3. Common Test Scenarios
- **New Purchase**: First-time purchase should work
- **Already Owned**: Attempting to buy owned product should show appropriate message
- **Network Error**: Purchase should handle network failures gracefully
- **User Cancellation**: Cancelled purchases should not affect app state
- **Restore Purchases**: Should restore previous purchases on new device

### iOS App Store Testing

#### 1. Sandbox Testing Setup
1. Create sandbox test accounts in App Store Connect
2. Sign out of App Store on test device
3. Sign in with sandbox account when prompted during purchase

#### 2. Test Purchase Flow
1. Install app via TestFlight or Xcode
2. Navigate to Pro features
3. Initiate purchase with sandbox account
4. Verify purchase completes and features unlock
5. Test restore purchases

#### 3. Sandbox Limitations
- Sandbox purchases expire after 6 months
- Some features may behave differently in sandbox
- Receipt validation works differently

## Price Localization

### Supported Currencies
The app automatically displays prices in local currency based on user's region:
- **JPY**: ¥300/month, ¥2,980 (lifetime)
- **USD**: $2.99/month, $29.99 (lifetime)
- **EUR**: €2.99/month, €29.99 (lifetime)
- **GBP**: £2.99/month, £29.99 (lifetime)

### Price Display Format
- Monthly: `[PRICE]/month [CURRENCY]`
- Lifetime: `[PRICE] (one-time) [CURRENCY]`
- Additional info: "Billed monthly" for subscriptions

### Tax Information
- Prices may include applicable taxes based on user's region
- Tax calculation handled by platform (Google Play/App Store)
- No additional tax handling required in app

## Error Handling

### Common Error Codes

#### Google Play Billing
- `BILLING_RESPONSE_RESULT_USER_CANCELED`: User cancelled purchase
- `BILLING_RESPONSE_RESULT_ITEM_ALREADY_OWNED`: User already owns product
- `BILLING_RESPONSE_RESULT_ITEM_UNAVAILABLE`: Product not available
- `BILLING_RESPONSE_RESULT_NETWORK_ERROR`: Network connectivity issues
- `BILLING_RESPONSE_RESULT_SERVICE_UNAVAILABLE`: Billing service unavailable

#### iOS StoreKit
- `SKErrorPaymentCancelled`: User cancelled purchase
- `SKErrorPaymentNotAllowed`: Payment not allowed
- `SKErrorStoreProductNotAvailable`: Product not available
- `SKErrorPaymentInvalid`: Invalid payment

### Error Recovery
1. **Network Errors**: Show retry option, maintain current state
2. **Cancellation**: No action needed, user can retry
3. **Already Owned**: Redirect to restore purchases or show success
4. **Service Unavailable**: Show maintenance message, retry later

## Entitlement Management

### Pro Status Storage
- Stored in SharedPreferences with key `is_pro_user`
- Includes purchase date and product ID for validation
- Automatically synced across app sessions

### Self-Repair Mechanism
- App startup: Verify past purchases
- Background: Periodic verification (if needed)
- Manual: User-triggered restore purchases

### Validation Logic
1. Check local pro status
2. Query platform for purchase history
3. Compare and repair inconsistencies
4. Update local state if needed

## Security Considerations

### Receipt Validation
- Currently client-side only (sufficient for MVP)
- Future enhancement: Server-side receipt validation
- Protects against basic tampering attempts

### Product ID Validation
- Hardcoded product IDs prevent unauthorized purchases
- Server-side validation recommended for production
- Regular audit of purchase logs

## Performance Optimization

### Purchase Service Initialization
- Lazy initialization on first use
- Cached product details for faster display
- Minimal network requests

### Error Recovery
- Exponential backoff for retry attempts
- Graceful degradation on failures
- User-friendly error messages

## Monitoring and Analytics

### Key Metrics to Track
- Purchase conversion rate
- Restore purchase success rate
- Error rates by type
- User satisfaction with billing flow

### Logging
- All purchase attempts (success/failure)
- Error codes and messages
- User actions (upgrade, restore, cancel)
- Performance metrics (load times, etc.)

## Common Issues and Solutions

### Issue: "Purchase not recognized"
**Solution**: 
1. Check product ID configuration
2. Verify app bundle ID matches store listing
3. Ensure test account has proper permissions
4. Try restore purchases

### Issue: "Billing service unavailable"
**Solution**:
1. Check Google Play Services version
2. Verify device compatibility
3. Try again after network connectivity restored
4. Check Play Console for service status

### Issue: "Product not found"
**Solution**:
1. Verify product IDs in store console
2. Check app version compatibility
3. Ensure products are published
4. Wait for store propagation (up to 24 hours)

### Issue: "Restore not working"
**Solution**:
1. Verify user is signed in with correct account
2. Check purchase history in store
3. Ensure app version supports restore
4. Try manual restore via store settings

## Future Enhancements

### Planned Features
1. **Server-side receipt validation**: Enhanced security
2. **Subscription management**: Better renewal handling
3. **Promotional pricing**: Special offers and discounts
4. **Family sharing**: Share purchases across family accounts
5. **Usage analytics**: Track feature usage by subscription status

### Technical Debt
1. Replace client-side validation with server-side
2. Implement proper subscription lifecycle management
3. Add comprehensive error tracking and reporting
4. Optimize purchase flow for better conversion

## Support and Troubleshooting

### User Support Checklist
1. Verify purchase in store account
2. Check app version and updates
3. Try restore purchases
4. Clear app data and reinstall (last resort)
5. Contact store support if issue persists

### Developer Debugging
1. Check logs for error codes
2. Verify product configuration
3. Test with different accounts
4. Check store console for issues
5. Monitor crash reports and analytics

## Compliance Notes

### App Store Guidelines
- Clear pricing display before purchase
- No misleading subscription terms
- Proper cancellation instructions
- Transparent data usage

### Google Play Policies
- Accurate product descriptions
- Fair pricing practices
- Proper subscription management
- Clear refund policies

### Privacy Compliance
- No unnecessary data collection
- Transparent data usage
- User consent for purchases
- Secure payment processing

---

*Last updated: [Current Date]*
*Version: 1.0*
*Author: Development Team*
