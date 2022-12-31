//
//  SubscriptionViewDemo.swift
//  aCh01
//
//  Created by user on 2022/4/2.
//
//

import SwiftUI
import Combine

struct SubscriptionGroupView: View {
    
    @EnvironmentObject var subModel : SubscriptionModel
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack {
            List(subModel.subscriptionRoot) { it in
                Section(content: {
                    ForEach(subModel.dic[it.name]!, id:\.self) { item in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(item.name)")
                                    .font(.system(size: 20))
                                    .textSelection(.enabled)
                                Spacer()
                                Text("$\(item.avgOfMonthAmountInt)")
                                    .font(.system(size: 20))
                            }
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 6, trailing: 10))
                            Text("\(item.cycleName) \(item.cycleNote) \(item.typeOfAmount_display)支出 \(item.amountInt)")
                                .font(.system(size: 16))
                                .foregroundColor(Color.cusDarkGray)
                        }
                    }
                    
                }, header: {
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(it.name) ")
                                .font(.system(size: 26))
                                .bold()
                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                            Spacer()
                        }
                        .padding()
                    }
                },footer: {
                    VStack {
                        HStack {
                            Text("")
                            Text("合計：")
                                .bold()
                            Spacer()
                            Text("$\(it.amountInt)")
                                .bold()
                        }
                        Divider()
                        HStack {
                            Text("月支出：")
                            Spacer()
                            Text("$\(it.avgOfMonthAmountInt)")
                        }
                        .foregroundColor(Color.cusPurle(cs: colorScheme))
                        Divider()
                    }
                    .font(.cusListTitle())
                    .foregroundColor(Color.cusDrakRed)
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                })
            }
            Spacer()
        }
        .navigationBarTitle("週期群組檢視")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}

struct SubscriptionViewDemo_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
            .environmentObject(SubscriptionModel())
    }
}
