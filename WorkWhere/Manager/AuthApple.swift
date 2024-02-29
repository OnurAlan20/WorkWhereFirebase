//
//  AuthApple.swift
//  WorkWhere
//
//  Created by Onur Alan on 1.03.2024.
//

import Foundation
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseFirestore



class AuthApple: NSObject, ASAuthorizationControllerPresentationContextProviding{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return Brain.topViewController()!.view.window!
    }
    
    private var currentNonce: String?
    let firebaseAuth = Auth.auth()
    let db = Firestore.firestore()
    static let shared = AuthApple()

   

    
    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

extension AuthApple: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) async throws -> UserModel? {
    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
      guard let nonce = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }
      guard let appleIDToken = appleIDCredential.identityToken else {
        print("Unable to fetch identity token")
        return nil
      }
      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
        return nil
      }
      // Initialize a Firebase credential, including the user's full name.
      let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                        rawNonce: nonce,
                                                        fullName: appleIDCredential.fullName)
      //firebase
        let authDataResult = try await firebaseAuth.signIn(with: credential)
        
        if authDataResult.additionalUserInfo?.isNewUser == true {
            let authdataResultModel = AuthDataResultModel(user: authDataResult.user)
            
            let user = UserModel(id: authdataResultModel.uid, email: authdataResultModel.email, profileImage: authdataResultModel.photoUrl, name: authDataResult.user.displayName, posts: [])
            
            let data: [String: Any] = [
                "id": user.id,
                "email": user.email,
                "profileImage": user.profileImage,
                "name": user.name,
                "posts": user.posts,
            ]
            db.collection("user").addDocument(data: data) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document added successfully")
                }
            }
        }
        
        return try await AuthManager.shared.getUserData()

        
    }
        return nil
        
  }

  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
    // Handle error.
    print("Sign in with Apple errored: \(error)")
  }

}
