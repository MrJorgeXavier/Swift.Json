//
//  JSONParser.swift
//  Pods
//
//  Created by Anderson Lucas C. Ramos on 08/03/17.
//
//

import Foundation

/// JsonParser class for parsing json strings into structured objects. 
public class JsonParser {
	fileprivate let commons: JsonCommon = JsonCommon()
	
	public init() {
		
	}
	
	/// Parses a string to the expected generic type populating an object instance mapped to the json string.
	///
	/// - Parameters:
	///   - string: the json string
	///   - config: optional parameter with custom parsing configs
	/// - Returns: The object populated with the values from the json string.
	public func parse<T: NSObject>(string: String, withConfig config: JsonConfig? = nil) -> T? {
		guard let data = string.data(using: .utf8) else { return nil }
		var instance: T = (getInstance() as T)
        self.parse(data: data, into: &instance, withConfig: config)
        return instance
	}
    
    /// Parses a Data to the expected generic type populating an object instance mapped to the json Data.
    ///
    /// - Parameters:
    ///   - data: the json Data
    ///   - config: optional parameter with custom parsing configs
    /// - Returns: The object populated with the values from the json Data.
    public func parse<T : NSObject>(data: Data, withConfig config: JsonConfig? = nil) -> T? {
        var instance: T = (getInstance() as T)
        self.parse(data: data, into: &instance, withConfig: config)
        return instance
    }
    
    /// Parses a string to the expected generic type populating an object instance mapped to the json string.
    ///
    /// - Parameters:
    ///   - string: the json string
    ///   - config: optional parameter with custom parsing configs
    /// - Returns: The object populated with the values from the json string.
    public func parse<T: NSObject>(string: String, into object: inout T, withConfig config: JsonConfig? = nil) {
        guard let data = string.data(using: .utf8) else { return }
        self.parse(data: data, into: &object, withConfig: config)
    }
    
    /// Parses a Data to the expected generic type populating an object instance mapped to the json Data.
    ///
    /// - Parameters:
    ///   - data: the json Data
    ///   - config: optional parameter with custom parsing configs
    /// - Returns: The object populated with the values from the json Data.
    public func parse<T: NSObject>(data: Data, into object: inout T, withConfig config: JsonConfig? = nil) {
        guard let jsonObject = self.getJsonDict(data) else { return }
        self.setupCommons()
        self.commons.populate(instance: object, withObject: jsonObject as AnyObject, withConfig: config)
        self.unsetupCommons()
    }
    
    fileprivate func getJsonDict(_ data: Data) -> [String: AnyObject]? {
        let options = JSONSerialization.ReadingOptions(rawValue: 0)
        var jsonObject: [String: AnyObject]?
        do {
            jsonObject = try JSONSerialization.jsonObject(with: data, options: options) as? [String: AnyObject]
        } catch let error as NSError {
            print("JsonParser error: \(error)")
            return nil
        } catch {
            print("JsonParser error: something went wrong with the json parsing, check the json contents")
            return nil
        }
        return jsonObject
    }
	
	fileprivate func setupCommons() {
		self.commons.valueBlock = { (instance, value, key) -> AnyObject? in
			guard let dict = value as? [String: AnyObject] else { return nil }
			return dict[key] as AnyObject
		}
		
		self.commons.primitiveValueBlock = { (instance, value, key) -> Void in
			instance.setValue(value, forKey: key)
		}
		
		self.commons.manualValueBlock = { (instance, value, key) -> Void in
			instance.setValue(value, forKey: key)
		}
		
		self.commons.objectValueBlock = { [weak self] (instance, typeInfo, value, key) -> Void in
			self?.populateObject(forKey: key, intoInstance: instance, withTypeInfo: typeInfo, withObject: value as AnyObject)
		}
		
		self.commons.arrayValueBlock = { [weak self] (instance, typeInfo, value, key) -> Void in
			self?.populateArray(forKey: key, intoInstance: instance, withTypeInfo: typeInfo, withJsonArray: value as! [AnyObject])
		}
	}
	
	fileprivate func unsetupCommons() {
		commons.primitiveValueBlock = nil
		commons.manualValueBlock = nil
		commons.objectValueBlock = nil
		commons.arrayValueBlock = nil
	}
	
	fileprivate func getInstance<T : NSObject>() -> T {
		return T()
	}
	
	fileprivate func getInstance(forType type: NSObject.Type) -> AnyObject {
		return type.init()
	}
	
	fileprivate func populateArray(forKey key: String, intoInstance instance: AnyObject, withTypeInfo typeInfo: TypeInfo, withJsonArray jsonArray: [AnyObject]) {
		var array = [AnyObject]()
		for item in jsonArray {
			if commons.isPrimitiveType(typeInfo.typeName) {
				array.append(item)
			} else {
				let cls: AnyClass? = NSClassFromString(typeInfo.typeName)
				assert(cls != nil, "Could not convert class name \(typeInfo.typeName) to AnyClass instance. Please add @objc(\(typeInfo.typeName)) to your class definition.")
				let inst: AnyObject = self.getInstance(forType: cls as! NSObject.Type)
				commons.populate(instance: inst, withObject: item)
				array.append(inst)
			}
		}
		instance.setValue(array, forKey: key)
	}
	
	fileprivate func populateObject(forKey key: String, intoInstance instance: AnyObject, withTypeInfo typeInfo: TypeInfo, withObject object: AnyObject) {
		let propertyInstance = self.getInstance(forType: typeInfo.type as! NSObject.Type)
		commons.populate(instance: propertyInstance, withObject: object)
		instance.setValue(propertyInstance, forKey: key)
	}
}
