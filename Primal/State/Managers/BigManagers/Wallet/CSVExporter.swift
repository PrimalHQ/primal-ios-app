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
      
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }()

    // MARK: - CSV headers
    private static let csvHeaders = [
        "Type", "Amount", "Fee", "State", "TransactionDate", "Note", "TransactionId", "Invoice",
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
        let amountInSats = Int(tx.amountInBtc * Double(SAT_PER_BTC))
        let feeInSats = Int((Double(tx.totalFeeInBtc ?? "") ?? 0) * Double(SAT_PER_BTC))
        
        let values: [String?] = [
            tx.type.name,
            String(amountInSats),
            String(feeInSats),
            tx.state.name,
            tx.completedAt.map { dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval($0.int64Value))) },
            tx.note,
            tx.transactionId,
            tx.invoice,
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
