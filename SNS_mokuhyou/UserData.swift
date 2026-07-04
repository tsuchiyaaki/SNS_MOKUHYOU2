//
//  UserDate.swift
//  SNS_mokuhyou
//
//  Created by 土屋　暁 on 2026/07/04.
//

import SwiftData
import Foundation
import SwiftUI

@Model
final class UserData {
    var id: String        // Firebaseのuid
    var userName: String  // 表示名
    var accountID: String // @user_id みたいなID
    var profileImageURL: String
    var bio: String

    var followingCount: Int
    var followerCount: Int
    var postCount: Int
    var streakDays: Int

    var createdAt: Date
    var updatedAt: Date

    init(
        id: String,
        userName: String,
        accountID: String,
        profileImageURL: String = "",
        bio: String = "",
        followingCount: Int = 0,
        followerCount: Int = 0,
        postCount: Int = 0,
        streakDays: Int = 0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userName = userName
        self.accountID = accountID
        self.profileImageURL = profileImageURL
        self.bio = bio
        self.followingCount = followingCount
        self.followerCount = followerCount
        self.postCount = postCount
        self.streakDays = streakDays
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
