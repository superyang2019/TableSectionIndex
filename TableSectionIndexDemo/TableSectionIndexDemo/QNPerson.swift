//
//  QNPerson.swift
//  TableSectionIndexDemo
//
//  Created by superyang on 2021/2/16.
//

import UIKit
class QNPerson:NSObject {
    let fullName:String
    let firstCharacter:String
    init(dic:Dictionary<String, String>) {
        self.fullName = dic["FirstNameLastName"] ?? "Some body"
        self.firstCharacter = String(self.fullName.prefix(1))
        super.init()
    }
    
}
