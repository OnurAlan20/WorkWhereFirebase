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
    var imageURLs: [String] = []
    var imageDownloadURLS: [URL] = []
    
    
    init(id: String, userId: String, placeTitle: String, placeDescription: String, location: LocationModel) {
        self.id = id
        self.userId = userId
        self.placeTitle = placeTitle
        self.placeDescription = placeDescription
        self.location = location
    }
    init(id: String, userId: String, placeTitle: String, placeDescription: String, location: LocationModel,imageURLs: [String]) {
        self.id = id
        self.userId = userId
        self.placeTitle = placeTitle
        self.placeDescription = placeDescription
        self.location = location
    }
}



