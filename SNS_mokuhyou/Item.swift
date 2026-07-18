import Foundation
import FirebaseFirestore

struct Post: Identifiable {
    let id: String
    let authorName: String
    let subject: String
    let change: String
    let selectedDate: String
    let selectedChange: String
    let authorID: String
    let createdAt: Date

    init?(
        document: QueryDocumentSnapshot
    ) {
        let data = document.data()

        guard
            let authorName = data["authorName"] as? String,
            let subject = data["subject"] as? String,
            let change = data["change"] as? String,
            let selectedDate = data["selectedDate"] as? String,
            let selectedChange = data["selectedChange"] as? String,
            let authorID = data["authorID"] as? String
        else {
            return nil
        }

        self.id = document.documentID
        self.authorName = authorName
        self.subject = subject
        self.change = change
        self.selectedDate = selectedDate
        self.selectedChange = selectedChange
        self.authorID = authorID
        self.createdAt = (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
    }

    // PreviewでFirebaseへ接続せずに表示確認するための初期化
    init(
        id: String,
        authorName: String,
        subject: String,
        change: String,
        selectedDate: String,
        selectedChange: String,
        authorID: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.authorName = authorName
        self.subject = subject
        self.change = change
        self.selectedDate = selectedDate
        self.selectedChange = selectedChange
        self.authorID = authorID
        self.createdAt = createdAt
    }
}
