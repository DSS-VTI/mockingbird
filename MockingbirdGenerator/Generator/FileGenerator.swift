//
//  FileGenerator.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/5/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

// swiftlint:disable leading_whitespace

import Foundation
import PathKit

class FileGenerator {
  let mockableTypes: [MockableType]
  let moduleName: String
  let imports: Set<String>
  let outputPath: Path
  let shouldImportModule: Bool
  let preprocessorExpression: String?
  let onlyMockProtocols: Bool
  let disableSwiftlint: Bool
  
  init(_ mockableTypes: [MockableType],
       moduleName: String,
       imports: Set<String>,
       outputPath: Path,
       preprocessorExpression: String?,
       shouldImportModule: Bool,
       onlyMockProtocols: Bool,
       disableSwiftlint: Bool) {
    self.mockableTypes = onlyMockProtocols ?
      mockableTypes.filter({ $0.kind == .protocol }) :
      mockableTypes
    self.moduleName = moduleName
    self.imports = imports
    self.outputPath = outputPath
    self.preprocessorExpression = preprocessorExpression
    self.shouldImportModule = shouldImportModule
    self.onlyMockProtocols = onlyMockProtocols
    self.disableSwiftlint = disableSwiftlint
  }
  
  var formattedDate: String {
    let date = Date()
    let format = DateFormatter()
    format.dateStyle = .short
    format.timeStyle = .none
    return format.string(from: date)
  }
  
  var outputFilename: String {
    return outputPath.components.last ?? "MockingbirdMocks.generated.swift"
  }
  
  private func generateFileHeader() -> String {
    let swiftlintDirective = disableSwiftlint ? "\n// swiftlint:disable all\n": ""
    
    let preprocessorDirective: String
    if let expression = preprocessorExpression {
      preprocessorDirective = "\n#if \(expression)\n"
    } else {
      preprocessorDirective = ""
    }
    
    let moduleImports = (
      imports.union(["import Foundation", "@testable import Mockingbird"]).union(
        shouldImportModule ? ["@testable import \(moduleName)"] : []
      )
    ).sorted()
    
    return """
    //
    //  \(outputFilename)
    //  \(moduleName)
    //
    //  Generated by Mockingbird v\(mockingbirdVersion.shortString) on \(formattedDate).
    //  DO NOT EDIT
    //
    \(swiftlintDirective)\(preprocessorDirective)
    \(moduleImports.joined(separator: "\n"))
    
    """
  }
  
  private func generateFileBody() -> String {
    guard !mockableTypes.isEmpty else { return "" }
    let operations = mockableTypes
      .sorted(by: <)
      .map({ GenerateMockableTypeOperation(mockableType: $0, moduleName: moduleName) })
    let queue = OperationQueue.createForActiveProcessors()
    queue.addOperations(operations, waitUntilFinished: true)
    return (
      [synchronizedClass, genericTypesStaticMocks]
        + operations.map({ $0.result.generatedContents })
    ).joined(separator: "\n\n")
  }
  
  private func generateFileFooter() -> String {
    return (preprocessorExpression != nil ? "\n#endif\n" : "\n")
  }
  
  private func generateFileContents() -> String {
    let sections = [
      generateFileHeader(),
      generateFileBody(),
      generateFileFooter(),
    ].filter({ !$0.isEmpty })
    return sections.joined(separator: "\n")
  }
  
  func generate() throws {
    try outputPath.write(generateFileContents(), encoding: .utf8)
  }
  
  private var synchronizedClass: String {
    return """
    private class Synchronized<T> {
      private var internalValue: T
      fileprivate var value: T {
        get {
          lock.wait()
          defer { lock.signal() }
          return internalValue
        }
    
        set {
          lock.wait()
          defer { lock.signal() }
          internalValue = newValue
        }
      }
      private let lock = DispatchSemaphore(value: 1)
    
      fileprivate init(_ value: T) {
        self.internalValue = value
      }
    
      fileprivate func update(_ block: (inout T) throws -> Void) rethrows {
        lock.wait()
        defer { lock.signal() }
        try block(&internalValue)
      }
    }
    """
  }
  
  private var genericTypesStaticMocks: String {
    return "private var genericTypesStaticMocks = Synchronized<[String: Mockingbird.StaticMock]>([:])"
  }
}