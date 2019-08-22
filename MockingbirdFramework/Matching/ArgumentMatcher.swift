//
//  ArgumentMatcher.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Matchers use equality for objects conforming to `Equatable` and fall back to comparison by
/// reference. For custom objects that are not equatable, provide a custom `comparator` that should
/// return `true` if `base` (lhs) is equal to the other `base` (rhs).
public class ArgumentMatcher: CustomStringConvertible {
  /// Necessary for custom comparators such as `any()` that only work on the lhs.
  public enum Priority: UInt {
    case low = 0, `default` = 500, high = 1000
  }

  /// A base instance to compare using `comparator`.
  let base: Any?
  
  /// The original type of the base instance.
  let baseType: Any?

  /// A description for test failure output.
  public let description: String

  /// The commutativity of the matcher comparator.
  let priority: Priority

  /// The method to compare base instances, returning `true` if they should be considered the same.
  let comparator: (_ lhs: Any?, _ rhs: Any?) -> Bool

  func compare(with rhs: Any?) -> Bool {
    return comparator(base, rhs)
  }

  public init<T: Equatable>(_ base: T?,
                            description: String? = nil,
                            priority: Priority = .default) {
    self.base = base
    self.baseType = T.self
    self.description = description ?? "\(String.describe(base))"
    self.priority = priority
    self.comparator = { base == $1 as? T }
  }

  public init(_ base: Any?,
              description: String,
              priority: Priority = .default,
              _ comparator: @escaping @autoclosure () -> Bool) {
    self.base = base
    self.baseType = type(of: base)
    self.description = description
    self.priority = priority
    self.comparator = { _, _ in comparator() }
  }

  public init(_ base: Any?,
              description: String? = nil,
              priority: Priority = .low,
              _ comparator: ((Any?, Any?) -> Bool)? = nil) {
    self.base = base
    self.baseType = type(of: base)
    self.priority = priority
    self.comparator = comparator ?? { $0 as AnyObject === $1 as AnyObject }
    let annotation = comparator == nil && base != nil ? " (by reference)" : ""
    self.description = description ?? "\(String.describe(base))\(annotation)"
  }
  
  public init(_ matcher: ArgumentMatcher) {
    self.base = matcher.base
    self.baseType = type(of: matcher.base)
    self.priority = matcher.priority
    self.comparator = matcher.comparator
    self.description = matcher.description
  }
}

extension ArgumentMatcher: Equatable {
  public static func == (lhs: ArgumentMatcher, rhs: ArgumentMatcher) -> Bool {
    if lhs.priority.rawValue >= rhs.priority.rawValue {
      return lhs.compare(with: rhs.base)
    } else {
      return rhs.compare(with: lhs.base)
    }
  }
}