import SpriteKit
import CoreText

struct FontHelper {
    /// Load and register a custom font from asset, return the font name to use in SKLabelNode
    static func loadCustomFont(assetName: String, tempFileName: String) -> String {
        let tempDir = FileManager.default.temporaryDirectory
        let fontURL = tempDir.appendingPathComponent(tempFileName)

        // Tulis file font ke temp jika belum ada
        if !FileManager.default.fileExists(atPath: fontURL.path) {
            if let fontAsset = NSDataAsset(name: assetName) {
                do {
                    try fontAsset.data.write(to: fontURL)
                } catch {
                    return "Menlo-Bold"
                }
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
        return "Menlo-Bold"
    }
} 
