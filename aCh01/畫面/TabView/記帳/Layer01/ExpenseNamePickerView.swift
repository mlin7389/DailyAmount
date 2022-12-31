//
//  ItemNamePickerView.swift
//  aCh01
//
//  Created by user on 2022/2/28.
//

import SwiftUI

struct ExpenseNamePickerView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var pr : ExpenseModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var amount : Int = 0
    @FocusState private var focused : Bool
    @State var firstTimePushAppear : Bool
    
    var body: some View {
        VStack {
            Text(" ")
                .font(.system(size: 6))
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            HStack{
                Button {
                    pr.newItemErrorMessageFlg = true
                } label: {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 18))
                        .foregroundColor(Color.orange)
                }
                .padding(EdgeInsets(top: 0, leading: 8, bottom: 10, trailing: 0))
                .alert(isPresented: $pr.newItemErrorMessageFlg) {
                    Alert(title: Text("訊息"), message: Text("僅列出近30日內前100個輸入最多次的項目，另相同金額次數滿足設定條件才會顯示金額。若要找其它的項目，請使用搜尋文字功能(會查詢全部資料不理會金額條件)\n\n往左滑可將項目加入群組"), dismissButton: .default(Text("知道了")))
                }
                
                TextField("搜尋文字", text: $pr.searchItemNameContainText)
                    .focused($focused)
                    .font(.cusTextField())
                    .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 20))
                    .border(Color.gray)
                    .padding(EdgeInsets(top: 0, leading: 4, bottom: 10, trailing: 4))
                TextField("搜尋金額", text: $pr.searchItemAmountIsText)
                    .focused($focused)
                    .font(.cusTextField())
                    .keyboardType(.numberPad)
                    .padding(EdgeInsets(top: 6, leading: 10, bottom: 6, trailing: 20))
                    .frame(width: 120)
                    .border(Color.gray)
                    .padding(EdgeInsets(top: 0, leading: 4, bottom: 10, trailing: 10))
            }
            
            
            if pr.sqlModel.demoDBMode == true {
                Text("學習模式資料")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .background(Color.red)
            }
            
            if focused == true {
                Button(action: {
                    focused = false
                }, label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .font(.system(size: 24))
                })
            }
            List {
                ForEach(pr.expenseItemNames, id:\.self) { it in
                    VStack(alignment: .leading) {
                       
                        Button(action: {
                            pr.itemName =  it.name
                            pr.itemAmount =  String(it.extraAmount)
                            if it.extraAmount == 0 {
                                dismiss()
                            }
                            else  {
                                dismiss()
                            }
                        }, label: {
                            HStack{
                                Text("\(it.name)")
                                    .font(.system(size: 18))
                                Spacer()
                                Text("\(it.extraAmountString)")
                                    .font(.cusListTitle())

                            }
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 5))
                        })
                        .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                pr.insertPickGroupName(item:it)
                            } label: {
                                Text("加入群組")
                            }
                            .tint(.green)
                            
                        }
                    }
                }
             }
            .listStyle(.plain)
            //.animation(.default, value: UUID())
            Spacer()
            if pr.pickGroupNames.count > 0 {
                ExpenseGroupNoteView() {
                    pr.pickGroupNameAddExpenseItems()
                    dismiss()
                }
            }
        }
        .onAppear() {

            if firstTimePushAppear == true {
                firstTimePushAppear = false

                //避免重置變數DidSet時去觸發load資料
                pr.byassDidSetLoaditems = true

                pr.searchItemNameContainText = ""
                pr.searchItemAmountIsText = ""
                pr.expenseItemNames.removeAll()
                
                pr.byassDidSetLoaditems = false
            }
            
            pr.loadExpensePickerNames()
          
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink("金額次數",value:NavigationPathView.ExpenseAmountCountSettingView )
            }
        }
        .navigationTitle("花費項目")
    }
}

struct ItemNamePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseNamePickerView(firstTimePushAppear: true)
            .environmentObject(ExpenseModel())
    }
}
