import SwiftUI

struct TermsAgreementView: View {
    let onAgree: () -> Void

    @State private var confirmsAge = false
    @State private var acceptsTerms = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)

                    Text("利用規約への同意")
                        .font(.largeTitle.bold())
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text("evolglamを利用するには、以下のコミュニティルールへの同意が必要です。")
                        .foregroundStyle(.secondary)

                    TermsTextView()

                    Toggle("私は18歳以上です", isOn: $confirmsAge)
                    Toggle("利用規約とコミュニティルールに同意します", isOn: $acceptsTerms)

                    Button("同意して利用を開始") {
                        onAgree()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    .frame(maxWidth: .infinity)
                    .disabled(!confirmsAge || !acceptsTerms)

                    Text("お問い合わせ：\(AppConfiguration.supportEmail)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
                .padding()
            }
            .interactiveDismissDisabled()
        }
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            TermsTextView()
                .padding()
        }
        .navigationTitle("利用規約")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SupportView: View {
    private var emailURL: URL? {
        let subject = "evolglam お問い合わせ"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "mailto:\(AppConfiguration.supportEmail)?subject=\(subject)")
    }

    var body: some View {
        List {
            Section("不適切な活動の報告") {
                Text("投稿右上の…メニューから通報できます。緊急の場合や、通報後のご相談はメールでお問い合わせください。")

                if let emailURL {
                    Link(destination: emailURL) {
                        Label(AppConfiguration.supportEmail, systemImage: "envelope")
                    }
                }
            }

            Section("対応方針") {
                Text("通報内容を24時間以内に確認し、規約違反が確認された投稿の削除と、投稿者の利用停止を行います。")
            }

            Section("安全機能") {
                Label("投稿の通報と即時非表示", systemImage: "exclamationmark.bubble")
                Label("不適切なユーザーのブロック", systemImage: "person.crop.circle.badge.xmark")
                Label("投稿前の不適切表現フィルター", systemImage: "checkmark.shield")
            }
        }
        .navigationTitle("お問い合わせ・安全")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct TermsTextView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Group {
                Text("コミュニティルール")
                    .font(.headline)
                Text("evolglamは、不快・わいせつ・暴力的・差別的な投稿、嫌がらせ、脅迫、個人情報の公開、スパム、その他の不適切なコンテンツや abusive users（他者を傷つける利用者）を一切容認しません。")
            }

            Group {
                Text("禁止事項")
                    .font(.headline)
                Text("他者への攻撃、いじめ、差別、性的搾取、暴力の扇動、なりすまし、個人情報の無断掲載、違法行為、権利侵害、迷惑行為は禁止です。")
            }

            Group {
                Text("通報・ブロック")
                    .font(.headline)
                Text("不適切な投稿は…メニューから通報または非表示にできます。投稿者をブロックすると、その利用者の投稿は表示されなくなります。")
            }

            Group {
                Text("運営の対応")
                    .font(.headline)
                Text("運営は通報を24時間以内に確認し、違反コンテンツの削除、違反ユーザーの利用停止その他必要な措置を行います。重大または反復的な違反は予告なく利用を停止します。")
            }

            Group {
                Text("利用条件")
                    .font(.headline)
                Text("本サービスは18歳以上の方を対象とします。利用者は、自身が投稿した内容と行動について責任を負い、本規約および適用法令を守るものとします。")
            }

            Text("規約バージョン：\(AppConfiguration.termsVersion)\nお問い合わせ：\(AppConfiguration.supportEmail)")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 16))
    }
}
