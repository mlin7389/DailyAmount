//
//  RoutinNamePickerView.swift
//  aCh01
//
//  Created by user on 2022/3/5.
//

import SwiftUI

struct CycleNamePickerView: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var subModel : SubscriptionModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        
        VStack {
         
            HStack {
                Image(systemName: "exclamationmark.shield")
                    .font(.system(size: 24))
                Text("若無適合週期，可於上一頁輸入新增一筆資料後就會自動出現在此畫面供後續選擇使用。")
                
            }
            .foregroundColor(Color.cusDrakRed)
            .padding()
            
            
            if subModel.sqlModel.demoDBMode == true {
                Text("學習模式資料")
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .foregroundColor(Color.white)
                    .background(Color.red)
            }
            
            List {
                ForEach(subModel.cycleNames, id:\.self) { it in
                    VStack(alignment: .leading) {
                        Button(action: {
                            subModel.updateCycleName(text: it.name)
                            dismiss()
                        }, label: {
                            HStack{
                                Text("\(it.name)")
                                    .font(.system(size: 20))
                                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                            }
                        }).foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                    }
                }
                .onDelete(perform: deleteName)
             }
            .listStyle(.plain)
        }
        .onAppear() {
            subModel.cycle_tmp = ""
            subModel.loadCycleNames()
        }
        .navigationTitle("選擇繳費週期")
    }
    
    private func deleteName(at indexSet: IndexSet) {
        let index = indexSet[indexSet.startIndex]
        subModel.deleteCycleName(subModel.cycleNames[index])
        subModel.cycleNames.remove(at: index)
    }
}
