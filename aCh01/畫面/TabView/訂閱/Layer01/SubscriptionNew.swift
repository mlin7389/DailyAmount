//
//  SubscriptionMew.swift
//  aCh01
//
//  Created by user on 2022/4/3.
//

import SwiftUI
import Combine

struct SubscriptionNew: View {
    
    @EnvironmentObject var subModel : SubscriptionModel
    @EnvironmentObject var navModelforSub : NavModelForSub
    @FocusState private var focused : Bool
    @Environment(\.dismiss) private var dismiss

    @State var amountIsNotNumber = false
    
    var subItem : Subscription
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("費用：")
                    Picker("PayWay", selection: $subModel.subscriptionItem.PayType) {
                        ForEach(PayWay.allCases, id: \.self) { type in
                            Text("\(type.rawValue)").tag(type.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 40))
                }
                
                HStack {
                    TextField("訂閱/帳單名稱",text: $subModel.subscriptionItem.name)
                        .focused($focused)
                        .padding(.cusDefault)
                        .border(Color.gray)
                        .font(.cusTextField())
                    
                    NavigationLink(value:NavModelForSub.NavPath(subItem: Subscription(), viewType: .NamePicker)) {
                        Image(systemName: "text.book.closed")
                            .font(.system(size: 32))
                    }
                }
                
                HStack {
                    TextField("訂閱或繳費週期",text: $subModel.subscriptionItem.cycleName)
                        .focused($focused)
                        .padding(.cusDefault)
                        .border(Color.gray)
                        .font(.cusTextField())
                    
                    NavigationLink(value:NavModelForSub.NavPath(subItem: Subscription(), viewType: .CycleNamePicker)) {
                        Image(systemName: "text.book.closed")
                            .font(.system(size: 32))
                    }
                }
                
                HStack {
                    TextField("付費金額",text: $subModel.subscriptionItem.amount)
                        .onReceive(Just(subModel.subscriptionItem.amount)) { _ in limitText1(AMOUNT_LIMIT) }
                        .keyboardType(.asciiCapableNumberPad)
                        .focused($focused)
                        .padding(.cusDefault)
                        .border(Color.gray)
                        .font(.cusTextField())
                    Text("/")
                    TextField("月平均支出",text: $subModel.subscriptionItem.avgOfMonthAmount)
                        .focused($focused)
                        .onReceive(Just(subModel.subscriptionItem.avgOfMonthAmount)) { _ in limitText2(AMOUNT_LIMIT) }
                        .keyboardType(.asciiCapableNumberPad)
                        .padding(.cusDefault)
                        .border(Color.gray)
                        .font(.system(size: 16))
                    
                    //請先輸入付費金額欄位
                    
                    Button {
                        if subModel.subscriptionItem.amount.isNumber {
                            subModel.listAvgOfMonth()
                            navModelforSub.appendPath(subItem: Subscription(), viewType: .AvgPicker)
                        }
                        else {
                            amountIsNotNumber = true
                        }
                    } label: {
                        Image(systemName: "candybarphone")
                            .font(.system(size: 32))
                    }
                    .alert(isPresented: $amountIsNotNumber) {
                        Alert(title:Text("訊息"),
                              message: Text("付費金額欄位請先輸入數字"), dismissButton: .default(Text("知道了")))
                    }
                    
                }
                
                HStack {
                    TextField("備註 例:12月 , 13號等",text: $subModel.subscriptionItem.cycleNote)
                        .focused($focused)
                        .padding(.cusDefault)
                        .border(Color.gray)
                        .font(.cusTextField())
                    
                    Button(action: {
                        focused = false
                        subModel.subscriptionViewAddSubItem()
                        dismiss()
                    }, label: {
                        Text(subModel.ViewModifyMode == false ? " 新 增 " : " 修 改 ")
                            .font(.cusTextField())
                            .padding(.cusDefault)
                            .border(Color.gray)
                            .foregroundColor(subModel.ViewModifyMode == false ? Color.blue : Color.red)
                    })
                    .alert(isPresented: $subModel.errorMessageFlg) {
                        Alert(title: Text("訊息"), message: Text(subModel.errorMessage), dismissButton: .default(Text("知道了")))
                    }
                }
                
            }
            .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            HStack {
                Image(systemName: "exclamationmark.shield")
                    .font(.system(size: 24))
                Text("新增完後點選「資料列」會自動找出所有帳務中符合名稱的流水帳。刪除時僅會移除週期畫面的項目，流水帳資料不會被異動。")
                
            }
            .foregroundColor(Color.cusDrakRed)
            .padding()
            Spacer()
        }
        
        .onAppear() {
 
            subModel.selectSubItem = subItem
            
            if subModel.text_tmp != "" {
                subModel.updateSubName()
            }

            if subModel.cycle_tmp != "" {
                subModel.updateCycleName()
            }
            
            if subModel.avgOfMonthAmount_tmp != "" {
                subModel.updateAvgOfMonth()
            }
            
           
        }
        
    }
    
    func limitText1(_ upper: Int) {
        if subModel.subscriptionItem.amount.count > upper {
            subModel.subscriptionItem.amount = String(subModel.subscriptionItem.amount.prefix(upper))
        }
    }
    
    func limitText2(_ upper: Int) {
        if subModel.subscriptionItem.avgOfMonthAmount.count > upper {
            subModel.subscriptionItem.avgOfMonthAmount = String(subModel.subscriptionItem.avgOfMonthAmount.prefix(upper))
        }
    }
}

struct SubscriptionMew_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionNew(subItem: Subscription())
    }
}
