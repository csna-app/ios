import XCTest

func testLoop<T: Equatable>(count: Int, generator: ((Int) -> (T, T))) {
    for n in 0..<count {
        let (first, second) = generator(n)
        XCTAssertEqual(first, second, "\(first) is not equal to \(second)")
    }
}
