//
//  Posts.swift
//  WorkWhere
//
//  Created by Onur Alan on 27.02.2024.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage


class PostManager {
    
    static let shared = PostManager()
    // Reference to Firestore
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    
    func deletePostById(id:String){
        db.collection("post").whereField("id", isEqualTo: id).getDocuments { snapshot, error in
            if let a = error{
                print(a.localizedDescription)
            }else{
                snapshot?.documents.first?.reference.delete()
            }
        }
    }
    
    func addPost(_ placePost:PlacePosts,data: [Data]){
        var UUIDArr: [String] = []
        
        for image in data{
            let UUID = UUID().uuidString
            let path = "images/\(UUID).jpg"
            UUIDArr.append(path)
            let fileRef = storageRef.child(path)
            
            let uploadTask = fileRef.putData(image, metadata: nil) { metaData, error in
                
            }
        }
        
        
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
                "imageUrls": UUIDArr,
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
        db.collection("user").whereField("id", isEqualTo: placePost.userId).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                let doc = querySnapshot!.documents.first!
                
                self.db.collection("user").document(doc.documentID).updateData(["propertyName": "newValue"]) { error in
                    if let error = error {
                        print("Error updating document \(doc.documentID): \(error)")
                    } else {
                        print("Document \(doc.documentID) successfully updated")
                    }
                }
                    
                
            }
        }
    }
    
    func getAllPosts(completion: @escaping ([PlacePosts]?, Error?) -> Void) {
        var postArr: [PlacePosts] = []
        
        db.collection("post").getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let snapshot = snapshot else {
                completion(nil, nil)
                return
            }
            
            for doc in snapshot.documents {
                let locationData = doc["location"] as! [String: Any]
                var post = PlacePosts(
                    id: doc["id"] as! String,
                    userId: doc["userId"] as! String,
                    placeTitle: doc["placeTitle"] as! String,
                    placeDescription: doc["placeDescription"] as! String,
                    location: LocationModel(
                        latitude: locationData["latitude"] as! Double,
                        longitute: locationData["longitude"] as! Double,
                        title: locationData["title"] as! String,
                        city: locationData["city"] as! String,
                        district: locationData["district"] as! String,
                        id: locationData["id"] as! String
                    ),
                    imageURLs: doc["imageUrls"] as! [String]
                )
                for imagepath in post.imageURLs {
                    
                    let imagePath = imagepath

                    let imageRef = self.storageRef.child(imagePath)

                    imageRef.downloadURL { url, error in
                        if let error = error {
                            print("Hata oluştu: \(error.localizedDescription)")
                        } else {
                            if let downloadURL = url {
                                post.imageDownloadURLS.append(url!)
                               
                            } else {
                                print("Resmin URL'si alınamadı")
                            }
                        }
                    }
                }
                postArr.append(post)
            }
            
            completion(postArr, nil)
        }
    }    
    
    func getPostById(wantedID: String, completion: @escaping (PlacePosts?, Error?) -> Void) {
        db.collection("post").whereField("id", isEqualTo: wantedID).getDocuments { (snapshot, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let snapshot = snapshot, !snapshot.isEmpty else {
                completion(nil, nil)
                return
            }
            
            let doc = snapshot.documents[0]
            let locationData = doc["location"] as! [String: Any]
            var post = PlacePosts(
                id: doc["id"] as! String,
                userId: doc["userId"] as! String,
                placeTitle: doc["placeTitle"] as! String,
                placeDescription: doc["placeDescription"] as! String,
                location: LocationModel(
                    latitude: locationData["latitude"] as! Double,
                    longitute: locationData["longitude"] as! Double,
                    title: locationData["title"] as! String,
                    city: locationData["city"] as! String,
                    district: locationData["district"] as! String,
                    id: locationData["id"] as! String
                ),
                imageURLs: doc["imageUrls"] as! [String]
            )
            
            var remainingImageCount = post.imageURLs.count
            
            for imagePath in post.imageURLs {
                let imageRef = self.storageRef.child(imagePath)
                imageRef.downloadURL { url, error in
                    remainingImageCount -= 1
                    
                    if let error = error {
                        print("Hata oluştu: \(error.localizedDescription)")
                    } else if let downloadURL = url {
                        post.imageDownloadURLS.append(downloadURL)
                    }
                    

                    if remainingImageCount == 0 {
                        completion(post, nil)
                    }
                }
            }
        }
    }

}
