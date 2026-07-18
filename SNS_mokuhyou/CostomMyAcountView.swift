//
//  CostomMyAcountView.swift
//  SNS_mokuhyou
//
//  Created by 土屋　暁 on 2026/07/04.
//
import SwiftUI

struct ProfileEditView: View {
    @EnvironmentObject private var userStore: UserStore
    @Environment(\.dismiss) private var dismiss

    @State private var userName = ""
    @State private var bio = ""
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section("名前") {
                TextField("表示名", text: $userName)
                Text("\(userName.count)/20文字")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("自己紹介") {
                TextField("100文字以内", text: $bio, axis: .vertical)
                    .lineLimit(3...6)
                Text("\(bio.count)/100文字")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("変更できないID") {
                Text("@\(userStore.currentUser?.accountID ?? "")")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("プロフィール編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(isSaving ? "保存中…" : "保存") {
                    Task {
                        await save()
                    }
                }
                .disabled(
                    userName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    userName.count > 20 ||
                    bio.count > 100 ||
                    isSaving
                )
            }
        }
        .task {
            guard let profile = userStore.currentUser else { return }
            userName = profile.userName
            bio = profile.bio
        }
        .alert("保存できませんでした", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "不明なエラーです")
        }
    }

    private func save() async {
        isSaving = true

        do {
            try await userStore.updateProfile(
                userName: userName,
                bio: bio
            )
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            isSaving = false
        }
    }
}
