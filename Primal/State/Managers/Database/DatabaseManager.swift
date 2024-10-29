//
//  DatabaseManager.swift
//  Primal
//
//  Created by Pavle Stevanović on 17.9.24..
//

import Foundation
import GRDB
import os.log

class DatabaseManager {
    private static let sqlLogger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "SQL")

    static let instance = makeShared()
    
    let dbWriter: any DatabaseWriter

    private init(_ dbWriter: any DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
    
    func performUpdates(_ updates: @escaping (Database) throws -> (Void)) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.dbWriter.write { db in
                    try updates(db)
                }
            } catch {
                print("DATABASE ERROR \(error)")
            }
        }
    }
        
    private static func makeShared() -> DatabaseManager {
        do {
            // Apply recommendations from
            // <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/databaseconnections>
            //
            // Create the "Application Support/Database" directory if needed
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(
                for: .applicationSupportDirectory, in: .userDomainMask,
                appropriateFor: nil, create: true)
            let directoryURL = appSupportURL.appendingPathComponent("Database", isDirectory: true)
            
            // Support for tests: delete the database if requested
            if CommandLine.arguments.contains("-reset") {
                try? fileManager.removeItem(at: directoryURL)
            }
            
            // Create the database folder if needed
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            
            // Open or create the database
            let databaseURL = directoryURL.appendingPathComponent("db.sqlite")
            NSLog("Database stored at \(databaseURL.path)")
            let dbPool = try DatabasePool(
                path: databaseURL.path,
                // Use default AppDatabase configuration
                configuration: Self.makeConfiguration()
            )
            
            // Create the AppDatabase
            return try DatabaseManager(dbPool)
        } catch {
            do {
                return try DatabaseManager(DatabaseQueue())
            } catch {
                fatalError("Database error \(error)")
            }
        }
    }
    
    public static func makeConfiguration(_ base: Configuration = Configuration()) -> Configuration {
        var config = base
        
        // An opportunity to add required custom SQL functions or
        // collations, if needed:
        // config.prepareDatabase { db in
        //     db.add(function: ...)
        // }
        
        // Log SQL statements if the `SQL_TRACE` environment variable is set.
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/database/trace(options:_:)>
        if ProcessInfo.processInfo.environment["SQL_TRACE"] != nil {
            config.prepareDatabase { db in
                db.trace {
                    // It's ok to log statements publicly. Sensitive
                    // information (statement arguments) are not logged
                    // unless config.publicStatementArguments is set
                    // (see below).
                    os_log("%{public}@", log: sqlLogger, type: .debug, String(describing: $0))
                }
            }
        }
        
#if DEBUG
        // Protect sensitive information by enabling verbose debugging in
        // DEBUG builds only.
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/configuration/publicstatementarguments>
        config.publicStatementArguments = true
#endif
        
        return config
    }

}

private extension DatabaseManager {
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
//        #if DEBUG
        // Speed up development by nuking the database when migrations change
        // See <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/migrations>
        migrator.eraseDatabaseOnSchemaChange = true
//        #endif
        
        migrator.registerMigration("firstSetup") { db in
            try db.create(table: Profile.databaseTableName) { t in
                t.primaryKey("pubkey", .text, onConflict: .replace)
                t.column("npub", .text).notNull()
                t.column("name", .text).notNull()
                t.column("about", .text).notNull()
                t.column("picture", .text).notNull()
                t.column("nip05", .text).notNull()
                t.column("banner", .text).notNull()
                t.column("displayName", .text).notNull()
                t.column("location", .text).notNull()
                t.column("lud06", .text).notNull()
                t.column("lud16", .text).notNull()
                t.column("website", .text).notNull()
                
                t.column("rawData", .text).notNull()
            }
            
            try db.create(table: ProfileLastVisit.databaseTableName) { t in
                t.column("profilePubkey", .text).notNull()
                t.column("userPubkey", .text).notNull()
                t.column("lastVisit", .date).notNull()
                
                t.primaryKey(["profilePubkey", "userPubkey"], onConflict: .replace)
                t.foreignKey(["profilePubkey"], references: Profile.databaseTableName, onDelete: .cascade)
            }
            
            try db.create(table: ProfileCount.databaseTableName) { t in
                t.primaryKey("profilePubkey", .text, onConflict: .replace)
                t.foreignKey(["profilePubkey"], references: Profile.databaseTableName, onDelete: .cascade)
                
                t.column("follows", .integer)
                t.column("followers", .integer)
                t.column("replies", .integer)
                t.column("notes", .integer)
                t.column("articles", .integer)
                t.column("media", .integer)
                
                t.column("timeJoined", .integer)
            }
            
            try db.create(table: ProfileNip05Check.databaseTableName) { t in
                t.primaryKey("nip05", .text, onConflict: .replace)
                t.column("pubkey", .text).notNull()
                t.column("lastChecked", .date).notNull()
            }
            
            try db.create(table: MediaResource.databaseTableName) { t in
                t.primaryKey("url", .text, onConflict: .replace)
                t.column("variants", .text).notNull()
            }
            
            try db.create(table: Thumbnail.databaseTableName) { t in
                t.primaryKey("url", .text, onConflict: .replace)
                t.column("image", .text).notNull()
            }
            
            try db.create(table: NoteDraft.databaseTableName) { t in
                t.column("replyingTo", .text).notNull()
                t.column("userPubkey", .text).notNull()
                
                t.column("preparedEvent", .text)
                
                t.column("text", .text).notNull()
                t.column("uploadedAssets", .text)
                t.column("taggedUsers", .text)
                
                t.primaryKey(["replyingTo", "userPubkey"], onConflict: .replace)
                t.foreignKey(["userPubkey"], references: Profile.databaseTableName)
            }
        }
        
        // Migrations for future application versions will be inserted here:
        // migrator.registerMigration(...) { db in
        //     ...
        // }
        
        return migrator
    }

}
