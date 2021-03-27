//
//  lobbyViewController.swift
//  PopMatch
//
//  Created by Ray Ngan on 2/21/21.
//

import UIKit
import Firebase
import AVFoundation

class LobbyViewController: UIViewController {
    
    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var bubbleZoom: UIImageView!
    @IBOutlet weak var headerLabel1: UILabel!
    @IBOutlet weak var headerLabel2: UILabel!
    
    var idealMatches = [String:[String]]()
    var answers = [String: [String]] ()
    var prev_matches = [String] ()
    var suspended = false
    var findMatchesQueue = DispatchQueue.global(qos: .userInitiated)
    var currUid = ""
    var audioPlayer = AVPlayer()
    var userNumber = 0
    var db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //take the current id as the current user's id and get the user's infp
        self.currUid = Firebase.Auth.auth().currentUser?.uid ?? ""
        getUserInfo()
        
        let sound = Bundle.main.path(forResource: "mixkit-soap-bubble-sound-2925", ofType: "wav")
        
        //initialize sound above
        audioPlayer = AVPlayer(url: URL(fileURLWithPath: sound ?? ""))
        
        //setup
        bubbleZoom.isHidden = true
        bubbleView.backgroundColor = .white
        self.view.addSubview(bubbleView)
        
        //adding the floating bubbles with continuous animation
        var array: [UIImageView] = []
        let userNumber = 10
        for _ in 0...userNumber-1 {
            let bubbleImageView = UIImageView(image: #imageLiteral(resourceName: "bubble2 copy"))
            bubbleImageView.translatesAutoresizingMaskIntoConstraints = false
            array.append(bubbleImageView)
        }
        for i in 0...userNumber-1 {
            array[i].frame = CGRect(x: bubbleView.center.x, y: bubbleView.center.y, width: 100, height: 100)
            bubbleView.addSubview(array[i])
            animation(image: array[i])
        }
        
    }
    
    var previousAnimation = Int()
    
    func animation(image: UIImageView) {
        let maxX = self.bubbleView.frame.maxX - CGFloat(100)
        let maxY = self.bubbleView.frame.height - CGFloat(100)
        var newX = UInt32(0)
        var newY = UInt32(0)
        
        //decide randomly which direction to go into
        var sideDecider = Int.random(in: 1...4)
        
        //added to make it less likely bubbles will overlap
        if previousAnimation == sideDecider && sideDecider < 4 {
            sideDecider += 1
        } else if previousAnimation == sideDecider && sideDecider == 4 {
            sideDecider = 1
        }
        
        //decide which side the bubble will go based on the random number
        switch sideDecider {
        case 1:
            newX = UInt32(maxX)
            newY = 0
        case 2:
            newX = UInt32(maxX)
            newY = UInt32(maxY)
        case 3:
            newX = 0
            newY = UInt32(maxY)
        case 4:
            newX = 0
            newY = 0
        default:
            newX = 0
            newY = 0
        }
        previousAnimation = sideDecider
        
        //calculation of distance to have the speed of the bubble be constant
        var distanceX = UInt32(0)
        var distanceY = UInt32(0)
        if newX > UInt32(image.center.x) {
            distanceX = newX - UInt32(image.center.x)
        } else {
            distanceX = UInt32(image.center.x) - newX
        }
        if newY > UInt32(image.center.y) {
            distanceY = newY - UInt32(image.center.y)
        } else {
            distanceY = UInt32(image.center.y) - newY
        }
        
        let totalDistance = sqrt(Double(distanceX * distanceX)) + sqrt(Double(distanceY * distanceY))
        let velocity = 125
        UIView.animate(withDuration: totalDistance / Double(velocity), delay: 0, options: .curveLinear, animations: {
            image.frame.origin.x = CGFloat(newX)
            image.frame.origin.y = CGFloat(newY)
            image.layoutIfNeeded()
        }, completion:
            { finished in
                self.animation(image: image)
            }
        )
    }
    
    @IBAction func backButton() {
        findMatchesQueue.suspend() //suspend queue relating to findMatches()
        self.suspended = true
        
        /*Go back to profileVC*/
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let profileViewController = storyboard.instantiateViewController(withIdentifier: "profileVC") as? ProfileViewController else {
            assertionFailure("couldn't find vc") //will stop program
            return
        }
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
    /*Get current user's answers to questions*/
    func getUserInfo() {
        let db = Firestore.firestore()
        db.collection("users").document(self.currUid).collection("questions").document("friendship").getDocument{(document, error) in
            if let document = document, document.exists {
                let data = document.data()
                
                self.answers["major"] = [data?["major"] as? String ?? ""]
                self.answers["hobbies"] = data?["hobbies"] as? [String]
                self.answers["music"] = data?["music"] as? [String]
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.findMatches()
            }
        }
    }
    
    /*Find match for user*/
    func findMatches() {
        var matches = [String: String]()
        matches = [:]
        
        if self.suspended == true { //back button was pressed
            return
        }
        
        self.findMatchesQueue.async(execute: {
            /*Task 1: Get the user's previous matches in the current setting */
            
            var semaphore = DispatchSemaphore(value: 0)
            self.db.collection("users").document(self.currUid).collection("matches").document("previous matches").getDocument{ (document, error) in
                if let document = document, document.exists {
                    self.prev_matches = document.get("prev_matches") as? [String] ?? []
                }
                else {
                    self.db.collection("users").document(self.currUid).collection("matches").document("previous matches").setData(["prev matches": []])
                }
                semaphore.signal() //done with task 1
                
            }
            
            
            semaphore.wait() //wait for Task 1 to finish
            
            /*Task 2: Check if they matched with someone already by checking if current match document exists in firebase*/
            var prevmatchId = ""
            var matchState = ""
            semaphore = DispatchSemaphore(value: 0)
            self.db.collection("users").document(self.currUid).collection("matches").document("current match").getDocument{(document, error) in
                if let document = document, document.exists {
                    let matchid = document.get("match id") as? String ?? ""
                    
                    /*Matched with someone, get that user's id*/
                    if matchid != "" {
                        prevmatchId = matchid
                        Database.database().reference().child("status").child(prevmatchId).observe(.value, with: { (snapshot) in
                            let value = snapshot.value as? [String:Any]
                            matchState = value?.first?.value as? String ?? ""
                            semaphore.signal() // done with task 2
                        })
                        
                    }
                    else {
                        semaphore.signal()
                    }
                }
                else {
                    semaphore.signal()
                }
            }
            
            semaphore.wait()   // wait for task 2 to finish
            
            /*They weren't matched with anyone before, find a new match*/
            if prevmatchId == "" || (matchState == "offline") {
                
                /*Task 3: get all users from realtime database and only add online user ids to matches map*/
                semaphore = DispatchSemaphore(value: 0)
                
                let ref = Database.database().reference().child("status")
                ref.observeSingleEvent(of:.value, with: { snapshot in
                    let children = snapshot.children.allObjects as? [DataSnapshot] ?? [DataSnapshot()]
                    for child in children {
                        
                        let uid = child.key
                        let value = child.value as? [String:Any]
                        let state = value?.values.first as? String ?? ""
                        
                        if state == "online" && self.prev_matches.contains(uid) == false && self.currUid != uid {
                            matches[uid] = ""
                        }
                    }
                    semaphore.signal()
                })
                
                semaphore.wait() // wait for task 3 to finish
                
                /*No users are online*/
                self.findMatchesQueue.asyncAfter(deadline: .now()+2.0){}
                if(matches.isEmpty == true) {
                    DispatchQueue.main.async { //update UI in main dispatch queue
                        print("No Matches Found!")
                        self.headerLabel1.text = "No bubbles to pop"
                        self.headerLabel2.text = "Try again later"
                        return
                    }
                    return
                }
                
                /*Task 4: get the bool variable isOnCall for every match in matches that is true if user is unavailable */
                
                semaphore = DispatchSemaphore(value: 0)
                var i = 0
                
                for match in matches {
                    self.db.collection("users").document(match.key).getDocument {(document, error) in
                        i+=1
                        if i == matches.count {
                            semaphore.signal() //signal at the least index
                        }
                        if let document = document, document.exists {
                            var isOnCall = document.get("isOnCall") as? String ?? "false"
                            if isOnCall == "" {
                                isOnCall = "false"
                            }
                            self.findMatchesQueue.asyncAfter(deadline: .now() + 2.0) {}
                            matches.updateValue(isOnCall, forKey: match.key) //update map
                        }
                    }
                }
                
                semaphore.wait() // wait for task 4 to finish
                
                /*Remove matches that are busy*/
                matches = matches.filter{$0.value == "false" || $0.value == ""}
                
                var matchId = ""
                var matchedOn = [String]()
                
                /*No matches left*/
                self.findMatchesQueue.asyncAfter(deadline: .now()+2.0){}
                if(matches.isEmpty == true) {
                    DispatchQueue.main.async {
                        print("No Matches Found!")
                        self.headerLabel1.text = "No bubbles to pop"
                        self.headerLabel2.text = "Try again later"
                        return
                    }
                    return
                    
                }
                else {
                    
                    /* Task 5: Find the most ideal match, if not found match with first person*/
                    semaphore = DispatchSemaphore(value: 0)
                    
                    
                    

                    /*Compare each match's answers to current user's, if its a match then add match id to idealMatches array */
                    
                    while (matches.isEmpty){
                        self.findMatchesQueue.asyncAfter(deadline: .now()+1.0){}
                    }
                    for (index, match) in matches.enumerated() {
                        var matchAnswers = [String:[String]]()
                        matchedOn.removeAll()
                        
                        self.db.collection("users").document(match.key).collection("questions").document("friendship").getDocument{(document, error) in
                            if let document = document, document.exists {
                                
                                matchAnswers["major"] = [document.get("major") as? String ?? ""]
                                matchAnswers["hobbies"] = document.get("hobbies") as? [String] ?? []
                                matchAnswers["music"] = document.get("music") as? [String] ?? []
                                
                                /*Check if major matches*/
                                if self.answers["major"] == matchAnswers["major"] {
                                    matchId = match.key
                                    
                                    let major = matchAnswers["major"]?.first ?? ""
                                    if !matchedOn.contains(major) {
                                        matchedOn.append(major)
                                    }
                                }
                                /*Check if any hobby matches*/
                                for hobby in matchAnswers["hobbies"] ?? [] {
                                    if self.answers["hobbies"]?.contains(hobby) == true {
                                        matchId = match.key
                                        matchedOn.append(hobby)
                                    }
                                }
                                
                                /*Check if any music genre matches*/
                                for music in matchAnswers["music"] ?? [] {
                                    if self.answers["music"]?.contains(music) == true {
                                        matchId = match.key
                                        matchedOn.append(music)
                                    }
                                }
                                
                                if !matchedOn.isEmpty  { //match had things in common
                                    self.idealMatches[match.key] = matchedOn
                                }
                            }
                            if index == 0 {
                                semaphore.signal()
                            }
                        }
                    }
                    
                    semaphore.wait() //wait for task 5 to finish
                    
                    if self.idealMatches.isEmpty == false { //One or more ideal matches found
                        
                        let result = self.idealMatches.sorted(by: {$0.1.count > $1.1.count}) //sort by match who has the most in common to the least
                        
                        matchId = result.first?.key ?? ""
                        
                        /*set current match variable in firestore */
                        let docData1: [String: Any] = [
                            "match id": matchId,
                            "matched on": matchedOn,
                        ]
                        let docData2: [String: Any] = [
                            "match id": self.currUid,
                            "matched on": matchedOn,
                        ]
                        
                        self.db.collection("users").document(self.currUid).collection("matches").document("current match").setData(docData1) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            }
                            else{
                                print("Document successfully written with id \(self.currUid)")
                            }
                            
                            /*Set isOnCall to true for both user and its match*/
                            self.db.collection("users").document(self.currUid).getDocument{(document, error) in
                                if let document = document, document.exists {
                                    document.reference.updateData([
                                        "isOnCall": "true"
                                    ])
                                }
                            }
                            self.db.collection("users").document(matchId).getDocument{(document, error) in
                                if let document = document, document.exists {
                                    document.reference.updateData([
                                        "isOnCall": "true"
                                    ])
                                }
                            }
                        }
                        
                        self.db.collection("users").document(matchId).collection("matches").document("current match").setData(docData2) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            }
                            else{
                                print("Document successfully written with id \(matchId)")
                            }
                            
                            /*Play match found animation and move to MatchingVC*/
                            DispatchQueue.main.async {
                                self.bubbleZoom.transform = CGAffineTransform.identity
                                self.bubbleZoom.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut , animations: {
                                    self.bubbleZoom.isHidden = false
                                    self.bubbleZoom.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                    self.audioPlayer.play()
                                }, completion: { finished in
                                    
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    guard let matchingViewController = storyboard.instantiateViewController(withIdentifier: "matchingVC") as? MatchingViewController else {
                                        assertionFailure("couldn't find vc")
                                        return
                                    }
                                    
                                    self.navigationController?.pushViewController(matchingViewController, animated: false)
                                })
                            }
                            
                        }
                    }
                    else { //No ideal matches found, match with first user in matches
                        
                        matchId = matches.first?.key ?? ""
                        
                        let docData1: [String: Any] = [
                            "match id": matchId,
                            "matched on": matchedOn,
                        ]
                        let docData2: [String: Any] = [
                            "match id": self.currUid,
                            "matched on": matchedOn,
                        ]
                        
                        self.db.collection("users").document(self.currUid).collection("matches").document("current match").setData(docData1) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            }
                            else{
                                print("Document successfully written with id \(self.currUid)")
                            }
                            
                            /*Set isOnCall to true for both user and its match*/
                            self.db.collection("users").document(self.currUid).getDocument{(document, error) in
                                if let document = document, document.exists {
                                    document.reference.updateData([
                                        "isOnCall": "true"
                                    ])
                                }
                            }
                            self.db.collection("users").document(matchId).getDocument{(document, error) in
                                if let document = document, document.exists {
                                    document.reference.updateData([
                                        "isOnCall": "true"
                                    ])
                                }
                            }
                            
                        }
                        self.db.collection("users").document(matchId).collection("matches").document("current match").setData(docData2) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            }
                            else{
                                print("Document successfully written with id \(matchId)")
                            }
                            
                            /*Play match found animation and move to MatchingVC*/
                            DispatchQueue.main.async {
                                self.bubbleZoom.transform = CGAffineTransform.identity
                                self.bubbleZoom.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                                UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut , animations: {
                                    self.bubbleZoom.isHidden = false
                                    self.bubbleZoom.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                                    self.audioPlayer.play()
                                }, completion: { finished in
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    guard let matchingViewController = storyboard.instantiateViewController(withIdentifier: "matchingVC") as? MatchingViewController else {
                                        assertionFailure("couldn't find vc")
                                        return
                                    }
                                    
                                    self.navigationController?.pushViewController(matchingViewController, animated: false)
                                })
                            }
                            
                        }
                    }
                }
            } else {
                
                /*Matched already, play animation and move to matchingVC */
                DispatchQueue.main.async {
                    self.bubbleZoom.transform = CGAffineTransform.identity
                    self.bubbleZoom.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
                    UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut , animations: {
                        self.bubbleZoom.isHidden = false
                        self.bubbleZoom.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        self.audioPlayer.play()
                    }, completion: { finished in
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        guard let matchingViewController = storyboard.instantiateViewController(withIdentifier: "matchingVC") as? MatchingViewController else {
                            assertionFailure("couldn't find vc")
                            return
                        }
                        
                        self.navigationController?.pushViewController(matchingViewController, animated: false)
                    })
                }
            }
        })
    }
}
