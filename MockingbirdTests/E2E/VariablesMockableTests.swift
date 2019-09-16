//
//  VariablesMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/9/19.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Mockable declarations

private protocol MockableVariablesContainer: Mock {
  var readonlyVariableOverwrittenAsReadwrite: Bool { get set }
  var uninitializedVariable: Bool { get set }
  
  var computedVariable: Bool { get }
  var computedMutableVariable: Bool { get set }
  
  var computedVariableWithDidSetObserver: Bool { get set }
  var computedVariableWithWillSetObserver: Bool { get set }
}
extension VariablesContainerMock: MockableVariablesContainer {}
