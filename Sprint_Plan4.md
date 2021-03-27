# Sprint Planning 4

### Project Summary:
An app that uses an unique queue matching system to allow users to have 1 on 1 video chats with other people. A way to create social bonds or networking in a community, specifically in Universities. 

### Trello Link:
https://trello.com/b/Ctr0GQnf/ecs-189e-project

### What was done with commit links and descriptions:

**Eden Avivi** - 
* I worked on modifying the Lobby view controller a bit by fixing some contraints and changing the flow so that there is no button to go stright into the video call, now it goes to the matching view controller instead after 10 seconds (temporary, will be replaced by when a match is found). 
* I added a transition between LobbyVC and matchingVC in which I zoom in on a bubble that is not in the LobbyVC as if that bubble is a match and then that gets into the size of the bubble in the matchingVC and added a bubble popping sound effect.
*  I fixed a forced unwrap that was in the usage of Firebase Authentication, tried to help passing the user's ID from the signupVC into the profileVC, but that didn't turn out well so I helped fix the bug that it created.
*  I noticed that the two custom pop ups for resetting a password did not match, so I matched them up and made small touch ups like adding the url before the username entered in the social media pop ups and passed them into the meetingVC.
*  Added questions to our document to help with the idea of having a question presented at the beginning of each video chat.

Commits:

https://github.com/ECS189E/project-w21-big-bang-theory/commit/53cb1c61461dc5be685910fd135234f0c6adb85c
https://github.com/ECS189E/project-w21-big-bang-theory/commit/a43b4679eb3fc77950fe18224b56f63b6b98756e
https://github.com/ECS189E/project-w21-big-bang-theory/commit/9c8264d6217300c5590c61425bb988b482273673
https://github.com/ECS189E/project-w21-big-bang-theory/commit/0ceefc6aa934a45ce6f313d468688acf706e112e
https://github.com/ECS189E/project-w21-big-bang-theory/commit/fbc916c3d0b1c4373a30bcd20cc0d9d222417939
https://github.com/ECS189E/project-w21-big-bang-theory/commit/d2afbf98f19e08d7a6a65caaf0b1ec16374d756a
https://github.com/ECS189E/project-w21-big-bang-theory/commit/c89e49e86ae3898d7d7e667fa5d7b8eeab6c06e2

**Gharam Alsaedi** - 
* Worked on finding matches depending for user depending on three categories; major, hobbies, music preferences. I had to first make sure they dont already have a match by keeping track of "current match" variable. If not, I had to get all users and filter out users that are offline and users that are currently chatting with someone. Then with all the users left, I first check if majors match, if not I check hobbies, if not I check for music preferences. If no matches are found, I match the user with the first user in matches array. I then save current match id to be used in matchingVC and move to matchingVC. I had to use semaphores to synchronize these tasks. 
* Connected match's info to matchingVC UI.
https://github.com/ECS189E/project-w21-big-bang-theory/commit/eeea8358eacaecab901db2925f3ded4d103c0745
https://github.com/ECS189E/project-w21-big-bang-theory/commit/4749e42ce9ef1950ab051bce76d6d1867630300e


**Ma Eint Poe** - 
* Updated the different VC connections based on milestone 1 meeting suggestions - removed the Edit Page VC & Professional Question VC, and rewired Friend VC
* Changed the Friendship question VC to non-textfield type questions and implemented the functionalities - Storing to Firestore db and retrieving from db
https://github.com/ECS189E/project-w21-big-bang-theory/commit/61b6a8b11773f1dc1603b455baad12a435529d38
* Implemented the Profile VC UIs to store display user's data, added the updatable profile picture, and the pop up views to handle reseting password and displaying/editing different social media links clicks
https://github.com/ECS189E/project-w21-big-bang-theory/commit/a91729469347b6ed2ecbd64517e583b67af8c30d
* Structured the user's social media and question data collection/document for firestore

**Wai Hei Ngan** -
* Created token for each user for the video conference room
https://github.com/ECS189E/project-w21-big-bang-theory/commit/dc8979335c2136eb32c5f566905b767b5cf1a4df
* Created Timer Model
https://github.com/ECS189E/project-w21-big-bang-theory/commit/97a8d97eeb7fc846880902dd12c64a4f9542e512
* Added social media features in video calls
https://github.com/ECS189E/project-w21-big-bang-theory/commit/ee72fe0a398d040b8237e8878f8f77939ec79000#diff-4ce7730f27878279fa1b97010b05b5e92e67dca94d9e89c5621fc4a57c190bc7
* Modifed video confoness room and improve video calling experience
https://github.com/ECS189E/project-w21-big-bang-theory/commit/72488d742c1adbc0fa2189e8c664493e6aeaca71

### Plan to do:

**Eden Avivi** - 
* Help out with the matching algorithm if needed and testing it
* look into having the user sign up with another social media app instead of entering username as mentioned in milestone 2.
* Add the number of users currently online to the lobby screen and limit it between 5-30 if possible.

**Gharam Alsaedi** - 
* Keep track of rejected matches and reset when user goes offline.
* Find a way to wait for other user to accept match and check if both accepted before moving to meetingVC.

**Ma Eint Poe** - 
* Add in the new suggestions for personal questions 
* Fix some of the autolayouts for different screens  

**Wai Hei Ngan** -
* Create timer Model API
* Create chatting/ firestore where users can share soical media links in video conference room
* Add ice breaker questions duing video call

