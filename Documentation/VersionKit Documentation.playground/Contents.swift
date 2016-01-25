//: VersionKit - A lightweight semantic version checker written in Swift
import UIKit
import VersionKit
import XCPlayground

//: Create a `Version` instance by passing the sematic version string
let versionString = "1.2.3.4.5"
guard let version = Version(versionString: versionString) else {
    
    print("Failed to create Version() object using: \(versionString)")
    XCPlaygroundPage.currentPage.finishExecution()
}

//: Test a `version` with; >, <, ==, >=, <= and ~> operators

if version.validate("< 2.0") {
    "version is less than 2.0"
}

//: The Optimistic operator will match any version upto but not greater-then the specified version

if version.validate("~> 1.2.3") {
    
    "version will match 1.2.3.x.x"
}

if version.validate("~> 1.2.4") {
    
    "Should not run"
}
else {
    
    "version will not match 1.2.4.x.x"
}


