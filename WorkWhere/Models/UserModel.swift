//
//  UserModel.swift
//  WorkWhere
//
//  Created by Onur Alan on 26.02.2024.
//

import Foundation
struct UserModel: Identifiable {
    
    let id: String
    let email: String?
    let profileImage: String?
    let name: String?
    let posts: [String]
    
    init(id: String, email: String?, profileImage: String?, name: String?, posts: [String]) {
        self.id = id
        self.email = email
        self.profileImage = profileImage
        self.name = name
        self.posts = posts
    }
}
