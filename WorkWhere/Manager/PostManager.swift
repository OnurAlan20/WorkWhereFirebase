//
//  Posts.swift
//  WorkWhere
//
//  Created by Onur Alan on 27.02.2024.
//

import Foundation
import FirebaseFirestore



class PostManager {

    // Reference to Firestore
    let db = Firestore.firestore()
    static let shared = PostManager()

    
    func addPost(_ placePost:PlacePosts){
        let locationData: [String: Any] = [
                "id": placePost.location.id ,
                "latitude": placePost.location.latitude,
                "longitude": placePost.location.longitute,
                "title": placePost.location.title,
                "city": placePost.location.city,
                "district": placePost.location.district
            ]

            let data: [String: Any] = [
                "id": placePost.id,
                "imageUrls": placePost.imageURLs,
                "placeDescription": placePost.placeDescription,
                "location": locationData,
                "placeTitle": placePost.placeTitle,
                "userId": placePost.userId
            ]
            
            db.collection("post").addDocument(data: data) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document added successfully")
                }
            }
    }
}
