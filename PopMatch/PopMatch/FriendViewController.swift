//
//  FriendViewController.swift
//  PopMatch
//
//  Created by Ma Eint Poe on 2/18/21.
//

import UIKit
import Firebase
import DLRadioButton

class FriendViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate,
                            UIPickerViewDataSource {
   
    
    // Variables Here
    @IBOutlet weak var pronounTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var majorTextField: UITextField!

    // Hobby Buttons
    @IBOutlet weak var travelingBtn: DLRadioButton!
    @IBOutlet weak var workingOutBtn: DLRadioButton!
    @IBOutlet weak var hikingBtn: DLRadioButton!
    @IBOutlet weak var cookingBtn: DLRadioButton!
    @IBOutlet weak var readingBtn: DLRadioButton!
    @IBOutlet weak var craftingBtn: DLRadioButton!
    @IBOutlet weak var hobbyMusicBtn: DLRadioButton!
    @IBOutlet weak var videoGamesBtn: DLRadioButton!
    @IBOutlet weak var photographyBtn: DLRadioButton!
    @IBOutlet weak var netflixBtn: DLRadioButton!
    @IBOutlet weak var hobbyOtherBtn: DLRadioButton!
    @IBOutlet weak var dontKnowBtn: DLRadioButton!
    var hobbies: [DLRadioButton] = []
    
    // Music Genres
    @IBOutlet weak var popBtn: DLRadioButton!
    @IBOutlet weak var edmBtn: DLRadioButton!
    @IBOutlet weak var hiphopBtn: DLRadioButton!
    @IBOutlet weak var rapBtn: DLRadioButton!
    @IBOutlet weak var rockBtn: DLRadioButton!
    @IBOutlet weak var rnbBtn: DLRadioButton!
    @IBOutlet weak var countryBtn: DLRadioButton!
    @IBOutlet weak var indieBtn: DLRadioButton!
    @IBOutlet weak var classicalBtn: DLRadioButton!
    @IBOutlet weak var kpopBtn: DLRadioButton!
    @IBOutlet weak var musicOtherBtn: DLRadioButton!
    @IBOutlet weak var musicNABtn: DLRadioButton!
    var musicGenres: [DLRadioButton] = []
    
    // Tv Show Genres
    @IBOutlet weak var actionBtn: DLRadioButton!
    @IBOutlet weak var comedyBtn: DLRadioButton!
    @IBOutlet weak var dramaBtn: DLRadioButton!
    @IBOutlet weak var documentaryBtn: DLRadioButton!
    @IBOutlet weak var romanceBtn: DLRadioButton!
    @IBOutlet weak var fantasyBtn: DLRadioButton!
    @IBOutlet weak var horrorBtn: DLRadioButton!
    @IBOutlet weak var tvOtherBtn: DLRadioButton!
    var tvGenres: [DLRadioButton] = []
    
    // Diet Options
    @IBOutlet weak var veganBtn: DLRadioButton!
    @IBOutlet weak var vegetarianBtn: DLRadioButton!
    @IBOutlet weak var dietNABtn: DLRadioButton!
    var dietBtns: [DLRadioButton] = []
    
    @IBOutlet weak var doneBtn: UIButton!
    
    var db = Firestore.firestore()
    
    // Picker Data
    var pronounData: [String] = ["She/Her", "He/Him", "They/Them", "Decline to state"]
    var ageData: [String] = ["Freshman", "Sophomore", "Junior", "Senior", "Super Senior"]
    var majorData: [String] = ["Business/Economics", "Technology", "Healthcare", "Education", "Engineering", "Agriculture", "Legal/Politcal Science", "Entertainment/Media", "Art", "Languages/Literature", "Research"]
  
    let pronounPicker = UIPickerView()
    let agePicker = UIPickerView()
    let majorPicker = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneBtn.layer.cornerRadius = 15
        
        // Set the arrays for different components - just to avoid rewriting reptitive code
        hobbies = [travelingBtn, workingOutBtn, hikingBtn, cookingBtn, readingBtn, craftingBtn, hobbyMusicBtn, videoGamesBtn, photographyBtn, netflixBtn, hobbyOtherBtn, dontKnowBtn]
        musicGenres = [popBtn, edmBtn, hiphopBtn, rapBtn, rockBtn, rnbBtn, countryBtn, indieBtn, classicalBtn, kpopBtn, musicOtherBtn, musicNABtn]
        tvGenres = [actionBtn, comedyBtn, dramaBtn, documentaryBtn, romanceBtn, fantasyBtn, horrorBtn, tvOtherBtn]
        dietBtns = [veganBtn, vegetarianBtn, dietNABtn]
        
        // Set the checkbox settings to allow more than one choice
        hobbies = hobbies.map({$0.isMultipleSelectionEnabled = true; return $0 })
        musicGenres = musicGenres.map({$0.isMultipleSelectionEnabled = true; return $0})
        tvGenres = tvGenres.map({$0.isMultipleSelectionEnabled = true; return $0})
        
        // Set delegates & data sources for the differnt pickers
        pronounTextField.delegate = self
        pronounPicker.delegate = self
        pronounTextField.inputView = pronounPicker
        pronounPicker.dataSource = pronounData as? UIPickerViewDataSource
        
        ageTextField.delegate = self
        agePicker.delegate = self
        ageTextField.inputView = agePicker
        agePicker.dataSource = ageData as? UIPickerViewDataSource
        
        majorTextField.delegate = self
        majorPicker.delegate = self
        majorTextField.inputView = majorPicker
        majorPicker.dataSource = majorData as? UIPickerViewDataSource
        
        // Start by display the currently stored user data
        displayData()
    }
    
    // MARK: - Display stored data
    func displayData() {
        
        // Get the current user's data from Firestore
        let userData = db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
        let userQuestions = userData.collection("questions").document("friendship")
        userQuestions.getDocument { (document, error) in
            if error == nil {
                if let document = document, document.exists {
                    let docData = document.data()
                    
                    // Set user's data from Firestore to current VC values
                    self.pronounTextField.text = docData?["pronoun"] as? String ?? ""
                    self.ageTextField.text = docData?["ageGroup"] as? String ?? ""
                    self.majorTextField.text = docData?["major"] as? String ?? ""
                   
                    if let hobbies = docData?["hobbies"] as? [String] {
                        // Iterate through saved hobbies to mark each chosen checkbox(es)
                        for hobby in hobbies {
                            self.hobbies = self.hobbies.map({
                                if($0.titleLabel?.text == hobby) { $0.isSelected = true }
                                return $0
                            })
                        }
                    }
                  
                    if let music = docData?["music"] as? [String] {
                        // Iterate through saved music to mark each chosen checkbox(es)
                            for genre in music {
                                self.musicGenres = self.musicGenres.map({
                                    if ($0.titleLabel?.text == genre) {$0.isSelected = true}
                                    return $0
                                })
                            }
                    }
                    
                    if let tvShows = docData?["tvShows"] as? [String] {
                        // Iterate through saved tvShows to mark each chosen checkbox(es)
                        for genre in tvShows {
                            self.tvGenres = self.tvGenres.map({
                                if ($0.titleLabel?.text == genre) {$0.isSelected = true}
                                return $0
                            })
                        }
                    }
                    
                    if let dietChoice = docData?["diet"] as? String {
                        // Mark the choicen diet options between the radio button group
                       self.dietBtns = self.dietBtns.map({
                            if (dietChoice == $0.titleLabel?.text) {$0.isSelected = true}
                            return $0
                        })
                    }
                    
                } else {
                    // Error check for document
                    print("User document doesn't exists")
                }
            } else {
                // Error check for that user
                print ("Error in user document, error: \(String(describing: error))")
            }
        }
    }
    

    // MARK: - Picker Delegate Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        // Provide the corresponding number of selection for each picker
        switch pickerView {
        case pronounPicker:
            return pronounData.count
        case agePicker:
            return ageData.count
        default:
            return majorData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        // Display the corresponding info based on the picker
        switch pickerView {
        case pronounPicker:
            return pronounData[row]
        case agePicker:
            return ageData[row]
        default:
            return majorData[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // Show the corresponding data set for each of the picker selections
        switch pickerView{
        case pronounPicker:
            pronounTextField.text = pronounData[row]
            pronounTextField.resignFirstResponder()
        case agePicker:
            ageTextField.text = ageData[row]
            ageTextField.resignFirstResponder()
        default:
            majorTextField.text = majorData[row]
            majorTextField.resignFirstResponder()
        }
        
        // Hide picker
        self.view.endEditing(true)
    }
    
    // MARK: - Retrieve selection & save to db
    // Get the selected choices from the checkboxes
    func getSelection(_ selections: DLRadioButton) -> [String] {
        var selectedArray: [String] = []
        if(selections.isMultipleSelectionEnabled) {
            for chosen in selections.selectedButtons() {
                selectedArray.append(chosen.titleLabel?.text ?? "")
            }
        }
        return selectedArray
    }
    
    
    func sendToDatabase() {
        // Get the user's selection that need to be stored
        let pronoun = pronounTextField.text ?? ""
        let age = ageTextField.text ?? ""
        let major = majorTextField.text ?? ""
        let hobbies = getSelection(travelingBtn)
        let music = getSelection(popBtn)
        let tvShows = getSelection(actionBtn)
        let diet = veganBtn.selected()?.titleLabel?.text ?? ""
        
        //
        let userDoc = db.collection("users").document(Auth.auth().currentUser?.uid ?? "")
        let friendshipDoc = userDoc.collection("questions").document("friendship")
        
        // Store to that user's collection using the obtained values
        friendshipDoc.setData([
            "pronoun" : pronoun,
            "ageGroup" : age,
            "major" : major,
            "hobbies" : hobbies,
            "music" : music,
            "tvShows" : tvShows,
            "diet" : diet
        ])
    }
    
    // MARK: - Navigation
    
    @IBAction func toProfile() {
        // Pop off the friend VC that was pushed from profile
        sendToDatabase()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let profileViewController = storyboard.instantiateViewController(withIdentifier: "profileVC") as? ProfileViewController else {
                assertionFailure("couldn't find vc") //will stop program
                return
            }
        //optional navigation controller
        self.navigationController?.pushViewController(profileViewController, animated: true)
    }
    
}
