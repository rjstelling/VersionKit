//
//  Version.swift
//  VersionKit
//
//  Created by Richard Stelling on 20/01/2016.
//  Copyright © 2016 Richard Stelling. All rights reserved.
//

import Foundation

public struct Version {
    
    internal let frameworkVersion = VersionKitVersionNumber
    
    enum LogicalOperator: String {
        
        case Optimistic         = "~>"
        case GreaterThan        = ">"
        case GreaterThanEqualTo = ">="
        case LessThan           = "<"
        case LessThanEqualTo    = "<="
        case EqualTo            = "=="
        case NotEqualTo         = "!="
    }
    
    var major: UInt8        //max: 255
    var minor: UInt8        //max: 255
    var build: UInt16       //max: 65535
    var iteration: UInt16   //max: 65535
    var atom: UInt16        //max: 65535
    
    public var versionInteger: UInt64 {
        
        let byte7 = (UInt64(major) << 56)
        let byte6 = (UInt64(minor) << 48)
        let doubleByte5_4 = (UInt64(build) << 32)
        let doubleByte3_2 = (UInt64(iteration) << 16)
        let doubleByte1_0 = (UInt64(atom) << 0)
        
        return (byte7 + byte6 + doubleByte5_4 + doubleByte3_2 + doubleByte1_0)
    }
    
    public var versionString: String {
        return "\(major).\(minor).\(build).\(iteration).\(atom)"
    }
    
    internal func maxOptimisticVersion() -> UInt64 {
        
        var versionArray = [UInt64(major), UInt64(minor), UInt64(build), UInt64(iteration), UInt64(atom)]
        let reversed = [UInt64(atom), UInt64(iteration), UInt64(build), UInt64(minor), UInt64(major)]
        var maximums = [UInt64(UInt16.max), UInt64(UInt16.max), UInt64(UInt16.max), UInt64(UInt8.max), UInt64(UInt8.max)]
        var maxOptVers: [UInt64] = [UInt64]()
        var count = 0
        
        for ele in reversed {
            
            if ele != 0 {
                break
            }
            else {
                
                maxOptVers.append(maximums[count])
            }
            
            count += 1
        }
        
        maxOptVers = maxOptVers.reversed()
        versionArray.replaceSubrange((5 - maxOptVers.count)..<versionArray.count, with: maxOptVers)
        
        let byte7           = (versionArray[0] << 56)
        let byte6           = (versionArray[1] << 48)
        let doubleByte5_4   = (versionArray[2] << 32)
        let doubleByte3_2   = (versionArray[3] << 16)
        let doubleByte1_0   = (versionArray[4] << 0)
        
        let maxOptVersion = (byte7 + byte6 + doubleByte5_4 + doubleByte3_2 + doubleByte1_0)
        
        return maxOptVersion
    }
    
    // Create the Version object with current `things` version
    public init?(version: Int) {
        self.init(versionString: String(version))
    }
    
    public init?(versionString: String) {
        
        guard Version.formatValidation(versionString) else {
            return nil
        }
        
        var sections: [String] = ["0", "0", "0", "0", "0"]
        let elements = versionString.characters.split { $0 == "." }.map { String($0) }
        
        sections.replaceSubrange(0..<elements.count, with: elements)
        
        if  let maj = UInt8(String(sections[0])),
            let min = UInt8(String(sections[1])),
            let bld = UInt16(String(sections[2])),
            let itr = UInt16(String(sections[3])),
            let atm = UInt16(String(sections[4])) {

                self.init(major: maj, minor: min, build: bld, iteration: itr, atom: atm)
        }
        else {
            return nil
        }
    }
    
    init(major: UInt8, minor: UInt8, build: UInt16, iteration: UInt16, atom: UInt16) {
        
        self.major = major
        self.minor = minor
        self.build = build
        self.iteration = iteration
        self.atom = atom
        
    }
    
    // Test your version against the actural version
    public func validate(_ versionString: String) -> Bool {
        
        let Nbsp: Character = " "
        let elements = versionString.characters.split { $0 == Nbsp }
        
        var opr: String
        var vers: String
        
        if(elements.count == 2) { opr = String(elements[0]); vers = String(elements[1]) } else { opr = "=="; vers = String(elements[0]) }
        
        if let testVersion: Version = Version(versionString: vers) {
        
            if let pred = LogicalOperator(rawValue: opr) {
                
                return self.validate(pred, version: testVersion)
            }
            else {
                
                return self.validate(.EqualTo, version: testVersion)
            }
        }
        else {
            
            return false
        }
    }
    
    internal func validate(_ operator: LogicalOperator, version: Version) -> Bool {
        
        switch `operator` {
            
        case .Optimistic where (self.versionInteger >= version.versionInteger && self.versionInteger <= version.maxOptimisticVersion()):
            return true
            
        case .GreaterThan where self.versionInteger > version.versionInteger:
            return true
            
        case .GreaterThanEqualTo where self.versionInteger >= version.versionInteger:
            return true
            
        case .LessThan where self.versionInteger < version.versionInteger:
            return true
            
        case .LessThanEqualTo where self.versionInteger <= version.versionInteger:
            return true
            
        case .EqualTo where self.versionInteger == version.versionInteger:
            return true
            
        case .NotEqualTo where self.versionInteger != version.versionInteger:
            return true
            
        default:
            return false
        }
    }
        
    internal static func formatValidation(_ testString: String) -> Bool {
        
        func match(_ regex: String, search: String) -> Bool {
            
            if let regex = try? NSRegularExpression(pattern: regex, options: NSRegularExpression.Options.caseInsensitive), regex.numberOfMatches(in: search, options: [], range: NSMakeRange(0, search.characters.count)) > 0 {
                return true
            }
            else {
                return false
            }
        }
        
        guard match("^([0-9]+\\.){0,4}[0-9]+$", search: testString) else {
            return false
        }
        
        return true
    }
}

// MARK: - CustomDebugStringConvertible
extension Version: CustomDebugStringConvertible {
    
    public var debugDescription: String {
        get {
            return "\(String(describing: type(of: self))) -> \(self.versionString) (\(self.versionInteger))"
        }
    }
    
}
