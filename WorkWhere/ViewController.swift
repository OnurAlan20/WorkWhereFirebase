import UIKit
import FirebaseAuth
import FirebaseFirestore


class ViewController: UIViewController {

    @IBOutlet weak var mail: UITextField!
    
    @IBOutlet weak var password: UITextField!
    let firebase = AuthManager.shared
    let postManager = PostManager.shared
    let db = Firestore.firestore()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            
        
        }
    
    @IBAction func mailFunc(_ sender: UITextField) {
    }
    
    @IBAction func passwordFunc(_ sender: UITextField) {
    }
    

    @IBAction func loginButton(_ sender: UIButton) {
        Task { @MainActor in
            try await firebase.signInWithEmail(email: mail.text!, password: password.text!)
            
        }
    }
    @IBAction func registerButton(_ sender: UIButton) {
        firebase.createUserWithEmail(email:mail.text! , password: password.text!)
    }
    
    @IBAction func googleSignIn(_ sender: UIButton) {
        Task { @MainActor in
            print(try await firebase.signWithGoogle())
        }
    }
    
    @IBAction func addPost(_ sender: UIButton) {
        
        postManager.addPost(PlacePosts(id: "postId", userId: "userId", placeTitle: "PlaceTitle", placeDescription: "PlaceDescription", location: LocationModel(latitude: 12, longitute: 13, title: "Aşk Cafe", city: "Ankara", district: "Bahçelievler"), imageURLs: ["img1","img2","img3"]))
         
        }

    
    
}

