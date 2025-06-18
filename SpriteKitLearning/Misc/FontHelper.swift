import SpriteKit
import CoreText

struct FontHelper {
    /// Load and register a custom font from asset, return the font name to use in SKLabelNode
    static func loadCustomFont(assetName: String, tempFileName: String) -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let fontURL = tempDir.appendingPathComponent(tempFileName)

        // Selalu tulis ulang file font ke temp
        if let fontAsset = NSDataAsset(name: assetName) {
            do {
                try fontAsset.data.write(to: fontURL)
            } catch {
                print("❌ Failed to write font data to temp file: \(error)")
                return "Menlo-Bold"
            }
        }

        // Selalu register font setiap app start
        var error: Unmanaged<CFError>?
        _ = CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, &error)

        // Ambil nama font dari file
        if let descriptors = CTFontManagerCreateFontDescriptorsFromURL(fontURL as CFURL) as? [CTFontDescriptor] {
            for desc in descriptors {
                if let fontName = CTFontDescriptorCopyAttribute(desc, kCTFontNameAttribute) as? String {
                    return fontName
                }
            }
        }
        print("⚠️ Font name not found, using fallback")
        return "Menlo-Bold"
    }
} 
