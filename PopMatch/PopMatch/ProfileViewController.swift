import UIKit
import Photos
import Firebase
import FirebaseStorage
import FirebaseUI
import FBSDKLoginKit


class ProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // Main buttons on Profile VC
    @IBOutlet weak var settingBtn: UIButton!
    @IBOutlet weak var signoutBtn: UIButton!
    @IBOutlet weak var lobbyBtn: UIButton!
    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var resetBtn: UIButton!
    
    // TextFields
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    var TFFields: [UITextField] = []
   
    // Social Media Buttons
    @IBOutlet weak var twitterBtn: UIButton!
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var snapchatBtn: UIButton!
    @IBOutlet weak var instagramBtn: UIButton!
    @IBOutlet weak var linkedinBtn: UIButton!
    var buttons: [UIButton] = []
    
    // Pop Up View
    @IBOutlet weak var popUpView: UIView!
    @IBOutlet weak var closeViewBtn: UIButton!
    @IBOutlet weak var popUpLabel: UILabel!
    @IBOutlet weak var popUpTextField: UITextField!
    @IBOutlet weak var popUpErrLabel: UILabel!
    @IBOutlet weak var popUpConfirmBtn: UIButton!
    @IBOutlet weak var promptLabel: UILabel!
    
    // Social Media links
    var twitterLink: String = ""
    var facebookLink: String = ""
    var snapchatLink: String = ""
    var instagramLink: String = ""
    var linkedinLink: String = ""
    
    var links: [String] = []
    
    var imageURL: URL?
    var imageText: String = ""
   
    var db = Firestore.firestore()
    var storage = Storage.storage()
    
    var imagePickerController = UIImagePickerController()
    let placeholderImage = UIImage(systemName: "person")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleSetUp()
        
        // Set Arrays & Delegates
        self.TFFields = [usernameTextField, firstnameTextField, lastnameTextField, emailTextField, popUpTextField]
        self.links = [twitterLink, facebookLink, snapchatLink, instagramLink, snapchatLink]
        self.buttons = [twitterBtn, facebookBtn, snapchatBtn, instagramBtn, linkedinBtn, signoutBtn, resetBtn, settingBtn, popUpConfirmBtn, closeViewBtn, profileBtn, lobbyBtn]
        self.TFFields = self.TFFields.map({$0.delegate = self; return $0})
        self.imagePickerController.delegate = self
        
        // Hide pop until button press
        popUpView.isHidden = true
        popUpConfirmBtn.isHidden = true
        popUpErrLabel.isHidden = true
        
        //set up prompt for username
        promptLabel.text = "Please enter your username"
        promptLabel.textColor = .orange
        
        // Display the stored data
        displayUserData()
        
        buildPresence()
        cleanPrevious()
    }
    func cleanPrevious(){
        
        let uid = Auth.auth().currentUser?.uid ?? ""
        let db = FirebaseFirestore.Firestore.firestore()
        if uid != "" {
        /*Delete fields of current match for myself*/
        db.collection("users").document(uid).collection("matches").document("current match").delete()
        db.collection("users").document(uid).collection("matches").document("previous matches").delete()
        /* set is on call to false*/
        db.collection("users").document(uid).getDocument{(document, error) in
            if let document = document, document.exists {
                document.reference.updateData([
                    "isOnCall": "false"
                ])
            }
        }
        }
    }
    // MARK: - Styling
    func styleSetUp() {
        // Making the buttons & popup stuff round
        signoutBtn.layer.cornerRadius = 15
        popUpView.layer.cornerRadius = 15
        popUpView.layer.borderWidth = 1.5
        popUpView.layer.borderColor = UIColor.systemOrange.cgColor
        popUpConfirmBtn.layer.borderWidth = 1
        popUpConfirmBtn.layer.borderColor = UIColor.systemOrange.cgColor
        popUpConfirmBtn.layer.cornerRadius = 15
        profileImage.layer.cornerRadius = 0.5 * profileImage.layer.bounds.size.width
        profileImage.layer.borderWidth = 8.0
        profileImage.layer.borderColor = UIColor(displayP3Red: 0.91, green: 0.87, blue: 1.0, alpha: 1.0).cgColor
        bottomBorder(usernameTextField)
        bottomBorder(firstnameTextField)
        bottomBorder(lastnameTextField)
        bottomBorder(emailTextField)
        bottomBorder(popUpTextField)
    }
    
    // Styling - textfield
    func bottomBorder(_ textField: UITextField) {
        // Makes the textfield appear as if it were just a line
        let layer = CALayer()
        layer.backgroundColor = UIColor.blue.cgColor
        layer.frame = CGRect(x: 0.0, y: textField.frame.size.height - 1.0, width: textField.frame.size.width, height: 1.0)
        textField.layer.addSublayer(layer)
    }
    
    
    // MARK: - Display User Data
    // Make API call to database and display user data
    func displayUserData () {
        
        // Get the current user's data collection
        let userData = db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
        userData.getDocument { (document, error) in
            if error == nil {
                if let document = document, document.exists {
                    // Setting the profile values if there is user data found without a problem
                    self.usernameTextField.text = document.get("username") as? String ?? ""
                    
                    if let image = document.get("image") {
                        self.imageText = image as? String ?? ""
                        self.profileImage.sd_setImage(with: URL(string: self.imageText), placeholderImage: self.placeholderImage)
                        self.profileImage.contentMode = .scaleAspectFill
                    }
                    
                    if let firstname = document.get("first name") {
                        self.firstnameTextField.text = firstname as? String
                    }
                    
                    if let lastname = document.get("last name") {
                        self.lastnameTextField.text = lastname as? String
                    }
                    
                    if let email = document.get("email") {
                        self.emailTextField.text = email as? String
                    }
                } else {
                    // Error check for document
                    print("User document doesn't exists")
                }
            } else {
                // Error check for document
                print ("Error in user document, error: \(String(describing: error))")
            }
        }
            
        // Get and set the social media links from Firestore
        let userSocialData = userData.collection("socials").document("links")
        userSocialData.getDocument { (document, error) in
            if error == nil {
                if let document = document, document.exists {
                    if let twitter = document.get("twitter") {
                        self.twitterLink = twitter as? String ?? ""
                    }
                    if let facebook = document.get("facebook") {
                        self.facebookLink = facebook as? String ?? ""
                    }
                    if let snapchat = document.get("snapchat") {
                        self.snapchatLink = snapchat as? String ?? ""
                    }
                    if let instagram = document.get("instagram") {
                        self.instagramLink = instagram as? String ?? ""
                    }
                    if let linkedin = document.get("linkedin") {
                        self.linkedinLink = linkedin as? String ?? ""
                    }
                } else {
                    // Error check for document
                    print("Social Media link doc doesn't exists, user hasn't inputted any")
                }
            } else {
                // Error check for document
                print("Error in getting social document, error: \(String(describing: error))")
            }
        }
    }
    
  
    // MARK: - Handling Textfield changes
    // Updating the textfield changes
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        
        guard let range = Range(range, in: currentText) else { assertionFailure("range not defined")
            return true
        }
        
        // Display the changes
        textField.text = currentText.replacingCharacters(in: range, with: string)
    
        return false
    }
    
    // For when user finished making changes to the textfiends
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        // Update the appropriate social media links if the textfield from a popup
        if textField == popUpTextField {
            switch popUpLabel.text {
            case "Twitter":
                self.twitterLink = "http://twitter.com/" + (popUpTextField.text ?? "[username]")
            case "Facebook":
                self.facebookLink = popUpTextField.text ?? "[username]"
            case "Snapchat":
                self.snapchatLink = "https://www.snapchat.com/add/" + (popUpTextField.text ?? "[username]")
            case "Instagram":
                self.instagramLink = "https://www.instagram.com/" + (popUpTextField.text ?? "[username]")
            case "LinkedIn":
                let fullName = popUpTextField.text?.replacingOccurrences(of: " ", with: "%20") ?? "[username]"
                
                self.linkedinLink = "https://www.linkedin.com/search/results/all/?keywords=" +  fullName + "&origin=GLOBAL_SEARCH_HEADER"
            default:
                print("Doesn't match any of the social media, meaning it's for password reset")
            }
        } else {
            // Store data right away if it's not the pop up because pop up would've stored already
            storeData()
        }

        return true
    }
    
    // MARK: - Add Profile Picture
    // When user clicks on the camera icon to change profile image
    @IBAction func addProfileImage() {
        checkPermission()
        self.imagePickerController.sourceType = .photoLibrary
        self.present(self.imagePickerController, animated: true, completion: nil)
        
    }
    
    // Check for photos access
    func checkPermission() {
        // Ask for authorization
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({
                (status: PHAuthorizationStatus) -> Void in ()
            })
        }
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {} else {
            PHPhotoLibrary.requestAuthorization(requestAuthorization)
        }
    }
    
    // Status for photo authorization
    func requestAuthorization(status: PHAuthorizationStatus) {
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            print("Have access to photos")
        } else {
            print("Don't have access to photos")
        }
    }
    
    // Get the url of selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Store the image into Firebase storage
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL{
            uploadToStorage(fileURL: url)
        }
        
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    
    // Store it into Firebase storage
    func uploadToStorage(fileURL: URL) {
        let _ = Data()
        let storageRef = storage.reference()
        
        let localFile = fileURL
        
        // Store the image as the user's id
        let photoRef = storageRef.child(Auth.auth().currentUser?.uid ?? "")
        let _ = photoRef.putFile(from: localFile, metadata: nil) { (metadata, error) in
            guard metadata != nil else {
                print("Error: \(String(describing: error?.localizedDescription))")
                return
            }
        
        // Photo successfully uploaded to storage, store the url in touser data document in Firestore
        photoRef.downloadURL(completion: { (url, error) in
            if let urlText = url?.absoluteString {
                self.imageText = urlText
                self.storeData()
            }
        })
        print("Photo has been uploaded to storage")
        }
        // Temporary placeholder image in case of error in uploading
        profileImage.sd_setImage(with: photoRef, placeholderImage: placeholderImage)
    }
    
    // MARK: - Social Media Button Clicked - Display corresponding popup
    // Display pop up for with values stored regarding user's twitter info
    @IBAction func twitterClicked() {
        displayPopUp("Twitter", twitterLink, false)
    }

    // Connect to Facebook App
    @IBAction func facebookClicked() {
        // Check if the user is currently logged in or not to decide appropriate action
           if (AccessToken.current == nil) {
               loginFB()
           } else {
               logoutFB()
           }
    }
    
    // Display pop up for with values stored regarding user's snapchat info
    @IBAction func snapchatClicked() {
        displayPopUp("Snapchat", snapchatLink, false)
    }
    
    // Display pop up for with values stored regarding user's instagram info
    @IBAction func instagramClicked() {
        displayPopUp("Instagram", instagramLink, false)
    }
    
    // Display pop up for with values stored regarding user's linkedin info
    @IBAction func linkedinClicked() {
        displayPopUp("LinkedIn", linkedinLink, false)
    }
    
    // MARK: - Facebook Login
    func loginFB() {
        // Use Facebook's login manager to get authorization token and permission to certain data fields
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [.publicProfile, .email, .custom("user_link")], viewController: self) { (result) in
            // Error and proceedings based on result of auhtorization token request
            switch result {
            case .cancelled:
                print("User canceled login")
            case .failed(let error):
                print("here in failed")
                print(error.localizedDescription)
            case .success(_, _, _):
                self.getFBData()
            }
        }
    }
    // Make API request for user's profile link
    func getFBData(){
        // Use the token to retrive user's data from Facebbok
        if let token = AccessToken.current, !token.isExpired {
            let token = token.tokenString
            
            // Making a request for the user's name, email, and Facebook profile link
            let request = GraphRequest(graphPath: "me", parameters: ["fields":"name, email, link" ], tokenString: token, version: nil, httpMethod: .get)
            request.start(completionHandler: { (connection, result, error) in
                if error == nil {
                    // Get the link and store it to user's Firebase collection
                    let data = result as? [String:Any]
                    if let link = data?["link"] as? String {
                        self.facebookLink = link
                        print(self.facebookLink)
                        self.storeData()
                    }
                } else {
                    // Error check
                    print("Error: \(String(describing: error?.localizedDescription))")
                }
            })
        } else {
            // Error check
            print("no token")
        }
    }
    
    // Log user out from Facebook
    func logoutFB() {
        let logoutManager = LoginManager()
        logoutManager.logOut()
        
        // Let user know they've successfully logged out
        let alert = UIAlertController(title: "Logout", message: "You've been logged out.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        // Remove their Facebook profile link from Firestore
        self.facebookLink = ""
        storeData()
    }
    
    
    // MARK: - Pop up for Social Media & Reset Password
    // Display pop up view
    func displayPopUp(_ label: String, _ text: String, _ reset: Bool) {
        // Disable all the background functions
        TFFields = TFFields.map({ $0.isUserInteractionEnabled = false; return $0})
        buttons = buttons.map({ $0.isUserInteractionEnabled = false; return $0})
        
        // Allow only the pop up components to have interaction
        popUpTextField.isUserInteractionEnabled = true
        closeViewBtn.isUserInteractionEnabled = true
        
        // Reset pop up displays different values and slightly different style
        if reset {
            popUpLabel.font = popUpLabel.font.withSize(16)
            popUpConfirmBtn.isHidden = false
            popUpConfirmBtn.isUserInteractionEnabled = true
            promptLabel.isHidden = true
        } else {
            popUpLabel.font = popUpLabel.font.withSize(22)
            promptLabel.isHidden = false
            promptLabel.text = "Please enter your username:"
        }
        popUpLabel.text = label
        popUpView.isHidden = false

        // Show the user's corresponding social media info in the textfield
        switch label {
        case "Twitter":
            let t = "http://twitter.com/"
            popUpTextField.text = String(text.dropFirst(t.count))
        case "Snapchat":
            let s = "https://www.snapchat.com/add/"
            popUpTextField.text = String(text.dropFirst(s.count))
        case "Instagram":
            let i = "https://www.instagram.com/"
            popUpTextField.text = String(text.dropFirst(i.count))
        case "LinkedIn":
            promptLabel.text = "Please enter your full name"
            let k = text.replacingOccurrences(of: "https://www.linkedin.com/search/results/all/?keywords=", with: "")
            let z = k.replacingOccurrences(of: "&origin=GLOBAL_SEARCH_HEADER", with: "")
            let y = z.replacingOccurrences(of: "%20", with: " ")
            popUpTextField.text = y
        default:
            popUpTextField.text = text
        }
      

    }
    
    
    @IBAction func closePopUp() {
        // Hide the pop up and all its components
        popUpView.isHidden = true
        popUpConfirmBtn.isHidden = true
        popUpErrLabel.isHidden = true
        
        // Enable the previously disabled functions in the background of pop up
        TFFields = TFFields.map({ $0.isUserInteractionEnabled = true; return $0})
        buttons = buttons.map({ $0.isUserInteractionEnabled = true; return $0})
        
        // Disable pop up components
        popUpConfirmBtn.isHidden = true
        popUpConfirmBtn.isUserInteractionEnabled = false
        popUpTextField.isUserInteractionEnabled = false
        emailTextField.isUserInteractionEnabled = false
        
        popUpTextField.text = ""
        
        // Update the user's data collection in Firestore based on changes in the pop up, e.g. adding in social media username
        storeData()
    }
    
    
    
    // MARK: - Updating the database
    func storeData() {
        
        // Get current user's data collection and update with the newly inputted/updated values
        let userDoc = db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
        userDoc.updateData([
            "username": usernameTextField.text ?? (Any).self,
            "image": imageText,
            "first name": firstnameTextField.text ?? (Any).self,
            "last name": lastnameTextField.text ?? (Any).self,
            "email" : emailTextField.text ?? (Any).self,
        ])
        
        // Also, update the social media links
        let socialData = ["twitter" : twitterLink, "facebook" : facebookLink, "snapchat" : snapchatLink, "instagram" : instagramLink, "linkedin" : linkedinLink]
        let socialDoc = userDoc.collection("socials").document("links")
        socialDoc.setData(socialData)
    
        // Keep the user's profile view updated with new info
        displayUserData()
    }
    
    
    // MARK: - Reseting Password
    // Reset button pressed
    @IBAction func resetPassPress() {
        displayPopUp("Enter the email to send the reset link:", "", true)
    }
    
    // Reset password confirm
    @IBAction func confirmReset(_ sender: Any) {
        
        // Send email to reset password
        Auth.auth().sendPasswordReset(withEmail: popUpTextField.text ?? "",  completion: { error in
            if error == nil {
                self.closePopUp()
            } else {
                self.popUpErrLabel.isHidden = false
                self.popUpErrLabel.text = "Invalid email"
            }
        })
    }
    
    
    // MARK: - Navigation
    @IBAction func to_lobby(_ sender: Any) {
        // go to lobby view
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let lobbyViewController = storyboard.instantiateViewController(identifier: "lobbyVC") as? LobbyViewController else {
            assertionFailure("couldn't find vc")
            return }
        //optional navigation controller
        navigationController?.pushViewController(lobbyViewController, animated: true)
    }

    // Setting button pressed
    @IBAction func toEditFriend() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let friendViewController = storyboard.instantiateViewController(identifier: "friendVC") as? FriendViewController else {
            assertionFailure("couldn't find vc")
            return }
        //optional navigation controller
        navigationController?.pushViewController(friendViewController, animated: true)
    }
    
    // Sign out button pressed
    @IBAction func toLogin(_ sender: Any) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let db = Firestore.firestore()
        /*Delete fields of current match for myself*/
        db.collection("users").document(uid).collection("matches").document("current match").delete()
        db.collection("users").document(uid).collection("matches").document("previous matches").delete()
        /* set is on call to false*/
        db.collection("users").document(uid).getDocument{(document, error) in
            if let document = document, document.exists {
                document.reference.updateData([
                    "isOnCall": "false"
                ])
            }
        }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let loginViewController = storyboard.instantiateViewController(identifier: "logInVC") as? ViewController else {
            assertionFailure("couldn't find vc")
            return }
        //optional navigation controller
        navigationController?.pushViewController(loginViewController, animated: true)
    }
    
// MARK: - Online Presence
    func buildPresence() {
        //MARK: Build Presence System
         
         /*Set up presence with realtime database*/
         
         // Fetch the current user's ID from Firebase Authentication.
         
         let uid = Firebase.Auth.auth().currentUser?.uid
         
         let path = "/status/" + String(uid ?? "")
         
         
         // Create a reference to this user's specific status node.
         // This is where we will store data about being online/offline.
         let userStatusDatabaseRef = FirebaseDatabase.Database.database().reference(withPath: path)
         
         // We'll create two constants which we will write to
         // the Realtime database when this device is offline
         // or online.
        let isOffline: [String: Any] = [
             "state": "offline",
         ]
        let isOnline: [String: Any] = [
             "state": "online",
         ]
         
         // Create a reference to the special '.info/connected' path in
         // Realtime Database. This path returns `true` when connected
         // and `false` when disconnected.
         let connectedRef = Database.database().reference(withPath: ".info/connected")
         connectedRef.observeSingleEvent(of: .value, with: { snapshot in
             if((snapshot.value != nil) == false) {
                 
                 return
             }
             
         })
         
         // If we are currently connected, then use the 'onDisconnect()'
             // method to add a set which will only trigger once this
             // client has disconnected by closing the app,
             // losing internet, or any other means.
 
         userStatusDatabaseRef.onDisconnectSetValue(isOffline, withCompletionBlock: {_,_ in
             userStatusDatabaseRef.setValue(isOnline)
            
         })
       
    }
}
