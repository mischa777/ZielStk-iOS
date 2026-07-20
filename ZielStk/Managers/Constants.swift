//
//  Constants.swift
//  ZielStk
//
//  Created by Roman Voinitchi on 9/9/19.
//  Copyright © 2019 Roman Voinitchi. All rights reserved.
//

import Foundation

struct Constants {
    
    struct Timers {
        static let CommonAnimationSeconds = 0.23
        static let AppearenceSeconds = 3.0
    }
    
    struct Values {
        static let MinPassCount = 6
        static let StringSeparator = ", "
        static let MinSymbolsForTest = 200
        static let KeyPostedString = "keyPostedString"
        static let PermissionsTextError = "Code=7"
        static let InProgressRestriction = "entwicklung"
    }
    
    struct Cells {
        static let CourseCellHeight = 70
        static let CourseCellSubHeight = 60
        static let StudienCollegsCellHeight = 130
        static let StudienCollegsInfoViewHeight = 50
        static let ShopHeaderHeight = 50
        static let ShopMainHeight = 40
    }
    
    struct Segues {
        static let ChooseCourses = "showChooseCourses"
        static let Register = "showRegister"
        static let Studienkolleg = "showStudienkolleg"
        static let CollegsTest = "showCollegsTest"
        static let SubCollegsTest = "showSubTest"
        static let AddTranlation = "showAddTranlation"
        static let ShowLogin = "showLoginSegue"
        static let SecondShop = "showSecondShopSegue"
        static let ShopFromTests = "segueShopFromTests"
        static let MathTest = "showMathTestSegue"
        static let BigImageSegue = "showBigImageSegue"
        static let DeutchCompiler = "showDeutchCompiler"
        static let DeutchTester = "showDeutchTester"
        static let TextEdit = "showTextEditSegue"
        static let CTestFromBase = "showCTestFromBase"
        static let WebViewSegue = "showWebViewSegue"
        static let PasswordWindowSegue = "ShowPasswordWindow"
        static let TextSelectorSegue = "showTextSelectorSeque"
    }
    
    struct FirebaseTables {
        static let Translations = "Woerterbuch"
        static let Prices = "Prices"
        static let Config = "config"
        static let ConfigVersions = "Versions"
        static let Users = "Users"
        static let Stk = "Stk"
        static let Deutch = "Deutsch"
        static let Purchases = "Purchases"
        static let Struct = "Struktur"
        static let CTest = "C-Test"
        static let Tasks = "Tasks"
    }
}
