//
//  Color.swift
//  aCh01
//
//  Created by user on 2022/3/5.
//

import Foundation
import SwiftUI

extension Color {
    
    static var cusDrakRed : Color {
        get {
            return Color(red: 0.78, green: 0.2, blue: 0.2)
        }
    }
    
    static var cusGray : Color {
        get {
            return Color(red: 0.6, green: 0.6, blue: 0.6)
        }
     }
    static var cusLightGray : Color {
        get {
            return Color(red: 0.9, green: 0.9, blue: 0.9)
        }
     }
    
    static var cusDarkGray2 : Color {
        get {
            return Color(red: 0.3, green: 0.3, blue: 0.3)
        }
     }
    
    static var cusDarkGray : Color {
        get {
            return Color(red: 0.6, green: 0.6, blue: 0.6)
        }
     }
    
    static func cusPurle(cs:ColorScheme) -> Color {
        if cs == .dark {
            return Color(red: 0.7, green: 0.3, blue: 0.9)
        }
        else {
            return Color(red: 0.4, green: 0.2, blue: 0.9)
        }
     }
    
    static var cusGreen : Color {
        get {
            return Color(red: 141/255, green: 175/255, blue: 74/255)
        }
     }
    
    static var cusLightGreen : Color {
        get {
            return Color(red: 117/255, green: 180/255, blue: 126/255)
        }
     }
    static var cusLightBlue : Color {
        get {
            return Color(red: 98/255, green: 151/255, blue: 219/255)
        }
     }
    
    
    
    
}

