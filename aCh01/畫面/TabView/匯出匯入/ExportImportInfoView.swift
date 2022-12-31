//
//  SwiftUIViewInfo.swift
//  aCh01
//
//  Created by user on 2022/4/4.
//

import SwiftUI

struct ExportImportInfoView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .leading){
                HStack {
                    Text("匯入流水帳格式：")
                        .foregroundColor(Color.cusDrakRed)
                        .font(.title2)
                    Spacer()
                }
                .padding(EdgeInsets(top: 10, leading: 10, bottom: -2, trailing: 10))
                Divider()
                Text("匯入格式為逗點分隔csv檔，共有三個欄位，可自行使用Excel將信用卡帳單等花費資料，製作csv後匯入本app。(必須含有標題列，匯入時會固定刪除第一列標題列)\n\n範例：")
                    .font(.system(size: 14))
                    .lineLimit(nil)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                HStack {
                    Text("日期,項目名稱,金額\n2021/10/02,Foodpanda,325\n2021/10/07,NETFLIX,335")
                        .lineLimit(nil)
                        .padding(EdgeInsets(top: 4, leading: 10, bottom: 0, trailing: 10))
                    Spacer()
                }
                
                HStack {
                    Text("匯入訂閱定期付費清單：")
                        .foregroundColor(Color.cusDrakRed)
                        .font(.title2)
                    Spacer()
                }
                .padding(EdgeInsets(top: 30, leading: 10, bottom: -2, trailing: 10))
                Divider()
                Text("匯入格式為逗點分隔csv檔，共有六個欄位。除第二欄位「固定或浮動」必須為中文「固定」或「浮動」，若非這兩個文字，則預設為「浮動」，其餘欄位可輸入任意值。(必須含有標題列，匯入時會固定刪除第一列標題列)\n\n範例：")
                    .lineLimit(nil)
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                HStack {
                    Text("項目名稱,固定或浮動,支付金額,月平均金額,週期,備註\n迪士尼+,固定,2790,232,每年,每月3號\nNetflix,固定,390,390,每月,7號\n水費,浮動,500,500,奇數月,13號\n電費,浮動,1500,1500,奇數月,19號")
                        .lineLimit(nil)
                        .padding(EdgeInsets(top: 8, leading: 2, bottom: 10, trailing: 2))
                        .font(.system(size: 14))
                    Spacer()
                }
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                
                
                Spacer()
            }
            .navigationTitle("匯入檔案格式說明")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") {
                        dismiss()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .font(.system(size: 14))
    }
}

struct SwiftUIViewInfo_Previews: PreviewProvider {
    static var previews: some View {
        ExportImportInfoView()
    }
}
