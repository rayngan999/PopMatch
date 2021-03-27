# PopMatch Documentation
## [The Big Bang Theory]! 
### Members:
<img src="https://user-images.githubusercontent.com/52867931/110847792-33a83680-8262-11eb-88da-df669f99d09b.png" width="40"> Eden Avivi, eavivi4 (sometimes just Eden) <br />
<img src="https://user-images.githubusercontent.com/52867931/110847792-33a83680-8262-11eb-88da-df669f99d09b.png" width="40"> Gharam Alsaedi, gharams19 <br />
<img src="https://user-images.githubusercontent.com/52867931/110847792-33a83680-8262-11eb-88da-df669f99d09b.png" width="40"> Wai Hei Ngan (Ray), rayngan999 <br />
<img src="https://user-images.githubusercontent.com/52867931/110847792-33a83680-8262-11eb-88da-df669f99d09b.png" width="40">  Ma Eint Poe, maeintpoe

## Description
<img src="https://user-images.githubusercontent.com/52867931/110848697-3ce5d300-8263-11eb-90bb-ad46beca2aee.png" width="100">  is a video chatting app that allows users to have 1 on 1 meetings with new people and like minded thinkers. It's a way to create social bonds and network for university students. Our app aims to mitigate the lack of social interaction as a result of the pandemic and having everything go virtual. With PopMatch, users are able to create a profile with a short personalized interest form. Based on the availablity of current users online, they will get match with someone they have the most in common with. Once they both accept the match, they can have an extendable 5 minute video chat filled with fun ice-breaker questions to keep the conversation going. If they want to extend this further, they can also exchange social medias with a press of a button that leads right them to the other's social media profile. PopMatch combines the well-liked features of being able to meet new people like Omelge while giving them the choice in who they actually talk to similarly to Tinder, but with a touch of personalized mutual interest matching.

## Installation Instruction & Other Notes
* Some cocopoads are used, so before compiling the app on xcode, the command "pod install" is needed in the PopMatch folder.
* Facebook's login SDK requires users to be added into the app with a role while the app is in development mode, so if you try to connect your facebook you'll be prompted with an error since we have not added whomever is testing this (Prof/TA).

## App Flow: 
<img src="https://user-images.githubusercontent.com/52867931/110840687-e1fbae00-8259-11eb-85f6-440a69328f29.png" width="160"> <img src="https://user-images.githubusercontent.com/52867931/110840692-e2944480-8259-11eb-925c-eeae40b31ba6.png" width="160"> <img src="https://user-images.githubusercontent.com/52867931/110840683-e0ca8100-8259-11eb-8381-8fa2d3fea11a.png" width="160"> <img src="https://user-images.githubusercontent.com/52867931/110840690-e1fbae00-8259-11eb-8571-90b34eb878a5.png" width="160"> <img src="https://user-images.githubusercontent.com/52867931/110840685-e1631780-8259-11eb-9c1e-0f0ed8ba0478.png" width="160"> 

<img src="https://user-images.githubusercontent.com/52867931/110841422-b5946180-825a-11eb-8180-85db360b120c.png" width="160"> <img src="https://user-images.githubusercontent.com/52867931/110841425-b62cf800-825a-11eb-987d-c128861826b1.png" width="160"> <img src="https://user-images.githubusercontent.com/52867931/110841426-b62cf800-825a-11eb-884e-51b2d01b7b19.png" width="160"> <img src="https://i.ibb.co/qk3xGPj/Simulator-Screen-Shot-i-Phone-12-Pro-Max-2021-03-14-at-17-19-42.png" width="160">


## Roles & Contribution:
* Eden Avivi
  * Implemented logInVC and signUpVC, including the show and hide buttons, setting up the reset email format and adding in the Firebase Auth API.
  * Implemented the LobbyVC's animations, the transition between the LobbyVC to MatchingVC and the sound between the two.
  * Worked on getting the links to social medias from the user's username and hiding it when they press it again.
* Gharam Alsaedi
  * Designed the UI, specifically designed the pages including the buttons' icons and logo. As well as the overall flow of the app.
  * Set up presence system (Online/Offline) using firebase's Realtime database.
  * Created matching algorithm which finds the most ideal match by filtering out users that are either unavailable or offline and then match the current user with the person they have most in common with. Also worked on the accept/reject a match algorithm.
  * Worked on sending and receiving social media links in the video chat.

* Wai Hei Ngan (Ray)
  * Created MeetingViewController for video chatting
  * Implemented Twilio Video API for the video chat
  * Created Twilio video user authentication tokens generation flow
  * Added timer model to video room using firebase's Realtime database
  * Implemented basic video functionalities (Such as add time, turn on/off camera, turn on/off mic, inbox, and end call)
  * Added Icebreaker quiestions for the video room
  * Improved sending and receiving social media user experince for the video chat
  * Created accept/reject flow logic in MatchingViewController with firebase's Realtime database
  * Created PreMeetingViewController to act as waiting room 

* Ma Eint Poe
  * Wireframed a prototype for overall flow of the app using Figma
  * Compiled a list of questions for questionnaire
  * Implemented the Profile VC and the Friendship VC by allowing users to edit their profile picture along with answers to questionnaire & account info and storing them to the Firebase's Firestore & retriving when needed
  * Linked the external connection to Facebook login 

## ViewController Detailed Descriptions
### Login VC & Sign Up VC
Here, returning users can login again if they have previously logged out. This will lead them to the profile view controller upon successful login. For the first time users, they can start by signing up and starting their PopMatch profile. This will lead them to the friend view controller.

### Friend VC 
For the first time users, here is where they will be first navigated to so that they can fill out a questionnaire regarding their basic demographic and some interests which will used in our algorithm. However, if you are a returning user, you can always revisit here from the profile view controller and make changes your selections.

### Profile VC
This is like the home page where users are redirected upon login and is the source of navigation to the others such as joining the lobby for a match, signing out, or the personal interest questionnaire. Here, users can make changes regarding their account info and profile picture.

### Lobby VC
Here is where the users will be waiting to get a match with other currently online users. They'll be shown a loading bubble animation while our matching algorithm runs in the background. Once a match has been found, a larger bubble will be displayed on the screen.

### Matching and Pre-Meeting VC
With a match found, this is where the users will be shown the profile of their match along the options to accept or reject the call and a countdown timer for them to make their choice. They can also press on bubble with the matched user's profile picture to view a more detailed description with their selections from the questionnaire. Upon an acceptance, the user will be directed to the loading pre-meeting view controller to wait while the matched user makes their choice to accept or not.

### Meeting VC
Here lies the core of our app - the video chatting. After both the matched users accept, this is where they can begin to chat and (hopefully) be the start of a new friendship :) They can discuss some fun and debatable ice-breaker questions to get a conversation going, and even extend the call time to keep chatting. This is also where can take this conversation a step furthur and share social medias with each other now that they've made a new friend.

## Progress 
Trello Board: https://trello.com/b/Ctr0GQnf/ecs-189e-project

## Come join PopMatch and pop some bubbles!

<img src="https://user-images.githubusercontent.com/52867931/110848697-3ce5d300-8263-11eb-90bb-ad46beca2aee.png" width="200"> 

_______________________________________________________________________________________________________________________________________________________

# Milestone 1 Documentation

### Pop Match
A video chatting app that allows users to have 1 on 1 meetings with new people and like minded thinkers. A way to create soical bonds or networks for university students.

### Installation instructions

- Some cocopoads are used, so before compiling the app on xcode, the command "pod install" is needed in the PopMatch folder.

### Designs for all screens to be used
[Figma Wireframe](https://www.figma.com/file/C1nZuKT19fLt7fyb8CQKS2/The-Big-Bang-Theory?node-id=0%3A1)

### List of third party libraries and server support
- Firebase
- Twilio
- DLRadioButtons

Since we are using Firebase for our data storage and authentication of emails and passwords, and Twilio for the video aspect, we have not found an Api component needed to be implmeneted for now.

### List of all view controllers
* Splash Screen
* Login 
* Sign up 
* Profile 
* Setting
* Friend Questionnaire 
* Lobby (loading screen)
* Match 
* Waiting room
* Video

Navigation between the VC: [Figma Wireframe](https://www.figma.com/proto/C1nZuKT19fLt7fyb8CQKS2/%5BThe-Big-Bang-Theory%5D!?node-id=17%3A25&scaling=scale-down)

Protocols for UserDelegate: (will keep updating)

`userDataChanged()` : To handle the changes to the user data such as name, social media, etc.

`displayMatch()` : To handle the matching between different users

`callStatusChange()` : To handle the the starting, extending, and ending of video calls


Delegates: (will keep updating)
* UITextFieldDelegate 
* UITableViewDelegate
* UserDelegate 
* UIImagePickerControllerDelegate
* UINavigationControllerDelegate



### List of models

- Timer Model
- Video Model
- User Model

### List of week long tasks

https://github.com/ECS189E/project-w21-big-bang-theory/blob/master/Week_Long_Tasks.md

### Trello board link
https://trello.com/b/Ctr0GQnf/ecs-189e-project

### Group member names, usernames and photos:
Eden Avivi, eavivi4 (sometimes just Eden)
<br/>
<img src="https://github.com/ECS189E/project-w21-big-bang-theory/blob/Eden/Images/EdenPic.jpg"  width="300"/>

Gharam Alsaedi, gharams19
<br/>
<img src="https://github.com/ECS189E/project-w21-big-bang-theory/blob/Eden/Images/GharamPic.jpg"  width="300"/>

Wai Hei Ngan, rayngan999 
<br/>
<img src="https://github.com/ECS189E/project-w21-big-bang-theory/blob/Eden/Images/RayPic.jpeg"  width="300"/>

Ma Eint Poe, maeintpoe
<br/>
<img src="https://github.com/ECS189E/project-w21-big-bang-theory/blob/Eden/Images/MaEintPoe.png"  width="300"/>

### Testing Plan
<https://github.com/ECS189E/project-w21-big-bang-theory/blob/Eden/Testing_Plan.md>
