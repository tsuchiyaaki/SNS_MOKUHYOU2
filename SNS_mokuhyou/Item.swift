import Foundation
import SwiftData

@Model
final class Post {
    var name: String         // 投稿者の名前（例：T.A）
    var subject: String      // 1つ目のカプセル（例：一日の歩数）
    var change: String       // 2つ目のカプセル（例：3倍）
    var createdAt: Date      // 投稿した日時
    var selectedDate:String
    var selectedchange:String

    init(name: String, subject: String, change: String, createdAt: Date = Date(), selectedDate:String,selectedchange :String) {
        self.name = name
        self.subject = subject
        self.change = change
        self.createdAt = createdAt
        self.selectedDate = selectedDate
        self.selectedchange = selectedchange
    }
}

