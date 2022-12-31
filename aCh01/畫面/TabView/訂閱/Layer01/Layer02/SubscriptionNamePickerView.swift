//
//  SubNamePickerView.swift
//  aCh01
//
//  Created by user on 2022/3/5.
//

import SwiftUI

struct SubscriptionNamePickerView: View {
    
    @EnvironmentObject var pr : ExpenseModel
    @EnvironmentObject var subModel : SubscriptionModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @FocusState private var focused : Bool
    
    @State var firstTimePushAppear : Bool
    @State private var amount : Int = 0
    @State private var pushExpenseAmountCountInfoView : Bool = false

    var body: some View {
        
        VStack {
            
            HStack {
                Image(systemName: "exclamationmark.shield")
                    .font(.system(size: 24))
                Text("僅列出前100個輸入最多次的項目，若要找其它的項目，請使用搜尋文字功能")
                
            }
            .foregroundColor(Color.cusDrakRed)
            .padding()
            
            
            
            TextField("輸入要搜尋的文字", text: $pr.pickNameForSubscriptionItem)
                .focused($focused)
                .font(.system(size: 18))
                .padding(EdgeInsets(top: 6, leading: 20, bottom: 6, trailing: 20))
                .border(Color.gray)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
            
            if pr.sqlModel.demoDBMode == true {
                Text("學習模式資料")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .background(Color.red)
            }
            
            List {
                ForEach(pr.expenseNames2, id:\.self) { it in
                    VStack(alignment: .leading) {
                        Button(action: {
                            subModel.updateSubName(text: it.name)
                            dismiss()
                        }, label: {
                            Text("\(it.name)")
                                .font(.system(size: 20))
                                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                        }).foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                }
             }
            .listStyle(.plain)
            
            .onAppear() {
                if firstTimePushAppear == true {
                    firstTimePushAppear = false
                    pr.pickNameForSubscriptionItem = ""
                }
                else {
                    pr.loadExpenseNames2(text: pr.pickNameForSubscriptionItem)
                }
                
            }
        }
        .navigationTitle("選擇花費項目")
    }
}
