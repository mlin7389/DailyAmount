//
//  ExpenseDetailSubView.swift
//  aCh01
//
//  Created by user on 2022/3/18.
//

import SwiftUI

struct ExpenseDetailSubView: View {
    
   @EnvironmentObject var pr : ExpenseModel

    var selectItem : ExpenseItem;

    var body: some View {
        VStack {
            Text("  ")
            if pr.sqlModel.demoDBMode == true {
                Text("學習模式資料")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .background(Color.red)
            }
            List {
                ForEach(pr.dsViewExpenseItems, id:\.self) { item in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(item.itemName)
                                .font(.cusListTitle())
                                .textSelection(.enabled)
                            Spacer()
                            Text("$\(item.totalAmountInt)")
                                .font(.cusListTitle())
                        }
                        .padding(EdgeInsets(top: 8, leading: 0, bottom: 6, trailing: 10))
                        Text(item.purhaseDateString)
                            .font(.cusListSubTitle())
                            .foregroundColor(.cusGray)
                    }
                }
            }
            .font(.cusListTitle())
            .listStyle(.plain)
            .navigationTitle(pr.detailViewGroupType.rawValue)
            .navigationBarTitleDisplayMode(.inline)
            
            Spacer()
            VStack {
                HStack {
                    Text("金額合計：")
                        .foregroundColor(Color.cusDrakRed)
                        .bold()
                    Spacer()
                    Text("$\(pr.detailSubViewSubtotal)")
                        .foregroundColor(Color.cusDrakRed)
                        .bold()
                }
                .padding()
                .font(.cusListTitle())
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear() {
            //顯示群組方式改變時觸動didset更新用
            pr.detailGroupSelectItem = selectItem
        }
    }
}

struct ExpenseDetailSubView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseDetailSubView(selectItem: ExpenseItem())
            .environmentObject(ExpenseModel())
    }
}
