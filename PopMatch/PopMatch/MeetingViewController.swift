//
//  MeetingViewController.swift
//  PopMatch
//
//  Created by Ray Ngan on 2/21/21.
//


import UIKit
import TwilioVideo
import Firebase
import FirebaseStorage
import FirebaseUI




class MeetingViewController: UIViewController {
    

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var myView: VideoView!
    @IBOutlet weak var addTimerButton: UIButton!
    @IBOutlet weak var micImage: UIButton!
    @IBOutlet weak var vidImage: UIButton!
    @IBOutlet weak var endImage: UIButton!
    @IBOutlet weak var socalMediaPopUp: UIView!
    @IBOutlet weak var sendMediaText: UILabel!
    @IBOutlet weak var twitter: UIButton!
    @IBOutlet weak var facebook: UIButton!
    @IBOutlet weak var snapchat: UIButton!
    @IBOutlet weak var ig: UIButton!
    @IBOutlet weak var linkedin: UIButton!
    @IBOutlet weak var urlView: UIView!
    @IBOutlet weak var mediaIcon: UIImageView!
    @IBOutlet weak var socialMediaMessageLabel: UILabel!
    @IBOutlet weak var mediaInbox: UIButton!
   
    var remoteView: VideoView!
    var room: Room?
    var camera: CameraSource?
    var localVideoTrack: LocalVideoTrack?
    var localAudioTrack: LocalAudioTrack?
    var remoteParticipant: RemoteParticipant?
    var vidTimer: Timer?
    var roomName: String = ""
    var accessToken : String = ""
    var matchId = ""
    var db = Firestore.firestore()
    var storage = Storage.storage()
    var twitterLink: String = ""
    var facebookLink: String = ""
    var snapchatLink: String = ""
    var instagramLink: String = ""
    var linkedinLink: String = ""
    var checkUpdates: Timer?
    var links: [String] = []
    var y = 10
    var sentSocialsCount = 0
    var checkSentSocialsTimer: Timer?
    var inboxToggle = 1
    var flip = 0
    var socialMediaSent: [Int] = [0,0,0,0,0]
    var questionTime = 0
    var toggleMicState = 1
    var toggleVidState = 1
    var questions: [String] = ["What goes in first? Milk or Cereal", "You are stranded on an island. What are 3 things you’re bringing?", "How do you pronounce gif?", "Favorite TV show?", "Never have I ever", "Two truths and a lie", "One thing I’ll never do again", "Most embarrassing thing that happened to you", "This year, I really want to", "If you could have any superpower, what would you want, and why?", "Worst professor experience", "Why did you choose your major", "What’s your ideal life"]
    var questionsNum  = 12
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLocalMedia()
        connect()
        messageLabel.adjustsFontSizeToFitWidth = true;
        messageLabel.minimumScaleFactor = 0.75;
        links = [twitterLink, facebookLink, snapchatLink, instagramLink, snapchatLink]
        socalMediaPopUp.isHidden = true
        urlView.isHidden = true
        mediaInbox.tintColor = UIColor.systemBlue
        setUpSocialMedia()
        // Hide video connection message after 5 sec
        Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.hideInfo), userInfo: nil, repeats: false)
        // Update timer every second. Synced to firestore room timer
        checkUpdates = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        
        checkSentSocialsTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.checkForSentSocials), userInfo: nil, repeats: true)
        
    }
    
    @objc func hideInfo() {
        messageLabel.isHidden = true
    }
    
    func setUpSocialMedia() {
        let userData = db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
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
                    print("Social Media link doc doesn't exists, user hasn't inputted any")
                }
            } else {
                print("Error in getting social document, error: \(String(describing: error))")
            }
        }
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return self.room != nil
    }
    
    // Allow user to hide social media and funality buttons when tap on view
    @IBAction func tapGesture(_ sender: Any) {
        twitter.isHidden = flip == 0 ? true:false
        facebook.isHidden = flip == 0 ? true:false
        snapchat.isHidden = flip == 0 ? true:false
        ig.isHidden = flip == 0 ? true:false
        linkedin.isHidden = flip == 0 ? true:false
        sendMediaText.isHidden = flip == 0 ? true:false
        addTimerButton.isHidden = flip == 0 ? true:false
        vidImage.isHidden = flip == 0 ? true:false
        micImage.isHidden = flip == 0 ? true:false
        endImage.isHidden = flip == 0 ? true:false
        mediaInbox.isHidden = flip == 0 ? true:false
        flip = flip == 0 ? 1 : 0
    }
    
    
    
    // Get a random icebreaker questions and send it to the room firestore database
    @IBAction func generateQuestions(_ sender: Any) {
        if (questionsNum != 0){
            let randInt = Int.random(in: 0..<questionsNum)
            self.db.collection("Rooms").document(roomName).setData(["Icebreaker":questions[randInt]], merge: true)
            questions.remove(at: randInt)
            questionsNum -= 1
        }else{
            questions = ["What goes in first? Milk or Cereal", "You are stranded on an island. What are 3 things you’re bringing?", "How do you pronounce gif?", "Favorite TV show?", "Never have I ever", "Two truths and a lie", "One thing I’ll never do again", "Most embarrassing thing that happened to you", "This year, I really want to", "If you could have any superpower, what would you want, and why?", "Worst professor experience", "Why did you choose your major", "What’s your ideal life"]
            questionsNum = 12
            let randInt = Int.random(in: 0..<questionsNum)
            self.db.collection("Rooms").document(roomName).setData(["Icebreaker":questions[randInt]], merge: true)
            questions.remove(at: randInt)
            questionsNum -= 1
        }
    }
    
    // Called when user decides to send a social media. A popup will appear telling the user the social media has suceessfully sent.
    func setSocialMedia(media:String){
        urlView.isHidden = true;
        inboxToggle = 1
        switch media{
        case "twitter":
            mediaIcon.image = UIImage(named:"twitter Icon")
            socialMediaMessageLabel.text = "Your Twitter is sent!"
        case "facebook":
            mediaIcon.image = UIImage(named:"facebook Icon")
            socialMediaMessageLabel.text = "Your Facebook is sent!"
        case "ig":
            mediaIcon.image = UIImage(named:"Instagram Icon")
            socialMediaMessageLabel.text = "Your Instagram is sent!"
        case "linkedin":
            mediaIcon.image = UIImage(named:"LinkedIn Icon")
            socialMediaMessageLabel.text = "Your Linkedin is sent!"
        case "snapchat":
            mediaIcon.image = UIImage(named:"snapchat Icon")
            socialMediaMessageLabel.text = "Your Snapchat is sent!"
        default:
            mediaIcon.image = UIImage()
            socialMediaMessageLabel.text = "Your " + media + " is already sent!"
        }
        self.socalMediaPopUp.isHidden = false
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.hideSocialMediaPopUp), userInfo: nil, repeats: false)
    }
    // Hide the soical media sent message after 3 seconds
    @objc func hideSocialMediaPopUp(){
        socalMediaPopUp.isHidden = true
    }
    
    // Social media buttons. If pressed, it will upload to the user's info to the room firestore database and the other user can recieve it.
    @IBAction func sendTwitter(_ sender: Any) {
        if(twitterLink == ""){
            return
        }
        if (self.socialMediaSent[0] == 1 ){
            self.setSocialMedia(media: "Twitter")
        }
        let uid = Auth.auth().currentUser?.uid ?? ""
        db.collection("Rooms").document(roomName).getDocument() {(document, error ) in
            if error == nil {
                if let document = document, document.exists {
                    var socials = document.get(uid) as? [String] ?? []
                    
                    if socials.contains(self.twitterLink) == false {
                        socials.append(self.twitterLink)
                        self.db.collection("Rooms").document(self.roomName).setData([uid: socials], merge: true)
                        
                        self.setSocialMedia(media: "twitter")
                        self.socialMediaSent[0] = 1

                    }
                }
            }
            
        }
        
    }
    @IBAction func sendFacebook(_ sender: Any) {
        if(facebookLink == ""){
            return
        }
        if (self.socialMediaSent[1] == 1 ){
            self.setSocialMedia(media: "Facebook")
        }
        let uid = Auth.auth().currentUser?.uid ?? ""
        db.collection("Rooms").document(roomName).getDocument() {(document, error ) in
            if error == nil {
                if let document = document, document.exists {
                    var socials = document.get(uid) as? [String] ?? []
                    if socials.contains(self.facebookLink) == false {
                
                        socials.append(self.facebookLink)
                        self.db.collection("Rooms").document(self.roomName).setData([uid: socials] ,merge: true)
    
                        
                        
                        self.setSocialMedia(media: "facebook")
                        
                        self.socialMediaSent[1] = 1
                        
                    
                    }
                }
            }
            
        }
      
    }
    @IBAction func sendIG(_ sender: Any) {
        if(instagramLink == ""){
            return
        }
        if (self.socialMediaSent[2] == 1 ){
            self.setSocialMedia(media: "Instagram")
        }
        let uid = Auth.auth().currentUser?.uid ?? ""
        db.collection("Rooms").document(roomName).getDocument() {(document, error ) in
            if error == nil {
                if let document = document, document.exists {
                    var socials = document.get(uid) as? [String] ?? []
                    if socials.contains(self.instagramLink) == false {
                       
                        socials.append(self.instagramLink)
                        self.db.collection("Rooms").document(self.roomName).setData([uid: socials], merge: true)
                       
                        
                        self.setSocialMedia(media: "ig")
                        
                        self.socialMediaSent[2] = 1
                    }
                }
            }
            
        }
        
    }
    @IBAction func sendLinkedin(_ sender: Any) {
        if(linkedinLink == ""){
            return
        }
        if (self.socialMediaSent[3] == 1 ){
            self.setSocialMedia(media: "LinkedIn")
        }
        let uid = Auth.auth().currentUser?.uid ?? ""
        db.collection("Rooms").document(roomName).getDocument() {(document, error ) in
            if error == nil {
                if let document = document, document.exists {
                    var socials = document.get(uid) as? [String] ?? []
                    if socials.contains(self.linkedinLink) == false {
                      
                        socials.append(self.linkedinLink)
                        self.db.collection("Rooms").document(self.roomName).setData([uid: socials], merge: true)
                        
                        
                        self.setSocialMedia(media: "linkedin")
                        self.socialMediaSent[3] = 1
                        
                    }
                }
            }
            
        }
     
    }
    @IBAction func sendSnapchat(_ sender: Any) {
        if(snapchatLink == ""){
            return
        }
        if (self.socialMediaSent[4] == 1 ){
            self.setSocialMedia(media: "Snapchat")
        }
        let uid = Auth.auth().currentUser?.uid ?? ""
        db.collection("Rooms").document(roomName).getDocument() {(document, error ) in
            if error == nil {
                if let document = document, document.exists {
                    var socials = document.get(uid) as? [String] ?? []
                    if socials.contains(self.snapchatLink) == false {
                        socials.append(self.snapchatLink)
                    self.db.collection("Rooms").document(self.roomName).setData([uid: socials], merge: true)
                        
                        self.setSocialMedia(media: "snapchat")
                        self.socialMediaSent[4] = 1
                        
                    }
                }
            }
            
        }
     
    }
    
    // Inbox for reieveing the other's user's social media. Press to open. Press again to close.
    @IBAction func openInbox(_ sender: Any) {
        
        if(inboxToggle == 1){
            socalMediaPopUp.isHidden = true
            urlView.isHidden = false
            inboxToggle = 2
            mediaInbox.setImage(UIImage(named:"inbox"), for: .normal)
        }else{
            urlView.isHidden = true
            inboxToggle = 1
        }
        
    }
    
    // Used for appending the other user's soical media links to the inbox
    func addLinkToView(url: String) {
        if (urlView.isHidden == true){
            mediaInbox.setImage(UIImage(named: "inbox message"), for: .normal)
        }
        var messageText = ""
        
        if url.contains("instagram") {
            messageText = "Follow Instagram"
            
        }
        else if url.contains("snapchat") {
            messageText =  "Add Snapchat"
            
            
        } else if url.contains("twitter") {
            messageText = "Follow Twitter"
            
        }
        else if url.contains("facebook") {
            messageText = "Add Facebook"
        }
        else {
            messageText = "Connect LinkedIn"
        }
        let socialUrl = URL(string: url)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attributedString = NSMutableAttributedString(string: messageText, attributes: [.paragraphStyle: paragraph])
        let range = NSMakeRange(0, attributedString.length)
        attributedString.setAttributes([.link: socialUrl ?? ""], range: range)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: NSMakeRange(0, attributedString.length))
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: 250, height: 50))
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18.0), range: range)
        textView.attributedText = attributedString
        textView.center = CGPoint(x: 240, y: self.y)
        let linkAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 0.69, green: 0.63, blue: 1.0, alpha: 1.0)]
        textView.linkTextAttributes = linkAttributes
        self.y += 25
        textView.backgroundColor = UIColor.clear
        textView.attributedText = attributedString
        self.urlView.addSubview(textView)
        self.urlView.isUserInteractionEnabled = true
        textView.isEditable = false
    }
    
    
    
   // Called every second to update timer to firestore room's timer, check for ice breakers questsions, and if the other user has exited the room.
    @objc func updateTimer(){
        db.collection("Rooms").document(roomName).getDocument(){ [self]
            (document, error) in
            if(error == nil){
                if let document = document, document.exists {
                    if document.get("Timer") != nil{
                        let time = document.get("Timer")
                        let curTime = Int(time as? String ?? "1000" ) ?? 1000
                        self.timerLabel.text = "Timer: " + String(curTime/60) + ":" + String(format: "%02d",curTime % 60)
                        if(curTime == 0){
                            exitRoom()
                        }
                    }
                    if document.get("Icebreaker") != nil{
                        let question = document.get("Icebreaker") as? String
                        messageLabel.isHidden = false
                        messageLabel.text = question  ?? "Error" + "\n"
                        
                    }
                    if document.get("Exited") != nil {
                        self.db.collection("Rooms").document(roomName).delete(){ err in
                            if let err = err {
                                print("Error removing document: \(err)")
                            } else {
                                print("Document successfully removed!")
                            }
                        }
                        exitRoom()
                    }
                }
            }
        }
        if questionTime == 10{
            db.collection("Rooms").document(roomName).updateData(["Icebreaker": FieldValue.delete()]){ err in
                if let err = err {
                    print("Error updating document: \(err)")
                }
            }
            messageLabel.isHidden = true
            questionTime = 0
        }
        questionTime += 1
        
    }
    
    // called every 0.02 second to check if the other user send social media links
    @objc func checkForSentSocials() {
        db.collection("Rooms").document(roomName).getDocument() { [self]
            (document, error) in
            if(error == nil){
                if let document = document, document.exists {
                    let links = document.get(self.matchId) as? [String] ?? []
                    if links.count > self.sentSocialsCount {
                        self.sentSocialsCount += 1
                        
                        self.addLinkToView(url: links[links.count-1])
                        
                    }
            
                }
            }
        }
        
    }
    
   
    // Used for updating the firestore's room timer to add time to the meeting
    @IBAction func addTime(_ sender: Any) {
        db.collection("Rooms").document(roomName).getDocument(){
            (document, error) in
            if(error == nil){
                if let document = document, document.exists {
                    if document.get("Timer") != nil{
                        let time = document.get("Timer")
                        var curTime = Int(time as? String ?? "1000" ) ?? 1000
                        curTime = curTime + 60
                        self.db.collection("Rooms").document(self.roomName).setData(["Timer":String(curTime)], merge: true)
                    }
                }
            }
        }
    }

    
    // Change isOnCall to false
    func setIsOnCall() {
        self.db.collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument{(document, error) in
            if let document = document, document.exists {
                document.reference.updateData([
                    "isOnCall": "false"
                ])
            }
        }
    }
    // Add current match to previous mathces
    func addMatchToPrevMatches() {
        self.db.collection("users").document(Auth.auth().currentUser?.uid ?? "").collection("matches").document("previous matches").getDocument {(document, error)  in
            if let document = document, document.exists {
                var prev_matches = document.get("prev_matches") as? [String] ?? []
                prev_matches.append(self.matchId)
                self.db.collection("users").document(Auth.auth().currentUser?.uid ?? "").collection("matches").document("previous matches").setData(["prev_matches": prev_matches])
            }
        }
    }
    
    // If the user decides to press end call, set exited to 1 for the firestore room's database so the other user would know to exit too
    @IBAction func disconnect(sender: AnyObject) {
        self.db.collection("Rooms").document(self.roomName).setData(["Exited":"1"], merge: true)
        exitRoom()
    }
   
    // Disconnect form room and delete firestore room's info
    func exitRoom(){
        checkSentSocialsTimer?.invalidate()
        checkUpdates?.invalidate()
        self.room?.disconnect()
        /*Add user to previous matches */
        self.addMatchToPrevMatches()
        
        /*Delete fields of current match for myself*/
        self.db.collection("users").document(Auth.auth().currentUser?.uid ?? "").collection("matches").document("current match").delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        /* set is on call to false*/
        self.setIsOnCall()
        let roomDict:[String: String] = ["room": roomName]
        NotificationCenter.default.post(name: Notification.Name("didStopTimer"), object : nil, userInfo: roomDict)
        logMessage(messageText: "Attempting to disconnect from room \(String(describing: room?.name))")
        goBackToLobby()
    }
    
    func goBackToLobby(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let lobbyViewController = storyboard.instantiateViewController(identifier: "lobbyVC") as? LobbyViewController else {
            assertionFailure("couldn't find vc")
            return }
        //optional navigation controller
        navigationController?.pushViewController(lobbyViewController, animated: true)
    }
    
    // Turn on and off mic
    @IBAction func toggleMic(sender: AnyObject) {
        let micOn = UIImage(named:"Microphone Icon")
        let micOff = UIImage(named: "mute Microphone Icon")
        if (self.localAudioTrack != nil) {
            self.localAudioTrack?.isEnabled = !(self.localAudioTrack?.isEnabled ?? false)
            if(toggleMicState == 1){
                micImage.setImage(micOff, for: .normal)
                toggleMicState = 2
            }else{
                micImage.setImage(micOn, for: .normal)
                toggleMicState = 1
            }
        }
    }
    
    // Turn on and off video camera
    @IBAction func toggleVid(_ sender: Any) {
        let vidOn = UIImage(named:"Video Icon")
        let vidOff = UIImage(named: "Close View Icon")
        if (self.localVideoTrack != nil) {
            self.localVideoTrack?.isEnabled = !(self.localVideoTrack?.isEnabled ?? false)
            if(toggleVidState == 1){
                vidImage.setImage(vidOff, for: .normal)
                toggleVidState = 2
            }else{
                vidImage.setImage(vidOn, for: .normal)
                toggleVidState = 1
            }
        }
    }
    
    // Set up View for the video
    func setupRemoteVideoView() {
        // Creating `VideoView` programmatically
        self.remoteView = VideoView(frame: CGRect.zero, delegate: self)

        self.view.insertSubview(self.remoteView, at: 0)
        
        // `VideoView` supports scaleToFill, scaleAspectFill and scaleAspectFit
        // scaleAspectFit is the default mode when you create `VideoView` programmatically.
        self.remoteView.contentMode = .scaleAspectFill;

        let centerX = NSLayoutConstraint(item: self.remoteView as Any,
                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: self.view,
                                         attribute: NSLayoutConstraint.Attribute.centerX,
                                         multiplier: 1,
                                         constant: 0);
        self.view.addConstraint(centerX)
        let centerY = NSLayoutConstraint(item: self.remoteView as Any,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         relatedBy: NSLayoutConstraint.Relation.equal,
                                         toItem: self.view,
                                         attribute: NSLayoutConstraint.Attribute.centerY,
                                         multiplier: 1,
                                         constant: 0);
        self.view.addConstraint(centerY)
        let width = NSLayoutConstraint(item: self.remoteView as Any,
                                       attribute: NSLayoutConstraint.Attribute.width,
                                       relatedBy: NSLayoutConstraint.Relation.equal,
                                       toItem: self.view,
                                       attribute: NSLayoutConstraint.Attribute.width,
                                       multiplier: 1,
                                       constant: 0);
        self.view.addConstraint(width)
        let height = NSLayoutConstraint(item: self.remoteView as Any,
                                        attribute: NSLayoutConstraint.Attribute.height,
                                        relatedBy: NSLayoutConstraint.Relation.equal,
                                        toItem: self.view,
                                        attribute: NSLayoutConstraint.Attribute.height,
                                        multiplier: 1,
                                        constant: 0);
        self.view.addConstraint(height)
    }
    
    func connect(){
        // Configure access token either from server or manually.
        // If the default wasn't changed, try fetching from server.
        // Preparing the connect options with the access token that we fetched (or hardcoded).
        let connectOptions = ConnectOptions(token: accessToken) { (builder) in
            builder.roomName = self.roomName
            // Use the local media that we prepared earlier.
            if let audioTrack = self.localAudioTrack{
                builder.audioTracks = [audioTrack]
            }
            if let videoTrack = self.localVideoTrack{
                builder.videoTracks = [videoTrack]
            }
        }
        // Connect to the Room using the options we provided.
        room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
        logMessage(messageText: "Attempting to connect to room")
    }
    
    func prepareLocalMedia() {
        // We will share local audio and video when we connect to the Room.
        // Create an audio track.
        if (localAudioTrack == nil) {
            localAudioTrack = LocalAudioTrack(options: nil, enabled: true, name: "Microphone")

            if (localAudioTrack == nil) {
                logMessage(messageText: "Failed to create audio track")
            }
        }
        // Create an video track.
        guard let frontCamera = CameraSource.captureDevice(position: .front) else{
            self.logMessage(messageText:"No front capture device found!")
            return
        }
        
        let options = CameraSourceOptions { (builder) in
        }
        guard let camera = CameraSource(options: options, delegate: self) else{
            self.logMessage(messageText:"No front capture device found!")
            return
        }
        
        localVideoTrack = LocalVideoTrack(source: camera, enabled: true, name: "Camera")
        localVideoTrack?.addRenderer(self.myView)
        // Add renderer to video track for local preview
        logMessage(messageText: "Video track created")
        camera.startCapture(device: frontCamera) { (captureDevice, videoFormat, error) in
            if let error = error {
                self.logMessage(messageText: "Capture failed with error.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
            }
        }
        
   }
    
    
/* Code below are taken from Twilio video quickstart ios inorder to make twilio video api function properly*/
///https://github.com/twilio/video-quickstart-ios
    
    func logMessage(messageText: String) {
        NSLog(messageText)
        messageLabel.text = messageText
    }
    func renderRemoteParticipant(participant : RemoteParticipant) -> Bool {
        // This example renders the first subscribed RemoteVideoTrack from the RemoteParticipant.
        let videoPublications = participant.remoteVideoTracks
        for publication in videoPublications {
            if let subscribedVideoTrack = publication.remoteTrack,
                publication.isTrackSubscribed {
                setupRemoteVideoView()
                subscribedVideoTrack.addRenderer(self.remoteView)
                self.remoteParticipant = participant
                return true
            }
        }
        return false
    }

    func renderRemoteParticipants(participants : Array<RemoteParticipant>) {
        for participant in participants {
            // Find the first renderable track.
            if participant.remoteVideoTracks.count > 0,
                renderRemoteParticipant(participant: participant) {
                break
            }
        }
    }

    func cleanupRemoteParticipant() {
        if self.remoteParticipant != nil {
            self.remoteView?.removeFromSuperview()
            self.remoteView = nil
            self.remoteParticipant = nil
        }
    }
}



// MARK:- RoomDelegate
extension MeetingViewController: RoomDelegate {
    func roomDidConnect(room: Room) {
        logMessage(messageText: "Connected to room \(room.name) as \(room.localParticipant?.identity ?? "")")
        // This example only renders 1 RemoteVideoTrack at a time. Listen for all events to decide which track to render.
        for remoteParticipant in room.remoteParticipants {
            remoteParticipant.delegate = self
            // This would create another timer model class, which would not synconize with the other timer model
            // We need to create a timer API so both devices would be accessing the same timer model API
            
        }
    }

    func roomDidDisconnect(room: Room, error: Error?) {
        logMessage(messageText: "Disconnected from room \(room.name), error = \(String(describing: error))")
        self.cleanupRemoteParticipant()
        self.room = nil
    }

    func roomDidFailToConnect(room: Room, error: Error) {
        logMessage(messageText: "Failed to connect to room with error = \(String(describing: error))")
        self.room = nil
    }

    func roomIsReconnecting(room: Room, error: Error) {
        logMessage(messageText: "Reconnecting to room \(room.name), error = \(String(describing: error))")
    }

    func roomDidReconnect(room: Room) {
        logMessage(messageText: "Reconnected to room \(room.name)")
    }
   
    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        // Listen for events from all Participants to decide which RemoteVideoTrack to render.
        participant.delegate = self
        
        logMessage(messageText: "Participant \(participant.identity) connected with \(participant.remoteAudioTracks.count) audio and \(participant.remoteVideoTracks.count) video tracks")
        db.collection("PopRoom").document("Timer").setData(["Time":"300"])
        
        
    }

    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        
        logMessage(messageText: "Room \(room.name), Participant \(participant.identity) disconnected")
        db.collection("Rooms").document(roomName).getDocument(){
            (document, error) in
            if(error == nil){
                if let document = document, document.exists {
                }else{
                    self.checkUpdates?.invalidate()
                    self.checkSentSocialsTimer?.invalidate()
                    self.goBackToLobby()
                }
            }
        }

        // Nothing to do in this example. Subscription events are used to add/remove renderers.
    }
}
// MARK:- RemoteParticipantDelegate
extension MeetingViewController : RemoteParticipantDelegate {

    func remoteParticipantDidPublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        // Remote Participant has offered to share the video Track.
        
        logMessage(messageText: "Participant \(participant.identity) published \(publication.trackName) video track")
    }

    func remoteParticipantDidUnpublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        // Remote Participant has stopped sharing the video Track.

        logMessage(messageText: "Participant \(participant.identity) unpublished \(publication.trackName) video track")
    }

    func remoteParticipantDidPublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        // Remote Participant has offered to share the audio Track.

        logMessage(messageText: "Participant \(participant.identity) published \(publication.trackName) audio track")
    }

    func remoteParticipantDidUnpublishAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        // Remote Participant has stopped sharing the audio Track.
 
        logMessage(messageText: "Participant \(participant.identity) unpublished \(publication.trackName) audio track")
    }

    func didSubscribeToVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        // The LocalParticipant is subscribed to the RemoteParticipant's video Track. Frames will begin to arrive now.

        logMessage(messageText: "Subscribed to \(publication.trackName) video track for Participant \(participant.identity)")
        
        if (self.remoteParticipant == nil) {
            renderRemoteParticipant(participant: participant)
        }
    }
    
    func didUnsubscribeFromVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        // We are unsubscribed from the remote Participant's video Track. We will no longer receive the
        // remote Participant's video.
        logMessage(messageText: "Unsubscribed from \(publication.trackName) video track for Participant \(participant.identity)")

        if self.remoteParticipant == participant {
            cleanupRemoteParticipant()

            // Find another Participant video to render, if possible.
            if var remainingParticipants = room?.remoteParticipants,
               let index = remainingParticipants.firstIndex(of: participant) {
                remainingParticipants.remove(at: index)
                renderRemoteParticipants(participants: remainingParticipants)
                
            }
        }
    }

    func didSubscribeToAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
        // We are subscribed to the remote Participant's audio Track. We will start receiving the
        // remote Participant's audio now.
       
        logMessage(messageText: "Subscribed to \(publication.trackName) audio track for Participant \(participant.identity)")
    }
    
    func didUnsubscribeFromAudioTrack(audioTrack: RemoteAudioTrack, publication: RemoteAudioTrackPublication, participant: RemoteParticipant) {
        // We are unsubscribed from the remote Participant's audio Track. We will no longer receive the
        // remote Participant's audio.
        
        logMessage(messageText: "Unsubscribed from \(publication.trackName) audio track for Participant \(participant.identity)")
    }

    func remoteParticipantDidEnableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) enabled \(publication.trackName) video track")
    }

    func remoteParticipantDidDisableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) disabled \(publication.trackName) video track")
    }

    func remoteParticipantDidEnableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) enabled \(publication.trackName) audio track")
    }

    func remoteParticipantDidDisableAudioTrack(participant: RemoteParticipant, publication: RemoteAudioTrackPublication) {
        logMessage(messageText: "Participant \(participant.identity) disabled \(publication.trackName) audio track")
    }

    func didFailToSubscribeToAudioTrack(publication: RemoteAudioTrackPublication, error: Error, participant: RemoteParticipant) {
        logMessage(messageText: "FailedToSubscribe \(publication.trackName) audio track, error = \(String(describing: error))")
    }

    func didFailToSubscribeToVideoTrack(publication: RemoteVideoTrackPublication, error: Error, participant: RemoteParticipant) {
        logMessage(messageText: "FailedToSubscribe \(publication.trackName) video track, error = \(String(describing: error))")
    }
}

// MARK:- VideoViewDelegate
extension MeetingViewController : VideoViewDelegate {
    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
        self.view.setNeedsLayout()
    }
}

// MARK:- CameraSourceDelegate
extension MeetingViewController : CameraSourceDelegate {
    func cameraSourceDidFail(source: CameraSource, error: Error) {
        logMessage(messageText: "Camera source failed with error: \(error.localizedDescription)")
    }
}



