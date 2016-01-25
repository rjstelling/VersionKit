# VersionKit

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

A lightweight semantic version checker written in Swift. Supports upto 5 version parts. 

##Usage

    let version = Version(versionString: "1.2.3")
    
    if version.validate("~> 1.2") {
    
        "version will match 1.2.x.y.z"
    }
    
