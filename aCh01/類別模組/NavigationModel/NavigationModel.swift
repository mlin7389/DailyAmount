//
//  NavigationModel.swift
//  aCh01
//
//  Created by user on 2022/9/10.
//

import Foundation

class NavModelForSub : ObservableObject {
    
    struct NavPath : Hashable {
        var id = UUID()
        var subItem : Subscription
        var viewType : DestType
  
        init(subItem s:Subscription,viewType v:DestType) {
            subItem = s
            viewType = v
        }
    }
    
    enum DestType {
        case AddandModeify
        case ShowDetail
        case NamePicker
        case GroupPicker
        case CycleNamePicker
        case AvgPicker
    }
    
   @Published var path : [NavPath]
    
    init() {
        path = [NavPath]()
    }
    
    func newPath(subItem s:Subscription,viewType v:DestType) ->  NavPath {
        return NavPath(subItem: s, viewType: v)
    }
  
    func appendPath(subItem s:Subscription,viewType v:DestType)  {
        self.path.append(NavPath(subItem: s, viewType: v))
    }
}
