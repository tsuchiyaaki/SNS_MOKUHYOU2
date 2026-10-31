import Foundation

enum AppConfiguration {
    static let appName = "evolglam"
    static let supportEmail = "ta.support.address@gmail.com"
    static let termsVersion = "2026-10-17"
}

enum SafetyPolicyError: LocalizedError {
    case objectionableContent

    var errorDescription: String? {
        switch self {
        case .objectionableContent:
            return "不適切な表現が含まれているため送信できません。内容を修正してください。"
        }
    }
}

enum ContentSafetyFilter {
    // 投稿前の一次フィルター。通報と運営確認も併用して安全性を確保する。
    private static let prohibitedPhrases = [
        "死ね", "殺す", "ころす", "消えろ", "自殺しろ",
        "裸の写真", "児童ポルノ", "レイプ", "強姦",
        "個人情報晒", "住所晒", "電話番号晒",
        "kill yourself", "i will kill you", "child porn", "rape"
    ]

    static func validate(_ values: String...) throws {
        let text = normalize(values.joined(separator: " "))

        if prohibitedPhrases.contains(where: { text.contains(normalize($0)) }) {
            throw SafetyPolicyError.objectionableContent
        }
    }

    private static func normalize(_ text: String) -> String {
        text.folding(
            options: [.caseInsensitive, .diacriticInsensitive, .widthInsensitive],
            locale: Locale(identifier: "ja_JP")
        )
        .replacingOccurrences(of: " ", with: "")
        .replacingOccurrences(of: "　", with: "")
    }
}

enum ReportReason: String, CaseIterable, Identifiable {
    case harassment = "嫌がらせ・いじめ"
    case hate = "差別的・攻撃的な内容"
    case sexual = "性的または不適切な内容"
    case violence = "暴力・脅迫"
    case personalInformation = "個人情報の公開"
    case spam = "スパム・宣伝"
    case other = "その他"

    var id: Self { self }
}
