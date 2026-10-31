import SwiftUI

struct BlockedUsersView: View {
    @EnvironmentObject private var postStore: PostStore
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if postStore.blockedUsers.isEmpty {
                ContentUnavailableView(
                    "ブロック中のユーザーはいません",
                    systemImage: "person.crop.circle.badge.checkmark"
                )
            } else {
                List(postStore.blockedUsers) { user in
                    HStack {
                        Label(user.displayName, systemImage: "person.crop.circle")
                        Spacer()
                        Button("解除") {
                            Task {
                                await unblock(user)
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
        }
        .navigationTitle("ブロック管理")
        .navigationBarTitleDisplayMode(.inline)
        .alert("ブロックを解除できませんでした", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "不明なエラーです")
        }
    }

    private func unblock(_ user: BlockedUser) async {
        do {
            try await postStore.unblockUser(user)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
