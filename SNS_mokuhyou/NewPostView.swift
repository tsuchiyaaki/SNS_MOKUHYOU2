//
//  Newpost.swift
//  SNS_mokuhyou
//
//  Created by 土屋　暁 on 2026/07/03.
//

import SwiftUI

struct NewPostView: View {
    @EnvironmentObject private var postStore: PostStore
    @EnvironmentObject private var userStore: UserStore
    @Environment(\.dismiss) private var dismiss

    @State private var subject = ""
    @State private var change = ""
    @State private var selectedDate = "昨日"
    @State private var selectedChange = "上がった"
    @State private var isPosting = false
    @State private var errorMessage: String?

    private let sectionDates = ["昨日", "一週間", "一ヶ月", "半年", "一年"]
    private let sectionChanges = ["上がった", "増えた", "下がった", "減った"]

    private var trimmedSubject: String {
        subject.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedChange: String {
        change.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canPost: Bool {
        !trimmedSubject.isEmpty &&
        !trimmedChange.isEmpty &&
        trimmedSubject.count <= 40 &&
        trimmedChange.count <= 20 &&
        userStore.currentUser != nil && !isPosting
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("投稿者") {
                    Text(userStore.currentUser?.userName ?? "読込中…")
                        .foregroundStyle(.secondary)
                }

                Section("いつから？") {
                    Picker("いつから？", selection: $selectedDate) {
                        ForEach(sectionDates, id: \.self) { date in
                            Text(date)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                }

                Section("なにが") {
                    TextField("例：一日の歩数", text: $subject)
                    Text("40文字まで")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("どのくらい") {
                    TextField("例：3倍", text: $change)
                    Text("20文字まで")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("どうなった？") {
                    Picker("どうなった？", selection: $selectedChange) {
                        ForEach(sectionChanges, id: \.self) { change in
                            Text(change)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 100)
                }
            }
            .navigationTitle("新しい投稿")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(isPosting ? "送信中…" : "投稿") {
                        Task {
                            await submit()
                        }
                    }
                    .disabled(!canPost)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        dismiss()
                    }
                    .disabled(isPosting)
                }
            }
            .alert("投稿できませんでした", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "不明なエラーです")
            }
        }
    }

    private func submit() async {
        guard canPost else { return }
        isPosting = true

        do {
            guard let profile = userStore.currentUser else {
                throw UserStoreError.profileNotFound
            }

            try await postStore.addPost(
                authorName: profile.userName,
                subject: trimmedSubject,
                change: trimmedChange,
                selectedDate: selectedDate,
                selectedChange: selectedChange
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            isPosting = false
        }
    }
}
