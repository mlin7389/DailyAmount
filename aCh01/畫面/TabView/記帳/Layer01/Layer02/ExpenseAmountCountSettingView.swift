//
//  ExpenseAmountCountInfo.swift
//  aCh01
//
//  Created by user on 2022/4/9.
//

import SwiftUI

struct ExpenseAmountCountSettingView: View {

    @EnvironmentObject var pr : ExpenseModel
     
    var body: some View {
        
        VStack {
            Text("當某項目輸入的金額「相同次數」超過設定次數時，項目清單會自動帶出該金額，通常是經常性要記錄的流水帳固定的項目，例如：通勤族車資等。")
                .padding()
            
            Stepper("項目相同金額次數超過\(pr.autoAmountCount)次", value: $pr.autoAmountCount, in: 0...99)
                .padding()
            Spacer()
        }
        .navigationBarTitle("設定相同金額次數")

    }
}

struct ExpenseAmountCountInfo_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseAmountCountSettingView()
            .environmentObject(ExpenseModel())
    }
}
