//
//  CalcuateAvgView.swift
//  aCh01
//
//  Created by user on 2022/3/5.
//

import SwiftUI

struct CalcuateAvgView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var subModel : SubscriptionModel
    @Environment(\.colorScheme) var colorScheme

    @State var hint_alert01 = false
    
    var body: some View {
        VStack {
            Text("  ")
            if subModel.sqlModel.demoDBMode == true {
                Text("學習模式資料")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .background(Color.red)
            }
            
            ScrollViewReader { scrollView in
                ScrollView(.vertical) {
                    LazyVStack(alignment: .leading) {
                        ForEach(subModel.avgSumOfMonth, id:\.self) { it in
                            
                            HStack {
                                Spacer()
                                Button(action: {
                                    subModel.updateAvgOfMonth(text: String(it.avgAmount))
                                    dismiss()
                                }, label: {
                                    HStack{
                                        Text("\(it.avgAmountString)")
                                            .foregroundColor(Color.blue)
                                            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                                    }
                                }).foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                Spacer()
                                Button(action: {
                                    subModel.updateAvgOfMonth(text: String(it.sumAmount))
                                    dismiss()
                                }, label: {
                                    HStack{
                                        Text("\(it.sumAmountString)")
                                            .foregroundColor(Color.blue)
                                            .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                                    }
                                }).foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                Spacer()
                            }
                        }
                    }
                }
                
            }
            .clipped()
        }
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    hint_alert01 = true
                } label: {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(Color.orange)
                }
                .alert(isPresented: $hint_alert01) {
                    Alert(title: Text("提示"), message: Text("此畫面僅供快速選擇平均的付費金額，例如年繳費用，月平均就是除12，也可回上一頁自行輸入特定數字。"), dismissButton: .default(Text("知道了")))
                }
            }
        })
        .onAppear() {
          
        }
        .navigationTitle("計算平均支出")
    }
}

struct CalcuateAvgView_Previews: PreviewProvider {
    static var previews: some View {
        CalcuateAvgView()
            .environmentObject(SubscriptionModel())
    }
}
