//
//  SideMenuModel.swift
//  Hykerr
//
//  Created by Corey Edh on 8/9/22.
//

import Foundation
import SwiftUI


enum SideMenuContentModel: Int, CaseIterable{
    case triphistory
    case settings
    
    var title: String{
        switch self{
        case .triphistory: return "Trip History"
        case .settings: return "Settings"
        }
    }
    
    var symbol: String{
        switch self{
        case .triphistory: return "clock.arrow.circlepath"
        case .settings: return "gear"
        }
    }

    
}
