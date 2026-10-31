# evolglam moderation operations

App Store Guideline 1.2 requires every report to be reviewed within 24 hours.

## Before release

1. Confirm that the Firebase CLI target is `yaruki-kaihatu`, matching `GoogleService-Info.plist`.
2. Deploy `firestore.rules` to the Firebase project used by the app.
3. Confirm Anonymous Authentication is enabled.
4. In Firebase Console > App Check, register the iOS app with App Attest.
5. Launch a Debug build, copy its App Check debug token from the Xcode console, and register that token before testing in Simulator.
6. Monitor App Check metrics before enabling enforcement for Cloud Firestore and Authentication. Do not enable enforcement until valid production requests are visible.
7. Confirm the `reports` collection can be created by a signed-in test user.
8. Set an operational alert for new documents in `reports`, or check the collection frequently enough to meet the 24-hour response commitment.
9. Keep `ta.support.address@gmail.com` monitored.

## Handling a report

1. Open the `reports` document and review its post snapshot and reason.
2. Open `posts/{postID}` and review the current post.
3. If it violates the terms, delete the post.
4. For an abusive or repeat offender, disable `reportedUserID` in Firebase Authentication.
5. Update the report `status` to `resolved` and add `resolvedAt`, `resolution`, and `moderatorNote`.
6. If it does not violate the terms, update `status` to `dismissed` and document the reason.

Admin access uses a Firebase Authentication custom claim named `admin`. Never add this claim to a normal app user.

## Deploying rules

From this repository, after confirming `.firebaserc` and `GoogleService-Info.plist` both point to `yaruki-kaihatu`:

```sh
firebase deploy --only firestore:rules
```

Do not deploy until the selected Firebase project ID has been verified against `GoogleService-Info.plist`.

## Cost and abuse controls

- The public post listener is limited to the latest 50 posts.
- Blocked-user and hidden-post listeners are limited to 200 documents each.
- A reporter can create only one report per post because report document IDs are deterministic.
- User documents are private to their owner and administrators.
- Keep Firebase budget alerts enabled. App Check reduces automated abuse but is not a spending cap.
