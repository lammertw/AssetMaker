//
//  main.swift
//  AssetMaker
//
//  Created by Lammert Westerhoff on 10/03/2020.
//  Copyright © 2020 Lammert Westerhoff. All rights reserved.
//

import ArgumentParser
import Files
import Foundation

struct Maker: ParsableCommand {

    @Argument()
    var file: String

    @Argument()
    var output: String

    mutating func validate() throws {
        let assetCatalog = try Folder(path: output)
        let input = try File(path: file)
        guard assetCatalog.extension == "xcassets" else {
            throw ValidationError("\(output) must be an Asset Catalog of type .xcassets")
        }
        guard input.extension == "pdf" else {
            throw ValidationError("\(file) must be a PDF file")
        }
    }

    func run() throws {
        let assetCatalog = try Folder(path: output)
        let input = try File(path: file)

        let assetFolder = try assetCatalog.createSubfolderIfNeeded(at: "\(input.nameExcludingExtension).imageset")
        try assetFolder.empty()

        let jsonEncoder = JSONEncoder()
        jsonEncoder.outputFormatting = .prettyPrinted
        let contents = try jsonEncoder.encode(Contents(file: input))
        let contentsFile = try assetFolder.createFile(named: "Contents.json")
        try contentsFile.write(contents)

        try input.copy(to: assetFolder)
    }
}

struct Contents: Codable {
    var images: [Image]
    var info = Info()

    struct Image: Codable {
        var idiom = "universal"
        var filename: String
    }

    struct Info: Codable {
        var version = 1
        var author = "AssetMaker"
    }
}

extension Contents {
    init(file: File) {
        self.images = [Image(filename: file.name)]
    }
}

Maker.main()
