//
//  Newpost.swift
//  SNS_mokuhyou
//
//  Created by 土屋　暁 on 2026/07/03.
//

import SwiftUI
import SwiftData

struct NewPostView: View {
    @Environment(\.modelContext) var context
    @Environment(\.dismiss) var dismiss      // 画面を閉じるための仕組み

    @State private var name = ""
    @State private var subject = ""
    @State private var change = ""
    let secsionDate = ["昨日", "一週間", "一ヶ月", "半年", "一年"]
    @State private var selectedDate = "昨日"

    let sectionchange = ["上がった", "増えた", "下がった", "減った"]
    @State private var selectedchange = "上がった"
    
    var body: some View {
        NavigationStack {
            
        
            Text("いつから？")
                            .font(.title2)
                            .bold()

                        Picker("いつから？", selection: $selectedDate) {
                            ForEach(secsionDate, id: \.self) { secsionDate in
                                Text(secsionDate)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 50)

                        Text("選択中：\(selectedDate)")
                            .font(.headline)
            
            Form {
                Section("だれが") {
                    TextField("名前（例：T.A）", text: $name)
                }
                Section("なにが") {
                    TextField("1つ目（例：一日の歩数）", text: $subject)
                }
                Section("どのくらい") {
                    TextField("2つ目（例：3倍）", text: $change)
                }
            }
            Text("どうなった？")
                            .font(.title2)
                            .bold()

                        Picker("どうなった？", selection: $selectedchange) {
                            ForEach(sectionchange, id: \.self) { sectionchange in
                                Text(sectionchange)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 50)

                        Text("選択中：\(selectedchange)")
                            .font(.headline)
            .navigationTitle("新しい投稿")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("投稿") {
                        addPost()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        dismiss()
                    }
                }
            }
        }
    }

    func addPost() {
        guard !name.isEmpty else { return }   // 名前が空なら何もしない
        let post = Post(name: name, subject: subject, change: change,selectedDate:selectedDate,selectedchange: selectedchange)
        context.insert(post)   // 保存する
        dismiss()              // 投稿したら画面を閉じる
    }
}

