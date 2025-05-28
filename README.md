# HayyGov 

## Overview
**HayyGov** is a cross-platform mobile application built with Flutter. It facilitates structured communication between citizens, government officials, and advertisers. The app supports public announcements with PDF attachments, emergency contact access, community polls, citizen reports, and a moderated advertising system. Comments submitted by users are automatically filtered through a profanity-checking API to maintain appropriate communication.

## Features

### User Authentication and Role Management
- Secure registration and login
- Local storage for persistent sessions
- Role-based UI: Citizen, Government, Advertiser

### Citizen (CIT) Role
- View approved government announcements and advertisements
- Access emergency contact information
- Submit reports or requests to government officials
- Send messages in a chat with the goverment
- Participate in polls created by the government
- Comment on announcements and polls (comments are filtered for inappropriate content)
  

### Government (GOV) Role
- Post announcements and upload PDF attachments
- Create and publish polls
- View citizen reports and respond accordingly
- Chat with citizens
- Approve or reject advertisements submitted by advertisers
- Maintain emergency contact records

### Advertiser (AD) Role
- Submit advertisements for government review
- View status of each ad (approved or rejected)
- Access a list of all previously submitted ads

### Other Features
- Profanity filtering via external API for all comment fields
- Role-specific dashboards and navigation flows
- Firebase backend integration using Firestore
- Clean UI structure with providers and service abstraction

## Technologies Used

### Frontend
- Flutter (Dart)
- Firebase Core and Firebase Auth (User authentication)
- Flutter Material and custom widgets
- Provider (State management)
- Shared Preferences (Local persistent storage)
- Cached Network Image (Efficient image rendering)
- Syncfusion PDF Viewer (Display attached PDF documents)
- Flutter Dotenv (Environment variable handling)
- URL Launcher (Open external links)
- Intl (Date/time formatting)
- Geolocator and latlong2 (Geolocation support)
- File Picker (Select files from device)
- Flutter Local Notifications and Firebase Messaging (Push/in-app notifications)
- Translator (Language translation features)
- Connectivity Plus (Network status monitoring)
- Flutter Map (Map rendering and location-based UI)

### Backend Integration (Dart-based)
- Cloud Firestore for storing and retrieving app data
- Firebase Authentication for managing user accounts and sessions
- Firebase Messaging for push notifications
- Profanity Filter API using HTTP/Dio clients
- Dio and HTTP packages for RESTful communication
- Shared Preferences for local persistence of tokens and user state
- Custom Dart services and providers for role-based logic and API interaction





