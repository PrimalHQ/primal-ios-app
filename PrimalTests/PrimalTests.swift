//
//  PrimalTests.swift
//  PrimalTests
//
//  Created by Nikola Lukovic on 20.2.23..
//

import XCTest
@testable import Primal

final class PrimalTests: XCTestCase {
    func testEncryptDecryptDirectMessages() {
        let keypair = NostrKeypair.generate()
        let message = "test"
        
        guard
            let privkey = keypair?.hexVariant.privkey,
            let pubkey = keypair?.hexVariant.pubkey,
            let encrypted = encryptDirectMessage(message, privkey: privkey, pubkey: pubkey),
            let decrypted = decryptDirectMessage(encrypted, privkey: privkey, pubkey: pubkey)
        else { return }
        
        XCTAssertEqual(message, decrypted)
    }
}
