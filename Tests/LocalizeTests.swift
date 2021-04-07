import XCTest
@testable import CSNA

class LocalizeTests: XCTestCase {
    
    
    func testLocalizedStrings() {
        let base = loadLanguage("en")
        let langs = ["nl"]
        
        for lang in langs {
            let test = loadLanguage(lang)
            for key in base.keys {
                XCTAssert(test.keys.contains(key), "Language \(lang) does not contain \(key)")
            }
        }
        
    }
    
    private func loadLanguage(_ key: String) -> [String: String] {
        guard let url = Bundle.main.url(forResource: "Localizable", withExtension: "strings", subdirectory: "\(key).lproj") else { return [:] }
        guard let dict = NSDictionary(contentsOf: url) as? [String: String] else { return [:] }
        return dict
    }
}
