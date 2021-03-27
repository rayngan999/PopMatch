# Sprint Planning 2

### Project Summary:
An app that uses an unique queue matching system to allow users to have 1 on 1 video chats with other people. A way to create social bonds or networking in a community, specifically in Universities. 

### Trello Link:
https://trello.com/b/Ctr0GQnf/ecs-189e-project

### What was done with commit links and descriptions:

**Eden Avivi** -

Testing plan for milestone 1 https://github.com/ECS189E/project-w21-big-bang-theory/blob/Eden/Testing_Plan.md
Started working on log in and sign up screens by creating the xcode project, applying constraints on view controllers to fit smaller phones, verification of several coditions such as all text fields full before pressing a button, hide/show password components and etc. Also started working on an API.swift file but then looked into Firebase and decided we do not need this file for now.
- https://github.com/ECS189E/project-w21-big-bang-theory/commit/a1ace5dcfd9cd642b620ede853140816bf25ace7 (called test 5 since pushing was not working for me several times, so the fifth test worked out)
- https://github.com/ECS189E/project-w21-big-bang-theory/commit/b1aed67fe8335e485e1c6fd78be9017265893168
- https://github.com/ECS189E/project-w21-big-bang-theory/commit/e8fe8e5c4be968d53bb8fa1d0504a6386ffdd3aa
- https://github.com/ECS189E/project-w21-big-bang-theory/commit/8238507d91b0fc465920f062b3a8f24d19ec3a43
- https://github.com/ECS189E/project-w21-big-bang-theory/commit/8907a11f8973ee83978bcb650e0c4177d0f4c957

Created a Firebase program, installed necessary pods (Auth and Firestore) and started looking into Api usage.
https://github.com/ECS189E/project-w21-big-bang-theory/commit/955c150622777e0c78af4277b41c40260f98c240

**Gharam Alsaedi** - 
- Designed Icon.
- Designed Screens and overall flow of the app. Along with Ma Eint Poe, we discussed the flow of the application and the connections between view controllers. In addition, I started designing the screens using Figma : https://www.figma.com/file/C1nZuKT19fLt7fyb8CQKS2/The-Big-Bang-Theory?node-id=0%3A1 
- Researched databases: found that Firebase is the best option due to its simplicity and speed. 

**Ma Eint Poe** - 
- Came up with the list of all the view controllers and wireframed the navigation for the overall flow of the app using Figma: https://www.figma.com/file/C1nZuKT19fLt7fyb8CQKS2/%5BThe-Big-Bang-Theory%5D!
- Compiled a list of questions to ask for the professional questionnaires and the friend questionnaires (Added in Figma)
- Came up with some possible protocols and delegates: https://github.com/ECS189E/project-w21-big-bang-theory/commit/3faaf33bdb07259975fe5608566ee5e9548f2111
- Added tabcontrollers: https://github.com/ECS189E/project-w21-big-bang-theory/commit/2779231f92ba8e8159a0ebccf390ddb82e634351

**Wai Hei Ngan** -
- Researched different Apis for Video Chatting and settled for Twilio
  <br/>
  https://www.twilio.com/docs/video
- Implmeneted basic video call features for the app:
  <br/>
  https://github.com/ECS189E/project-w21-big-bang-theory/commit/4be4ff7b4a6ea4b5594c48573a54aed9a539dc98

### Plan to do:

**Eden Avivi** -

Look more into Firebase, understand the usage and implement into the login and sign up view controllers.

**Gharam Alsaedi** - 

Create UI for the view controllers. 

**Ma Eint Poe** - 
- Start implementing the professional and friend questionnaire view controllers 
- Familiarize/Learn how to use Firebase

**Wai Hei Ngan** - 
- Customize video call Api to fit what we need
- Improve video meeting room interface
- Generate token for different users logged in
- Bypass video meeting room name declaration

