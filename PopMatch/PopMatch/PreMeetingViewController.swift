//
//  PreMeetingViewController.swift
//  PopMatch
//
//  Created by Ray Ngan on 3/5/21.
//

import UIKit
import Firebase

class PreMeetingViewController: UIViewController {
    
    
    @IBOutlet weak var bubble: UIImageView!
    var displayLink: CADisplayLink!
    var value: CGFloat = 0.0
    var waitTime = 0
    var invert: Bool = false
    var roomName: String = ""
    var accessToken : String = ""
    var waitTimer : Timer?
    var db = Firestore.firestore()
    var username = ""
    var matchName = ""
    var matchId = ""
    var currUId = ""
    var enteredRoom = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.currUId = Auth.auth().currentUser?.uid ?? ""
        displayLink = CADisplayLink(target: self, selector: #selector(handleAnimations))
        displayLink.add(to: RunLoop.main, forMode: .default)
        waitTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.checkIfRoomIsReady), userInfo: nil, repeats: true)
    }
    
    
    // Blinking bubble animation for the waiting room
    @objc func handleAnimations() {
        invert ? (value -= 1) : (value += 1)
        bubble.alpha = (value / 100)
        if ( value > 100 || value < 0) {
            invert = !invert
        }
    }
    
    // Change isOnCall to false
    func setIsOnCall() {
        self.db.collection("users").document(self.currUId).getDocument{(document, error) in
            if let document = document, document.exists {
                document.reference.updateData([
                    "isOnCall": "false"
                ])
            }
        }
    }
    
    // Add current match to previous mathces
    func addMatchToPrevMatches() {
        self.db.collection("users").document(self.currUId).collection("matches").document("previous matches").getDocument {(document, error)  in
            if let document = document, document.exists {
                var prev_matches = document.get("prev_matches") as? [String] ?? []
                prev_matches.append(self.matchId)
                self.db.collection("users").document(self.currUId).collection("matches").document("previous matches").setData(["prev_matches": prev_matches])
            }
        }
    }
   
    // A func that is called every second to see if the other matched person went into the video room
    @objc func checkIfRoomIsReady() {
        db.collection("Rooms").document(roomName).getDocument() {
            (document, error) in
            if(error == nil){
                if let document = document, document.exists {
                    if document.get("Entered") != nil{
                        self.enterVideo()
                        self.waitTimer?.invalidate()
                        self.db.collection("Rooms").document(self.roomName).setData(["Timer":"300"], merge: false)
                        self.enteredRoom = true

                    }
                    if document.get("Rejected") != nil{
                        self.db.collection("Rooms").document(self.roomName).delete(){ err in
                            if let err = err {
                                print("Error removing document: \(err)")
                            } else {
                                print("Document successfully removed!")
                            }
                        }
                        /*Add user to previous matches */
                        self.addMatchToPrevMatches()
                        
                        /*Delete fields of current match for myself*/
                        self.db.collection("users").document(self.currUId).collection("matches").document("current match").delete() { err in
                            if let err = err {
                                print("Error removing document: \(err)")
                            } else {
                                print("Document successfully removed!")
                            }
                        }
                        self.enteredRoom = true
                        /* set is on call to false*/
                        self.setIsOnCall()
                        self.goBackToLobby()
                    }
                    
                }
                
            }
            
        }
    }
    
    func enterVideo(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let meetingViewController = storyboard.instantiateViewController(withIdentifier: "meetingVC") as? MeetingViewController else {
            assertionFailure("couldn't find vc")
            return
        }
        // need to gernerate tokens for each user
        meetingViewController.accessToken = accessToken
        meetingViewController.roomName =  roomName
        meetingViewController.matchId = matchId
        navigationController?.pushViewController(meetingViewController, animated: true)
    }
    func goBackToLobby(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let lobbyViewController = storyboard.instantiateViewController(identifier: "lobbyVC") as? LobbyViewController else {
            assertionFailure("couldn't find vc")
            return }
        //optional navigation controller
        navigationController?.pushViewController(lobbyViewController, animated: true)
    }
}
