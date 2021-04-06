import XCTest
@testable import CSNA

class UtilityTests: XCTestCase {
    
    func testLocalizedString() {
        //TODO: Implement
    }
    
    func testLocalizedTime() {
        //TODO: Implement
    }
    
    func testPointDistance() {
        let p1 = CGPoint(x: 5, y: 2)
        let p2 = CGPoint(x: 2, y: 6)
        XCTAssertEqual(p1.distance(to: p2), 5)
        
        let p3 = CGPoint(x: -4, y: -2)
        let p4 = CGPoint(x: 2, y: 6)
        XCTAssertEqual(p3.distance(to: p4), 10)
        
        let p5 = CGPoint(x: -4, y: -2)
        let p6 = CGPoint(x: -19, y: -22)
        XCTAssertEqual(p5.distance(to: p6), 25)
    }
    
    func testDictionaryFirstLast() {
        //TODO: Implement
    }
    
}
