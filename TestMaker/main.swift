//
//  main.swift
//  TestMaker
//
//  Created by Shane Whitehead on 22/6/17.
//  Copyright © 2017 Shane Whitehead. All rights reserved.
//

import Foundation
import Cocoa

let fileManager = FileManager.default
let currentDirectory = fileManager.currentDirectoryPath
let urlPath = URL(fileURLWithPath: currentDirectory)

for index in 1..<CommandLine.arguments.count {
    let argument = CommandLine.arguments[index]
    let file = urlPath.appendingPathComponent(argument)
    print("Read \(file)")
    let contents = try String(contentsOf: file, encoding: .utf8)
    let lines = contents.split(separator: "\n")
    var cards: [String] = []
    for line in lines {
        var vCard = VCard()
        let nameParts = line.split(separator: " ")
        vCard.firstName = String(nameParts[0])
        if nameParts.count > 2 {
            let subParts = nameParts[1...nameParts.count - 2]
            vCard.secondName = String(subParts.joined(separator: " "))
        }
        vCard.lastName = String(nameParts.last!)
        vCard.address = "Address"
        vCard.company = "Company"
        vCard.eMail = "email"
        vCard.phoneNumber = "123456789"
        cards.append(vCard.vCardRepresentation)
    }
    guard let output = String(cards.joined(separator: "\r\n")) else {
        continue
    }
    let ext = NSString(string: argument).pathExtension
    let name = "Translation" //NSString(string: argument).deletingPathExtension
    let outputFile = "\(name).\(ext)"
    let outputPath = urlPath.appendingPathComponent(outputFile)
    do {
        print(outputPath)
        try output.write(to: outputPath, atomically: true, encoding: .utf8)
    } catch let error {
        print(error)
    }
}

//for argument in CommandLine.arguments {
//}

