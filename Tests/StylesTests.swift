import XCTest
@testable import CSNA

class StylesTests: XCTestCase {
    
    func testStylesValid() {
        let validCharacters = CharacterSet(charactersIn: "MmZzLlHhVvCcSsQqTtAa0123456789-,. ")
        for style in Styles {
            XCTAssert(style.value != "", "\(style.key) returned an empty string")
            XCTAssert(style.value.trimmingCharacters(in: validCharacters).isEmpty, "\(style.key) contains invalid characters")
            XCTAssert(style.value.range(of: "[a-zA-Z][ ,]?[a-zA-Z]", options: .regularExpression, range: nil, locale: nil) == nil, "\(style.key) contains two adjecent letters")
            XCTAssert(style.value.range(of: "^[0-9-,. ]", options: .regularExpression, range: nil, locale: nil) == nil, "\(style.key) starts with an invalid character")
            XCTAssert(style.value.range(of: "[a-yA-Y -,.]$", options: .regularExpression, range: nil, locale: nil) == nil, "\(style.key) ends with an invalid character")
        }
    }
    
    func testStylesAvailable() {
        let keys = ["headPart1", "headPart2", "shirt", "style0", "style1", "style2", "style3", "style4", "style5", "style6", "style7", "style8", "style9", "style10", "style11", "style11part2", "style12", "style13", "style14", "style14part2", "style15", "style16", "style17", "style18", "style19", "style19part2", "style20", "style21", "style22", "style23", "style24", "style25", "style26", "style27", "style28", "style28part2", "style29", "style30"]
        for key in keys {
            XCTAssertNotNil(Styles[key], "Could not find style for \(key)")
        }
    }
    

}
