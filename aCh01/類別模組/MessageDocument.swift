//
//  MessageDocument.swift
//  ImportExport
//
//  Created by Aaron Wright on 8/27/20.
//

import SwiftUI
import UniformTypeIdentifiers



struct MessageDocument: FileDocument {
    
    enum CusCodingType: String, CaseIterable {
        case utf8 = "utf-8格式"
        case big5 = "Big5格式"
    }

    enum DataAction: String, CaseIterable {
        case Import = "匯入"
        case Export = "匯出"
    }

    struct StringCoding {

        static func documentCoding(_ codingType:CusCodingType)-> String.Encoding {
            switch (codingType) {
            case .utf8:
                return .utf8
            case .big5:
                // 轉換作業 CFStringEncodings -> CFStringEncoding -> NSStringEncoding -> String.Encoding
                let cfEnc = CFStringEncodings.big5
                let nsEnc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(cfEnc.rawValue))
                let big5encoding = String.Encoding(rawValue: nsEnc) // String.Encoding
                return big5encoding
            }
        }
    }
    
    static var readableContentTypes: [UTType] { [.plainText] }

    var message: String = ""
    var messageCoding : CusCodingType = .utf8
    
    init(message: String,coding:CusCodingType) {
        self.message = message
        self.messageCoding = coding
    }

    private var documentCoding : String.Encoding {
        get {
            return StringCoding.documentCoding(self.messageCoding)
        }
    }
    
    init(configuration: ReadConfiguration) throws {

        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: self.documentCoding)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        message = string
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: message.data(using: self.documentCoding)!)
    }
    
}
