# Community Classroom

Responsive Full Stack discussion forum application like reddit - Works on Android! 

## Features
- Google/Guest Authentication
- Create, Join community
- Community Profile (Avatar, Banner, Members) 
- Edit Description and Avatar of community
- Post (link only, photo, text only) 
- Displaying posts from communities user is part of
- Upvote, Downvote
- Comment
- Award the Post
- Update Karma
- Add Moderators
- Moderator- remove post
- Delete post
- User Profile (Avatar, Banner) 
- Theme Switch
- Cross Platform
- Responsive UI
- Latest posts (instead of home, display this to guest users) 

## Installation
After cloning this repository, migrate to ```Community Classroom``` folder. Then, follow the following steps:
- Create Firebase Project
- Enable Authentication (Google Sign In, Guest Sign In)
- Make Firestore Rules
- Create Android, iOS & Web Apps
- Use FlutterFire CLI to add the Firebase Project to this app.
Then run the following commands to run your app:
```cmd
  flutter pub get
  open -a simulator 
  flutter run
```

## Tech Used
**Server**: Firebase Auth, Firebase Storage, Firebase Firestore

**Client**: Flutter, Riverpod 2.0, Routemaster
    
