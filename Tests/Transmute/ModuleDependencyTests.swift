/*
 This source file is part of the Swift.org open source project

 Copyright 2015 - 2016 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

@testable import Transmute
import class PackageType.Module
import XCTest

func testModules(file: StaticString = #file, line: UInt = #line, body: () throws -> Void) {
    do {
        try body()
    } catch {
        XCTFail("\(error)", file: file, line: line)
    }
}

class ModuleDependencyTests: XCTestCase {

    func test1() {
        testModules {
            let t1 = try Module(name: "t1")
            let t2 = try Module(name: "t2")
            let t3 = try Module(name: "t3")

            t3.depends(on: t2)
            t2.depends(on: t1)

            XCTAssertEqual(t3.recursiveDeps, [t2, t1])
            XCTAssertEqual(t2.recursiveDeps, [t1])
        }
    }

    func test2() {
        testModules {
            let t1 = try Module(name: "t1")
            let t2 = try Module(name: "t2")
            let t3 = try Module(name: "t3")
            let t4 = try Module(name: "t3")

            t4.depends(on: t2)
            t4.depends(on: t3)
            t4.depends(on: t1)
            t3.depends(on: t2)
            t3.depends(on: t1)
            t2.depends(on: t1)

            XCTAssertEqual(t4.recursiveDeps, [t3, t2, t1])
            XCTAssertEqual(t3.recursiveDeps, [t2, t1])
            XCTAssertEqual(t2.recursiveDeps, [t1])
        }
    }

    func test3() {
        testModules {
            let t1 = try Module(name: "t1")
            let t2 = try Module(name: "t2")
            let t3 = try Module(name: "t3")
            let t4 = try Module(name: "t4")

            t4.depends(on: t1)
            t4.depends(on: t2)
            t4.depends(on: t3)
            t3.depends(on: t2)
            t3.depends(on: t1)
            t2.depends(on: t1)

            XCTAssertEqual(t4.recursiveDeps, [t3, t2, t1])
            XCTAssertEqual(t3.recursiveDeps, [t2, t1])
            XCTAssertEqual(t2.recursiveDeps, [t1])
        }
    }

    func test4() {
        testModules {
            let t1 = try Module(name: "t1")
            let t2 = try Module(name: "t2")
            let t3 = try Module(name: "t3")
            let t4 = try Module(name: "t4")

            t4.depends(on: t3)
            t3.depends(on: t2)
            t2.depends(on: t1)

            XCTAssertEqual(t4.recursiveDeps, [t3, t2, t1])
            XCTAssertEqual(t3.recursiveDeps, [t2, t1])
            XCTAssertEqual(t2.recursiveDeps, [t1])
        }
    }

    func test5() {
        testModules {
            let t1 = try Module(name: "t1")
            let t2 = try Module(name: "t2")
            let t3 = try Module(name: "t3")
            let t4 = try Module(name: "t4")
            let t5 = try Module(name: "t5")
            let t6 = try Module(name: "t6")

            t6.depends(on: t5)
            t6.depends(on: t4)
            t5.depends(on: t2)
            t4.depends(on: t3)
            t3.depends(on: t2)
            t2.depends(on: t1)

            // precise order is not important, but it is important that the following are true
            let t6rd = t6.recursiveDeps
            XCTAssertEqual(t6rd.index(of: t3)!, t6rd.index(after: t6rd.index(of: t4)!))
            XCTAssert(t6rd.index(of: t5)! < t6rd.index(of: t2)!)
            XCTAssert(t6rd.index(of: t5)! < t6rd.index(of: t1)!)
            XCTAssert(t6rd.index(of: t2)! < t6rd.index(of: t1)!)
            XCTAssert(t6rd.index(of: t3)! < t6rd.index(of: t2)!)

            XCTAssertEqual(t5.recursiveDeps, [t2, t1])
            XCTAssertEqual(t4.recursiveDeps, [t3, t2, t1])
            XCTAssertEqual(t3.recursiveDeps, [t2, t1])
            XCTAssertEqual(t2.recursiveDeps, [t1])
        }
    }

    func test6() {
        testModules {
            let t1 = try Module(name: "t1")
            let t2 = try Module(name: "t2")
            let t3 = try Module(name: "t3")
            let t4 = try Module(name: "t4")
            let t5 = try Module(name: "t5")
            let t6 = try Module(name: "t6")

            t6.depends(on: t4)  // same as above, but
            t6.depends(on: t5)  // these two swapped
            t5.depends(on: t2)
            t4.depends(on: t3)
            t3.depends(on: t2)
            t2.depends(on: t1)

            // precise order is not important, but it is important that the following are true
            let t6rd = t6.recursiveDeps
            XCTAssertEqual(t6rd.index(of: t3)!, t6rd.index(after: t6rd.index(of: t4)!))
            XCTAssert(t6rd.index(of: t5)! < t6rd.index(of: t2)!)
            XCTAssert(t6rd.index(of: t5)! < t6rd.index(of: t1)!)
            XCTAssert(t6rd.index(of: t2)! < t6rd.index(of: t1)!)
            XCTAssert(t6rd.index(of: t3)! < t6rd.index(of: t2)!)

            XCTAssertEqual(t5.recursiveDeps, [t2, t1])
            XCTAssertEqual(t4.recursiveDeps, [t3, t2, t1])
            XCTAssertEqual(t3.recursiveDeps, [t2, t1])
            XCTAssertEqual(t2.recursiveDeps, [t1])
        }
    }
}

extension Module {
    private func depends(on target: Module) {
        dependencies.append(target)
    }
    
    private var recursiveDeps: [Module] {
        sort(self)
        return dependencies
    }
}
