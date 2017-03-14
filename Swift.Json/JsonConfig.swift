//
//  JsonConfig.swift
//  Pods
//
//  Created by Anderson Lucas C. Ramos on 09/03/17.
//
//

import Foundation

/// JsonConvertBlock is the block to convert values from object to json and json to object.
public typealias JsonConvertBlock = ((_ object: AnyObject, _ andKey: String) -> AnyObject?)

/// JsonConfig class for setting custom conversion fields or data types.
public class JsonConfig {
	internal var fieldManualParsing: [String: JsonConvertBlock] = Dictionary()
	internal var dataTypeManualParsing: [String: JsonConvertBlock] = Dictionary()
	
	public init() {
		
	}
	
	/// Sets the conversion block for a given field name.
	///
	/// - Parameters:
	///   - field: the field name String
	///   - block: the conversion block
	public func set(forField field: String, withConversionBlock block: @escaping JsonConvertBlock) {
		self.fieldManualParsing[field] = block
	}
	
	/// Sets the conversion block for a given data type name.
	///
	/// - Parameters:
	///   - type: the type name, ex: "Date"
	///   - block: the conversion block
	public func set(forDataType type: String, withConversionBlock block: @escaping JsonConvertBlock) {
		self.dataTypeManualParsing[type] = block
	}
}
