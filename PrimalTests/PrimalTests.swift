//
//  PrimalTests.swift
//  PrimalTests
//
//  Created by Nikola Lukovic on 20.2.23..
//

import XCTest
@testable import Primal

final class PrimalTests: XCTestCase {

    func testBech32Decode() {
        let result = bech32Decode(bech: "1j7uc37l5lzyqfyley4c3ux7cqeshk5y060fgxy3gs5r7gtu2xd5qyc8lvw")
        
        print(result)
    }
}
