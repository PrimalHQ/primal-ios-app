//
//  WalletLogRecorder.swift
//  Primal
//
//  Created by Pavle Stevanović on 2.4.26..
//

import Foundation
import PrimalShared

extension String {
    static let walletLogRecordingEnabledKey = "walletLogRecordingEnabledKey"
}

final class WalletLogRecorder {
    static let instance = WalletLogRecorder()

    private let maxFileSize: UInt64 = 10 * 1024 * 1024  // 10 MB
    private let maxFileCount = 10

    private let queue = DispatchQueue(label: "com.primal.walletLogRecorder", qos: .utility)
    private var fileHandle: FileHandle?
    private var currentFileURL: URL?
    private var currentFileSize: UInt64 = 0

    private let dateFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private var logsDirectory: URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        return appSupport.appendingPathComponent("WalletLogs", isDirectory: true)
    }

    var isRecording: Bool {
        UserDefaults.standard.bool(forKey: .walletLogRecordingEnabledKey)
    }

    // MARK: - Public API

    func startRecording() {
        UserDefaults.standard.set(true, forKey: .walletLogRecordingEnabledKey)
        try? FileManager.default.createDirectory(at: logsDirectory, withIntermediateDirectories: true)

        WalletRepositoryFactory.shared.setLogWriter { [weak self] entry in
            self?.handleLogEntry(entry)
        }
    }

    func stopRecording() {
        UserDefaults.standard.set(false, forKey: .walletLogRecordingEnabledKey)
        WalletRepositoryFactory.shared.removeLogWriter()

        queue.async { [weak self] in
            self?.closeFile()
        }
    }

    func logFileURLs() -> [URL] {
        (try? FileManager.default.contentsOfDirectory(
            at: logsDirectory,
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: .skipsHiddenFiles
        )
        .filter { $0.pathExtension == "jsonl" }
        .sorted { ($0.modificationDate ?? .distantPast) < ($1.modificationDate ?? .distantPast) })
        ?? []
    }

    func clearLogs() {
        if isRecording {
            stopRecording()
        }
        queue.async { [weak self] in
            guard let self else { return }
            for file in self.logFileURLs() {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }

    // MARK: - Private

    private func handleLogEntry(_ entry: LogEntry) {
        queue.async { [weak self] in
            self?.writeEntry(level: entry.level, tag: entry.tag, message: entry.message)
        }
    }

    private func writeEntry(level: String, tag: String?, message: String) {
        ensureFileOpen()

        var dict: [String: Any] = [
            "ts": dateFormatter.string(from: Date()),
            "level": String(level.prefix(1)),
            "msg": message
        ]
        if let tag { dict["tag"] = tag }

        guard let data = try? JSONSerialization.data(withJSONObject: dict),
              var line = String(data: data, encoding: .utf8) else { return }

        line.append("\n")
        guard let lineData = line.data(using: .utf8) else { return }

        fileHandle?.write(lineData)
        currentFileSize += UInt64(lineData.count)

        if currentFileSize >= maxFileSize {
            rotateFile()
        }
    }

    private func ensureFileOpen() {
        guard fileHandle == nil else { return }

        let fileName = "wallet_log_\(Int(Date().timeIntervalSince1970 * 1000)).jsonl"
        let fileURL = logsDirectory.appendingPathComponent(fileName)
        FileManager.default.createFile(atPath: fileURL.path, contents: nil)
        fileHandle = try? FileHandle(forWritingTo: fileURL)
        fileHandle?.seekToEndOfFile()
        currentFileURL = fileURL
        currentFileSize = fileHandle?.offsetInFile ?? 0
    }

    private func rotateFile() {
        closeFile()
        pruneOldFiles()
    }

    private func closeFile() {
        fileHandle?.closeFile()
        fileHandle = nil
        currentFileURL = nil
        currentFileSize = 0
    }

    private func pruneOldFiles() {
        let files = logFileURLs()
        if files.count >= maxFileCount {
            for file in files.prefix(files.count - maxFileCount + 1) {
                try? FileManager.default.removeItem(at: file)
            }
        }
    }
}

private extension URL {
    var modificationDate: Date? {
        try? resourceValues(forKeys: [.contentModificationDateKey]).contentModificationDate
    }
}
