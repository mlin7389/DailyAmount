//
//  NavigationModel.swift
//  aCh01
//
//  Created by user on 2022/9/18.
//

import Foundation

enum NavigationPathView {
    case ExpenseItemsReplaceView
    case ExpenseAmountCountSettingView
    case ExpenseNamePickerView 
}

class NavigationModel : ObservableObject {
    
    init() {
        navPath = [NavigationPathView]()
    }
    
    @Published var navPath : [NavigationPathView] {
        didSet {
            backRootViewFlg = true
        }
    }

    var backRootViewFlg = false
    var focusedText = false
    var focusedAmount = false
    var pushingViewBack = false
}
