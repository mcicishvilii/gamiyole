# Firestore Setup Guide for Gamiyole

## Collection Structure

Your app requires two main collections in Firestore:

### 1. `users` Collection
This collection stores user profile information created during registration.

**Collection Path:** `users/`

**Document Structure:**
- Document ID: `{uid}` (Firebase Auth UID - auto-set by code)
- Fields:
  - `email` (String) - User's email address
  - `role` (String) - Either "sender" or "traveler"
  - `createdAt` (Timestamp) - Account creation timestamp

**Example Document:**
```
Document ID: "abc123xyz"
{
  "email": "john@example.com",
  "role": "traveler",
  "createdAt": Timestamp(2026, 4, 4, ...)
}
```

### 2. `shipments` Collection (Already Exists)
This collection stores all shipment listings.

**Collection Path:** `shipments/`

**Document Structure:**
- Document ID: Auto-generated
- Fields:
  - `senderId` (String) - UID of the sender
  - `origin` (String) - Starting location
  - `destination` (String) - Destination location
  - `budget` (Number) - Offered price
  - `status` (String) - "open" or "closed"
  - `createdAt` (Timestamp) - When shipment was created

**Subcollections:**
- `shipments/{shipmentId}/offers/` - Price offers from travelers
  - Fields:
    - `travelerId` (String) - UID of traveler making offer
    - `price` (Number) - Offered price
    - `status` (String) - "sent", "accepted", "rejected"
    - `createdAt` (Timestamp) - When offer was made

## Firestore Security Rules

Update your Firestore security rules to allow authenticated users to read/write their own data:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Everyone can read all shipments and offers
    match /shipments/{document=**} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth.uid == resource.data.senderId;
    }
    
    // Users can only read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

## How It Works in Your Code

### Registration Flow:
1. User enters email, password, and selects role
2. `AuthViewModel.signUp()` creates Firebase Auth user
3. Code automatically writes to `users/{uid}` with email and role
4. User is automatically logged in

### Login Flow:
1. User enters email and password
2. Firebase authenticates the user
3. `_onAuthStateChanged()` is triggered
4. Code reads from `users/{uid}` to get user role
5. UI routes to appropriate home screen

### Data Fetching:
- Senders see `SenderHomeScreen`
- Travelers see shipments from `shipments` collection filtered by status="open"
- Travelers can place bids in `shipments/{shipmentId}/offers`

## Steps to Set Up

1. **Go to Firebase Console** → Your Project → Firestore Database
2. **Create Collection:**
   - Click "Create Collection"
   - Name it: `users`
   - Click "Auto ID" for the first document
   - Add fields with sample data or leave blank (code will populate on first signup)

3. **Update Security Rules:**
   - Go to Firestore → Rules
   - Replace the default rules with the ones above
   - Click "Publish"

4. **Test:**
   - Run your app
   - Create a new account
   - Check Firestore console - you should see the user document created automatically

That's it! Your app will automatically create `users` documents when users register.
