//
//  FileHelper.swift
//  Vite
//
//  Created by Stone on 2018/9/15.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import UIKit

public class FileHelper: NSObject {

    public enum FileError: Error {
        case pathEmpty
        case createFileFailed
    }

    public enum PathType {
        case documents
        case library
        case tmp
        case caches
        case appGroup(identifier: String)
    }

    public let rootPath: String
    private let fileManager: FileManager = FileManager.default

    public init(_ pathType: PathType = .library, appending pathComponent: String? = nil, createDirectory: Bool = true) {
        var path = ""
        switch pathType {
        case .documents:
            path = FileHelper.documentsPath
        case .library:
            path = FileHelper.libraryPath
        case .tmp:
            path = FileHelper.tmpPath
        case .caches:
            path = FileHelper.cachesPath
        case .appGroup(let identifier):
            path = (FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)?.path)!
        }

        if createDirectory {
            path = (path as NSString).appendingPathComponent(Bundle.main.bundleIdentifier ?? "FileHelper") as String
        }

        if let component = pathComponent, !component.isEmpty {
            path = (path as NSString).appendingPathComponent(component) as String
        }

        rootPath = path
    }

    public func writeData(_ data: Data, relativePath: String) -> Error? {

        if relativePath.isEmpty {
            return FileError.pathEmpty
        }

        let path = (rootPath as NSString).appendingPathComponent(relativePath) as String
        let dirPath = (path as NSString).deletingLastPathComponent as String

        if !fileManager.fileExists(atPath: dirPath) {
            do {
                try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
            } catch let e {
                return e
            }
        }

        if !fileManager.createFile(atPath: path, contents: data, attributes: nil) {
            return FileError.createFileFailed
        }

        return nil
    }

    public func moveFileAtPath(_ srcPath: String, to dstRelativePath: String) -> Error? {
        if srcPath.isEmpty ||
            dstRelativePath.isEmpty {
            return FileError.pathEmpty
        }

        let path = (rootPath as NSString).appendingPathComponent(dstRelativePath) as String
        let dirPath = (path as NSString).deletingLastPathComponent as String

        if !fileManager.fileExists(atPath: dirPath) {
            do {
                try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
            } catch let e {
                return e
            }
        }

        try? fileManager.removeItem(atPath: path)
        do {
            try fileManager.moveItem(atPath: srcPath, toPath: path)
        } catch let e {
            return e
        }

        return nil
    }

    public func deleteFileAtRelativePath(_ path: String) -> Error? {
        let path = (rootPath as NSString).appendingPathComponent(path) as String
        if fileManager.fileExists(atPath: path) {
            do {
                try fileManager.removeItem(atPath: path)
            } catch let e {
                return e
            }
        }
        return nil
    }

    public func contentsAtRelativePath(_ path: String) -> Data? {
        let path = (rootPath as NSString).appendingPathComponent(path) as String
        return fileManager.contents(atPath: path)
    }
}

extension FileHelper {

    public static var documentsPath: String = {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
    }()

    public static var libraryPath: String = {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.libraryDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).last!
    }()

    public static var tmpPath: String = {
        return NSTemporaryDirectory()
    }()

    public static var cachesPath: String = {
        return NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
    }()
}
