//
//  LoginModel.swift
//  XIVE
//
//  Created by 나현흠 on 4/3/24.
///Users/nahyeonheum/Desktop/xive/XIVE/XIVE/UI/home

import Foundation
import AuthenticationServices

class LoginModel {
    var userIdentifier: String?
    var fullName: String?
    var email: String?

    init(userIdentifier: String? = nil, fullName: String? = nil, email: String? = nil) {
        self.userIdentifier = userIdentifier
        self.fullName = fullName
        self.email = email
    }
}
