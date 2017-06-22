//
//  VCard.swift
//  SwiftyVCard
//
//  Created by Ruslan on 29.10.15.
//  Copyright © 2015 GRG. All rights reserved.
//

import Foundation
import AppKit

public enum VCardProperty: String {
    case N
    case PHOTO
    case LOGO
    case TITLE
    case EMAIL
    case ORG
    case URL
    case TEL
    case ADR
    case FACEBOOK = "X-FACEBOOK"
    case SKYPE = "X-SKYPE"
    case INSTAGRAM = "X-INSTAGRAM"
    case LINKEDIN = "X-LINKEDIN"
    case TWITTER = "X-TWITTER"
    case PRODID
}

public class VCard {
    private var scanner: Scanner!
    
    public var firstName = ""
    public var secondName = ""
    public var lastName = ""
    public var photo: NSImage?
    public var logo: NSImage?
    public var eMail = ""
    public var position = ""
    public var company = ""
    public var website = ""
    public var phoneNumber = ""
    public var address = ""
    public var facebook = ""
    public var skype = ""
    public var instagram = ""
    public var linkedIn = ""
    public var twitter = ""
    
    public var vCardRepresentation: String {
        var result =  "BEGIN:VCARD\r\n" +
        "VERSION:4.0\r\n"
        
        if !firstName.isEmpty || !secondName.isEmpty || !lastName.isEmpty {
            result +=   "\(VCardProperty.N.rawValue):\(lastName);\(firstName);\(secondName);\r\n"
        }
        
        if let base64String = toBase64(from: photo) {
            result += "\(VCardProperty.PHOTO.rawValue):data:image/png;base64,\(base64String)"
        }
        if let base64String = toBase64(from: logo) {
            result += "\(VCardProperty.LOGO.rawValue):data:image/png;base64,\(base64String)\r\n"
        }
        
        if !position.isEmpty {
            result += "\(VCardProperty.TITLE.rawValue):\(position)\r\n"
        }
        
        if !company.isEmpty {
            result += "\(VCardProperty.ORG.rawValue):\(company)\r\n"
        }
        
        if !website.isEmpty {
            result += "\(VCardProperty.URL.rawValue):\(website)\r\n"
        }
        
        if !phoneNumber.isEmpty {
            result += "\(VCardProperty.TEL.rawValue):\(phoneNumber)\r\n"
        }
        
        if !address.isEmpty {
            result += "\(VCardProperty.ADR.rawValue):\(address);;;;;\r\n"
        }
        
        if !facebook.isEmpty {
            result += "\(VCardProperty.FACEBOOK.rawValue):\(facebook)\r\n"
        }
        
        if !skype.isEmpty {
            result += "\(VCardProperty.SKYPE.rawValue):\(skype)\r\n"
        }
        
        if !instagram.isEmpty {
            result += "\(VCardProperty.INSTAGRAM.rawValue):\(instagram)\r\n"
        }
        
        if !linkedIn.isEmpty {
            result += "\(VCardProperty.LINKEDIN.rawValue):\(linkedIn)\r\n"
        }
        
        if !twitter.isEmpty {
            result += "\(VCardProperty.TWITTER.rawValue):\(twitter)\r\n"
        }
        
        result += "END:VCARD\r\n"
        
        return result
    }
    
    func toBase64(from image: NSImage?) -> String? {
        guard let image = image,
            let data = image.tiffRepresentation,
            let rep = NSBitmapImageRep(data: data),
            let pngData = rep.representation(using: .png, properties: [:]) else {
                return nil
        }
        let base64String = pngData.base64EncodedString(options: [])
        return base64String
    }
    
    public init() {}
    
    public init(vCardString: String) {
        fillFromVCardString(vCardString)
    }
    
    func fillFromVCardString(_ string: String) {
        let preparedString = string.replacingOccurrences(of: "\r\n ", with: "")
            .replacingOccurrences(of: "\r\n\t", with: "")
            .replacingOccurrences(of: "\n ", with: "")
            .replacingOccurrences(of: "\n\t", with: "")
        
        scanner = Scanner(string: preparedString)
        scanner.charactersToBeSkipped = CharacterSet()
        
        guard scanBegin() else { return }
        guard scanNewLine() else { return }
        guard scanVersion() else { return }
        guard scanNewLine() else { return }
        
        while !scanner.isAtEnd {
            guard let property = scanProperty() else { return }
            guard let value = scanValue() else {
                _ = scanNewLine()
                continue
            }
            
            switch property {
            case .N:
                parseNValue(value)
                
            case .PHOTO:
                parsePhotoValue(value)
                
            case .TITLE:
                parseTitleValue(value)
                
            case .EMAIL:
                parseEmailValue(value)
                
            case .ORG:
                parseOrgValue(value)
                
            case .URL:
                parseUrlValue(value)
                
            case .TEL:
                parseTelValue(value)
                
            case .ADR:
                parseAdrValue(value)
                
            case .FACEBOOK:
                parseFacebookValue(value)
                
            case .SKYPE:
                parseSkypeValue(value)
                
            case .INSTAGRAM:
                parseInstagramValue(value)
                
            case .LINKEDIN:
                parseLinkedInValue(value)
                
            case .TWITTER:
                parseTwitterValue(value)
                
            case .LOGO:
                parseLogoValue(value)
                
            default:
                break
            }
            
            _ = scanNewLine()
        }
    }
    
    private func scanNewLine() -> Bool {
        return scanner.scanCharacters(from: CharacterSet.newlines, into: nil)
    }
    
    private func scanBegin() -> Bool {
        return scanner.scanString("BEGIN:VCARD", into: nil)
    }
    
    private func scanVersion() -> Bool {
        return scanner.scanString("VERSION:4.0", into: nil)
    }
    
    private func scanProperty() -> VCardProperty? {
        var propertyName: NSString?
        scanner.scanUpTo(":", into: &propertyName)
        scanner.scanString(":", into: nil)
        if let thePropertyName = propertyName as String? {
            let property = VCardProperty(rawValue: thePropertyName)
            return property
        }
        return nil
    }
    
    private func scanValue() -> String? {
        var value: NSString?
        scanner.scanUpToCharacters(from: CharacterSet.newlines, into: &value)
        
        return value as String?
    }
    
    private func parseNValue(_ value: String) {
        let namesArray = value.components(separatedBy: ";")
        (lastName, firstName, secondName) = (namesArray[0], namesArray[1], namesArray[2])
    }
    
    private func parsePhotoValue(_ value: String) {
        photo = imageFromValue(value)
    }
    
    private func parseLogoValue(_ value: String) {
        logo = imageFromValue(value)
    }
    
    private func imageFromValue(_ value: String) -> NSImage? {
        let regPattern = "data:image/(jpg|jpeg|png);base64,(.*)"
        do {
            let regExp = try NSRegularExpression(pattern: regPattern, options: [])
            if let result = regExp.firstMatch(in: value,
                                              options: [],
                                              range: NSMakeRange(0, value.characters.count)) {
//                let fileExtension = (value as NSString).substring(with: result.rangeAt(1))
                let base64Image = (value as NSString).substring(with: result.rangeAt(2))
                
                if let imageData = Data(base64Encoded: base64Image, options: []) {
                    return NSImage(data: imageData)
                }
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    private func parseEmailValue(_ value: String) {
        eMail = value
    }
    
    private func parseTitleValue(_ value: String) {
        position = value
    }
    
    private func parseOrgValue(_ value: String) {
        company = value
    }
    
    private func parseUrlValue(_ value: String) {
        website = value
    }
    
    private func parseTelValue(_ value: String) {
        phoneNumber = value
    }
    
    private func parseAdrValue(_ value: String) {
        address = value.components(separatedBy: ";").filter{!$0.isEmpty}.joined(separator: ", ")
    }
    
    private func parseFacebookValue(_ value: String) {
        facebook = value
    }
    
    private func parseSkypeValue(_ value: String) {
        skype = value
    }
    
    private func parseInstagramValue(_ value: String) {
        instagram = value
    }
    
    private func parseLinkedInValue(_ value: String) {
        linkedIn = value
    }
    
    private func parseTwitterValue(_ value: String) {
        twitter = value
    }
    
    private func scanEnd() -> Bool {
        return scanner.scanString("END:VCARD", into: nil)
    }
    
}

extension VCard: CustomStringConvertible {
    public var description: String {
        let result =  "firstName: \(firstName)\n" +
            "secondName: \(secondName)\n" +
            "lastName: \(lastName)\n" +
            "position: \(position)\n" +
            "company: \(company)\n" +
            "website: \(website)\n" +
            "address: \(address)\n" +
            "facebook: \(facebook)\n" +
            "skype: \(skype)\n" +
            "instagram: \(instagram)\n" +
            "linkedIn: \(linkedIn)\n" +
        "twitter: \(twitter)"
        return result
    }
}
