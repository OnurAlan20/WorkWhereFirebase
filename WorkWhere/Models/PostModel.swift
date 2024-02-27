//
//  PostModel.swift
//  WorkWhere
//
//  Created by Onur Alan on 26.02.2024.
//

import Foundation

struct PlacePosts: Identifiable {
    let id: String
    let userId: String
    let placeTitle: String
    let placeDescription: String
    let location: LocationModel
    let imageURLs: [String]
    
    init(id: String, userId: String, placeTitle: String, placeDescription: String, location: LocationModel, imageURLs: [String]) {
        self.id = id
        self.userId = userId
        self.placeTitle = placeTitle
        self.placeDescription = placeDescription
        self.location = location
        self.imageURLs = imageURLs
    }
}



