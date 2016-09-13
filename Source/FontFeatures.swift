//
//  FontFeatures.swift
//
//  Created by Brian King on 8/31/16.
//  Copyright © 2016 Raizlabs. All rights reserved.
//

/// Protocol to provide values to be used by UIFontFeatureTypeIdentifierKey and UIFontFeatureSelectorIdentifierKey.
public protocol FontFeatureProvider {
    func featureSettings() -> (Int, Int)
}

public extension UIFont {
    /// Create a new UIFont and attempt to enable the specified font features. The returned font will have all
    /// features enabled that are supported by the font.
    public func font(withFeatures featureProviders: [FontFeatureProvider]) -> UIFont {
        var fontAttributes = fontDescriptor.fontAttributes
        var features = fontAttributes[UIFontDescriptorFeatureSettingsAttribute] as? [StyleAttributes] ?? []
        let newFeatures = featureProviders.map() { $0.featureAttribute() }
        features.append(contentsOf: newFeatures)
        fontAttributes[UIFontDescriptorFeatureSettingsAttribute] = features
        let descriptor = UIFontDescriptor(fontAttributes: fontAttributes)
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}

/// An enumeration representing the kNumberCaseType features.
public enum NumberCase: FontFeatureProvider {
    case upper, lower
    public func featureSettings() -> (Int, Int) {
        switch self {
        case .upper:
            return (kNumberCaseType, kUpperCaseNumbersSelector)
        case .lower:
            return (kNumberCaseType, kLowerCaseNumbersSelector)
        }
    }
}

/// An enumeration representing the kNumberSpacingType features.
public enum NumberSpacing: FontFeatureProvider {
    case monospaced, proportional
    public func featureSettings() -> (Int, Int) {
        switch self {
        case .monospaced:
            return (kNumberSpacingType, kMonospacedNumbersSelector)
        case .proportional:
            return (kNumberSpacingType, kProportionalNumbersSelector)
        }
    }
}

/// An enumeration representing the tracking to be applied.
public enum Tracking {
    case point(CGFloat)
    case adobe(CGFloat)

    func kerning(forFont font: UIFont?) -> CGFloat {
        switch self {
        case .point(let kernValue):
            return kernValue
        case .adobe(let adobeTracking):
            let AdobeTrackingDivisor: CGFloat = 1000.0
            if font == nil {
                print("Can not apply tracking to style when no font is defined, using 0 instead")
            }
            let pointSize = font?.pointSize ?? 0
            return pointSize * (adobeTracking / AdobeTrackingDivisor)
        }
    }
}

extension FontFeatureProvider {
    /// Return a dictionary representing one feature for the attributes key in the font attributes
    func featureAttribute() -> StyleAttributes {
        let featureSettings = self.featureSettings()
        return [
            UIFontFeatureTypeIdentifierKey: featureSettings.0,
            UIFontFeatureSelectorIdentifierKey: featureSettings.1
        ]
    }
}
