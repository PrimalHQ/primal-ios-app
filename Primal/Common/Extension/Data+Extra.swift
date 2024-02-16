//
//  Data+Extra.swift
//  Primal
//
//  Created by Pavle Stevanović on 14.2.24..
//

import Foundation
import CryptoKit

extension Data {
    func hash256() -> String {
        let digest = SHA256.hash(data: self)
        let hashString = digest
            .compactMap { String(format: "%02x", $0) }
            .joined()
        return hashString
    }
    
    func chunked(size: Int) -> [Data] {
        var chunks = [Data]()
        
        withUnsafeBytes { (u8Ptr: UnsafeRawBufferPointer) in
            guard let mutRawPointer = UnsafeMutableRawPointer(mutating: u8Ptr.baseAddress) else { return }
            let totalSize = count
            var offset = 0

            while offset < totalSize {
                let chunkSize = offset + size > totalSize ? totalSize - offset : size
                let chunk = Data(bytesNoCopy: mutRawPointer+offset, count: chunkSize, deallocator: Data.Deallocator.none)
                chunks.append(chunk)
                offset += chunkSize
            }
        }
        
        return chunks
    }
}
