# Text with custom fonts is invisible in iOS App Extensions (Fabric / New Architecture)

## Description

When using React Native 0.84+ with the New Architecture (Fabric) in an iOS App Extension (Share Extension, Action Extension, etc.), all `<Text>` components that use a custom `fontFamily` are invisible. Text using the system font renders fine.

Setting `allowFontScaling={false}` on individual `<Text>` components works around the issue.

## Root Cause

`RCTFontSizeMultiplier()` in `React/Fabric/Surface/RCTFabricSurface.mm` calls:

```objc
return mapping[RCTSharedApplication().preferredContentSizeCategory].floatValue;
```

In App Extensions, `RCTSharedApplication()` returns `nil` (because `UIApplication.sharedApplication` is unavailable in extensions). This causes:

1. `nil.preferredContentSizeCategory` → `nil`
2. `mapping[nil]` → `nil`
3. `nil.floatValue` → `0.0`

This `0.0` is stored as `layoutContext.fontSizeMultiplier`, which propagates to all text measurement:

```objc
// In RCTFontWithFontProperties (prebuilt binary):
CGFloat effectiveFontSize = fontProperties.sizeMultiplier * fontProperties.size;
// effectiveFontSize = 0.0 * 14.0 = 0.0
```

**System fonts survive** because `[UIFont systemFontOfSize:0]` returns a 12pt default font. But **custom fonts fail** because `[UIFont fontWithName:@"CustomFont" size:0]` returns `nil`, falling through to a Helvetica fallback with incorrect metrics — resulting in zero-sized text layout.

## Proposed Fix

Replace `RCTSharedApplication().preferredContentSizeCategory` with `UITraitCollection.currentTraitCollection.preferredContentSizeCategory`, which works in both apps and extensions:

```objc
// Before (broken in extensions):
return mapping[RCTSharedApplication().preferredContentSizeCategory].floatValue;

// After (works everywhere):
NSString *category;
if (!RCTRunningInAppExtension()) {
    category = RCTSharedApplication().preferredContentSizeCategory;
} else {
    category = UITraitCollection.currentTraitCollection.preferredContentSizeCategory;
}
return mapping[category ?: UIContentSizeCategoryLarge].floatValue;
```

This also correctly handles Dynamic Type accessibility settings in extensions, which the current code silently ignores.

## Reproduction

### Steps

1. Clone this repo
2. `npm install && cd ios && bundle exec pod install && cd ..`
3. Open `ios/FontScalingRepro.xcworkspace` in Xcode
4. **Add a Share Extension target** (see "Xcode Setup" below)
5. Build and run the main app on a simulator
6. Start Metro: `npx react-native start`
7. Open Safari, navigate to any page, tap Share → select "ShareExtension"

### Expected

All text labels render with the Inter font at the correct size.

### Actual

- "System font (default)" rows: **visible** (system font handles size 0 gracefully)
- "Custom font (Inter-Regular)" rows: **invisible** (custom font at size 0 → nil → no text)
- "Custom font + allowFontScaling=false" rows: **visible** (bypasses the broken multiplier)

### Xcode Setup for Share Extension

Since Xcode project targets can't be created from the command line, follow these steps after `pod install`:

1. Open `ios/FontScalingRepro.xcworkspace` in Xcode
2. File → New → Target → **Share Extension**
3. Name it `ShareExtension`, language **Swift**
4. When prompted, activate the scheme
5. Delete the auto-generated `ShareViewController.swift` and storyboard
6. In the ShareExtension target's **Build Settings**:
   - Set **Objective-C Bridging Header** to `ShareExtension/ShareExtension-Bridging-Header.h`
   - Add `$(inherited)` to **Header Search Paths** (recursive)
   - Add `$(inherited)` to **Other Linker Flags**
7. In the ShareExtension target's **Build Phases → Compile Sources**:
   - Add `ShareExtension/ShareExtensionReactHelper.mm`
   - Add `ShareExtension/ShareViewController.swift`
8. In **Build Phases → Copy Bundle Resources**:
   - Add `Inter-Regular.ttf` and `Inter-Bold.ttf` from `assets/fonts/`
9. In the **main app target** (FontScalingRepro):
   - Build Phases → Embed Foundation Extensions → add `ShareExtension.appex`
10. In **Podfile**, the `ShareExtension` target is already configured. Run `pod install` again.
11. Build and run.

## Environment

- React Native: 0.84.1
- Architecture: New (Fabric + Bridgeless)
- iOS: 18.x / 26.x simulator
- Xcode: 17+
- Affects: Any iOS App Extension using Fabric with custom fonts

## Workarounds

### Per-component (JS)
```jsx
<Text style={{fontFamily: 'Inter-Regular'}} allowFontScaling={false}>
  This text will be visible
</Text>
```

### Native swizzle (ObjC++)
Swizzle `RCTFabricSurface._updateLayoutContext` to correct `fontSizeMultiplier` from 0 to 1.0 after the original implementation sets it. See `ShareExtensionReactHelper.mm` in the main project for a working implementation.
