//
//  SwiftUIViewSubExpense.swift
//  aCh01
//
//  Created by user on 2022/4/13.
//

import SwiftUI

struct SubscriptionViewDetail: View {
    
    @EnvironmentObject var pr : ExpenseModel
    @EnvironmentObject var subModel : SubscriptionModel
    @Environment(\.colorScheme) var colorScheme
    
    var subItem : Subscription
    
    var body: some View {
        VStack {
            List {
                ForEach(pr.subscriptionViewExpenseItems, id:\.self) { it in
                    VStack(alignment: .leading) {
                        HStack {
                            Text("\(it.itemName)")
                                .textSelection(.enabled)
                                .font(.system(size: 20))
                            Spacer()
                            Text("$\(it.totalAmountInt)")
                                .font(.system(size: 20))
                        }
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 6, trailing: 10))
                        Text("\(it.purhaseDateString)")
                            .font(.system(size: 14))
                            .foregroundColor(.cusGray)
                    }
                }
            }
            .listStyle(.plain)
            Spacer()
            VStack {
                HStack {
                    Text("合計")
                        .foregroundColor(Color.cusDrakRed)
                        .bold()
                    Spacer()
                    Text("$\(pr.subExpensetItemSubtotal)")
                        .foregroundColor(Color.cusDrakRed)
                        .bold()
                }
                Divider()
                HStack {
                    Text("平均")
                    Spacer()
                    Text("$\(pr.subExpenseItemAvg)")
                }
                .bold()
                .foregroundColor(Color.cusPurle(cs: colorScheme))
            }
            .padding()
            .font(.system(size: 20))
        
        }
        .navigationTitle("訂閱及週期花費狀況")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear() {
            pr.queryExpenseItemByName(subItem.name)
        }
    }
}

struct SwiftUIViewSubExpense_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionViewDetail(subItem: Subscription())
            .environmentObject(ExpenseModel())
            .environmentObject(SubscriptionModel())
    }
}
