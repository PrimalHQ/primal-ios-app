//
//  CSVExporter.swift
//  Primal
//
//  Created by Pavle Stevanović on 18. 2. 2026..
//

import PrimalShared
import Foundation
import UIKit

class CSVExporter {
      
    // MARK: - CSV headers (matches Android column order exactly)
    private static let csvHeaders = [
        "transactionId", "type", "state",
        "createdAt", "updatedAt", "completedAt", "userId",
        "note", "invoice", "amount", "amountInUsd",
        "exchangeRate", "totalFeeInBtc", "otherUserId",
        "otherLightningAddress", "otherUserProfile", "preimage",
        "paymentHash", "zappedEntity", "zappedByUserId",
        "onChainTxId", "onChainAddress", "sparkAddress",
    ]

    // MARK: - CSV building

    static func buildTransactionsCsv(_ transactions: [Transaction]) -> String {
        var lines = [csvHeaders.joined(separator: ",")]
        for tx in transactions {
            lines.append(csvRow(for: tx))
        }
        return lines.joined(separator: "\n")
    }

    private static func csvRow(for tx: Transaction) -> String {
        // Type-specific fields s— default to nil for types that don't have them
        var otherUserId: String? = nil
        var otherLightningAddress: String? = nil
        var otherUserProfile: String? = nil
        var preimage: String? = nil
        var paymentHash: String? = nil
        var zappedEntity: String? = nil
        var zappedByUserId: String? = nil
        var onChainTxId: String? = nil
        var onChainAddress: String? = nil
        var sparkAddress: String? = nil

        // NOTE: Adjust these type names to match the KMP-generated Swift interface in your project.
        switch tx {
        case let t as Transaction.Lightning:
            otherUserId = t.otherUserId
            otherLightningAddress = t.otherLightningAddress
            otherUserProfile = t.otherUserProfile?.displayName ??
            t.otherUserProfile?.handle ?? t.otherUserProfile?.profileId
            preimage = t.preimage
            paymentHash = t.paymentHash

        case let t as Transaction.Zap:
            otherUserId = t.otherUserId
            otherLightningAddress = t.otherLightningAddress
            otherUserProfile = t.otherUserProfile?.displayName ??
            t.otherUserProfile?.handle ?? t.otherUserProfile?.profileId
            preimage = t.preimage
            paymentHash = t.paymentHash
            zappedEntity = t.zappedEntity.toNostrString()
            zappedByUserId = t.zappedByUserId

        case let t as Transaction.OnChain:
            onChainTxId = t.onChainTxId
            onChainAddress = t.onChainAddress
        case let t as Transaction.Spark:
            sparkAddress = t.sparkAddress
            preimage = t.preimage
            paymentHash = t.paymentHash
        default: // TransactionStorePurchase — no extra fields
        break
        }

        let values: [String?] = [
            tx.transactionId,
            tx.type.name, tx.state.name,
            String(tx.createdAt), String(tx.updatedAt),
            tx.completedAt.map { String($0.int64Value) },
            tx.userId, tx.note, tx.invoice,
            String(Int(tx.amountInBtc * Double(SAT_PER_BTC))),
            tx.amountInUsd.map { String($0.int64Value) },
            tx.exchangeRate, tx.totalFeeInBtc,
            otherUserId, otherLightningAddress, otherUserProfile,
            preimage, paymentHash,
            zappedEntity, zappedByUserId,
            onChainTxId, onChainAddress, sparkAddress,
        ]

        return values.map(csvEscaped).joined(separator: ",")
    }

    /// RFC 4180 compliant field escaping.
    /// Wraps the value in double quotes and doubles any internal quotes
    /// when the value contains commas, quotes, or line breaks.
    private static func csvEscaped(_ value: String?) -> String {
        guard let value else { return "" }
        guard value.contains(",") || value.contains("\"") || value.contains("\n") || value.contains("\r") else {
            return value
        }
        return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    static func exportTransactions(_ transactions: [Transaction], walletType: String, from viewController: UIViewController) {
        let csv = buildTransactionsCsv(transactions)
        let fileName = "\(walletType)_transactions.csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csv.write(to: tempURL, atomically: true, encoding: .utf8)
        } catch {
        // Replace with your app's standard error/alert handling
            print("Failed to write CSV: \(error)")
            return
        }

        let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
        
        viewController.present(activityVC, animated: true)
    }
}
