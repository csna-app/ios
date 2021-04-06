import XCTest
@testable import CSNA

class SVGTests: XCTestCase {
    
    func testSVGPath() {
        let shape = UIBezierPath()
        shape.move(to: CGPoint(x: 3, y: 3))
        shape.addLine(to: CGPoint(x: 6, y: 5))
        shape.addLine(to: CGPoint(x: 6, y: 1))
        shape.addLine(to: CGPoint(x: 10, y: 1))
        shape.addCurve(to: CGPoint(x: 5, y: 9), controlPoint1: CGPoint(x: 10, y: 5), controlPoint2: CGPoint(x: 9, y: 9))
        shape.addCurve(to: CGPoint(x: 1, y: 6), controlPoint1: CGPoint(x: 3, y: 9), controlPoint2: CGPoint(x: 1, y: 8))
        shape.addCurve(to: CGPoint(x: 1, y: 0), controlPoint1: CGPoint(x: 1, y: 4), controlPoint2: CGPoint(x: -1, y: 0))
        shape.addLine(to: CGPoint(x: 3, y: 0))
        shape.addCurve(to: CGPoint(x: 5, y: 1), controlPoint1: CGPoint(x: 4, y: 0), controlPoint2: CGPoint(x: 5, y: 0))
        shape.addCurve(to: CGPoint(x: 4, y: 3), controlPoint1: CGPoint(x: 5, y: 2), controlPoint2: CGPoint(x: 5, y: 3))
        shape.close()
        
        let paths = [
            "M 3 3 L 6 5 V 1 H 10 C 10 5 9 9 5 9 C 3 9 1 8 1 6 C 1 4 -1 0 1 0 L 3 0 C 4 0 5 0 5 1 C 5 2 5 3 4 3 Z",
            "M3 3L6 5V1H10C10 5 9 9 5 9C3 9 1 8 1 6C1 4-1 0 1 0L3 0C4 0 5 0 5 1C5 2 5 3 4 3Z",
            "M3 3L6 5V1H10C10 5 9 9 5 9 3 9 1 8 1 6 1 4-1 0 1 0L3 0C4 0 5 0 5 1 5 2 5 3 4 3Z",
            "m 3 3 l 3 2 v -4 h 4 c 0 4 -1 8 -5 8 c -2 0 -4 -1 -4 -3 c 0 -2 -2 -6 0 -6 l 2 0 c 1 0 2 0 2 1 c 0 1 0 2 -1 2 z",
            "m3 3l3 2v-4h4c0 4-1 8-5 8c-2 0-4-1-4-3c0-2-2-6 0-6l2 0c1 0 2 0 2 1c0 1 0 2-1 2z",
            "m3 3l3 2v-4h4c0 4-1 8-5 8 -2 0-4-1-4-3 0-2-2-6 0-6l2 0c1 0 2 0 2 1 0 1 0 2-1 2z",
            "M,3,3,L,6,5,V,1,H,10,C,10,5,9,9,5,9,C,3,9,1,8,1,6,C,1,4,-1,0,1,0,L,3,0,C,4,0,5,0,5,1,C,5,2,5,3,4,3,Z",
            "M3,3L6,5V1H10C10,5,9,9,5,9C3,9,1,8,1,6C1,4-1,0,1,0L3,0C4,0,5,0,5,1C5,2,5,3,4,3Z",
            "M3,3L6,5V1H10C10,5,9,9,5,9,3,9,1,8,1,6,1,4-1,0,1,0L3,0C4,0,5,0,5,1,5,2,5,3,4,3Z",
            "m,3,3,l,3,2,v,-4,h,4,c,0,4,-1,8,-5,8,c,-2,0,-4,-1,-4,-3,c,0,-2,-2,-6,0,-6,l,2,0,c,1,0,2,0,2,1,c,0,1,0,2,-1,2,z",
            "m3,3l3,2v-4h4c0,4-1,8-5,8c-2,0-4-1-4-3c0-2-2-6,0-6l2,0c1,0,2,0,2,1c0,1,0,2-1,2z",
            "m3,3l3,2v-4h4c0,4-1,8-5,8,-2,0-4-1-4-3,0-2-2-6,0-6l2,0c1,0,2,0,2,1,0,1,0,2-1,2z"
        ]
        
        for path in paths {
            let bezier = UIBezierPath(from: path)
            XCTAssertEqual(bezier, shape, "\(bezier) is not equal to \(path)")
        }
        
    }

}
