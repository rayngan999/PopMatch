# Sprint Planning 5

### Project Summary:
A video chatting app that allows users to have 1 on 1 meetings with new people and like minded thinkers. A way to create soical bonds or networks for university students.

### Trello Link:
https://trello.com/b/Ctr0GQnf/ecs-189e-project

### What was done with commit links and descriptions:

**Eden Avivi** - 
* This week I mostly did formatting changes with Ma, fixing bugs and practicing for the demo.
* I succeeded in implementing the bubbles to fit the number of users online and limit it between 5 to 30 bubbles so the screen will not be empty, but this interrupted with the matching algorithm so it had to be taken down and might be used in the future. 
* In addition, I added a sound when a match is found in the lobbyVC. 
* Also, I tried to make an animation for the premeeting screen but the conversion between After Effects and xcode does not support the particles I used to animate the bubbles. 

Commits:
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/eeea8358eacaecab901db2925f3ded4d103c0745
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/28cb9554f8befb212301949270c7f4e053e9d90c
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/befd36224587a5bea462f90f4b917b6a42a5e9ff
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/6a6b7127a5866765340bb95e61b3b1aaf7477ea0
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/a9eb1a5f011c4ef826dbb3956a539a6d06fd4d4a
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/6422c846f337b9f0685abebeb222402a92e23bc2
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/e39b2f10fd71f88a05267a24a928a93850a298f5
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/4d652d04bc61a4fa08f6c38c01c45598880077bf

Animation tries:

![Comp-1-4](https://user-images.githubusercontent.com/67129992/110831444-19b12880-824f-11eb-8752-40915caf7e9f.gif)
![Comp-1](https://user-images.githubusercontent.com/67129992/110833749-a1983200-8251-11eb-9926-9bd254f8377e.gif)


**Gharam Alsaedi** -
* Improved Accept/Reject algorithm by adding rejected matches or matches you already conversated with to previous matches so they dont match again. 
* Improved matching algorithm to match the user to the person they have the most in common with. 
* Created the algoritm for sending social media links in the video chat.
* Fixed some bugs related to matching algorithm.

Commits: 
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/5b8696090c9982bad6f0b1f07220a85e06998f15
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/53d9780b000111b16ab615abeee804bb58bc4ff8

**Ma Eint Poe** -
* Worked on adding in personal qestions with various radio/checkbox styles for the Friend VC
* Linked external connection to facebook login
* Attempted to add in instagram external login (and linkedin with Eden), but removed it after api usage limitations
* Some formatting fixes and touchups on layouts for different screen sizes


Commits: 
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/089c9e03312f905715223b401b1f3c4b84cc0930
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/c5aba04e001ff5310dc2e67db11594380be64b9e

**Wai Hei Ngan (Ray)** -
* Created Timer Model and connected it to the firestore so the timer in the video room will be synchronize
* Automated username and roomname creation
* Added matching screen timer
* Support mutiple video rooms
* Improved accept/reject flow
* Added Icebreaker quiestions during video call
* Changed delete previous matches to profile view and added delay for matching so the data will be avaible after asynchronous call
* Added soical media links to  video room
* Changed linkedin user data to seach for full name

Commits:
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/0ddc8e771ce6811e820a3a04af3e6bf3c530638a
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/5fb43aa3ef4f984439360326f5dd72837a0688cb
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/3cfe35bee2703e8d75cc9feac02f5cf9389d87b3
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/2f25b5eebed60186af4a2456dbb44f1daf5c37d1
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/d7e6575535e8c644035193370e157a4fb7e4c30a
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/9c32f5dadcd6e2d02a906deb402ce39772767e7c
* https://github.com/ECS189E/project-w21-big-bang-theory/commit/4c0116bb3e4d7e9b99762ee6e4172cca826df004

### Plan to do:

**Eden Avivi** - Finish up the project by touching up on the constraints, adding comments and fixing warnings.

**Gharam Alsaedi** - Clean up the code by adding comments and cleaning up the UI a little bit more.

**Ma Eint Poe** - Clean up code and polish the autolayout warnings, the final documentation/readme

**Wai Hei Ngan (Ray)** -
Change reciving soical media links in a separate popup view

