import XCTest
@testable import CSNA

class HexTests: XCTestCase {
    
    func testThreeDigitHexColor() throws {
        testLoop(count: 25) { _ -> (UIColor, UIColor) in
            let r = Int.random(in: 0..<15)
            let g = Int.random(in: 0..<15)
            let b = Int.random(in: 0..<15)
            let hex = UIColor(hex: toSingleHexString(r, g, b))
            let color = UIColor(red: CGFloat(r)/15, green: CGFloat(g)/15, blue: CGFloat(b)/15, alpha: 1)
            return (hex, color)
        }
    }
    
    func testFourDigitHexColor() throws {
        testLoop(count: 25) { _ -> (UIColor, UIColor) in
            let r = Int.random(in: 0..<15)
            let g = Int.random(in: 0..<15)
            let b = Int.random(in: 0..<15)
            let a = Int.random(in: 0..<15)
            let hex = UIColor(hex: toSingleHexString(r, g, b, a))
            let color = UIColor(red: CGFloat(r)/15, green: CGFloat(g)/15, blue: CGFloat(b)/15, alpha: CGFloat(a)/15)
            return (hex, color)
        }
    }
    
    func testSixDigitHexColor() throws {
        testLoop(count: 25) { _ -> (UIColor, UIColor) in
            let r = Int.random(in: 0..<255)
            let g = Int.random(in: 0..<255)
            let b = Int.random(in: 0..<255)
            let hex = UIColor(hex: toDoubleHexString(r, g, b))
            let color = UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1)
            return (hex, color)
        }
    }
    
    func testEightDigitHexColor() throws {
        testLoop(count: 25) { _ -> (UIColor, UIColor) in
            let r = Int.random(in: 0..<255)
            let g = Int.random(in: 0..<255)
            let b = Int.random(in: 0..<255)
            let a = Int.random(in: 0..<255)
            let hex = UIColor(hex: toDoubleHexString(r, g, b, a))
            let color = UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: CGFloat(a)/255)
            return (hex, color)
        }
    }
    
    func testDarkenColor() throws {
        testLoop(count: 25) { _ -> (UIColor, UIColor) in
            let r = CGFloat(Float.random(in: 0..<1))
            let g = CGFloat(Float.random(in: 0..<1))
            let b = CGFloat(Float.random(in: 0..<1))
            let a = CGFloat(Float.random(in: 0..<1))
            let d = CGFloat(Float.random(in: -1..<1))
            let color = UIColor(red: r, green: g, blue: b, alpha: a).darken(by: d)
            let testColor = UIColor(red: r - d, green: g - d, blue: b - d, alpha: a)
            return (color, testColor)
        }
    }
    
    private func toSingleHexString(_ ints: Int...) -> String {
        return ints.map({ String(format:"%01X", $0) }).joined()
    }
    
    private func toDoubleHexString(_ ints: Int...) -> String {
        return ints.map({ String(format:"%02X", $0) }).joined()
    }
}
