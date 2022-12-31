//
//  SwiftUIViewReplaceAlert.swift
//  aCh01
//
//  Created by user on 2022/4/9.
//

import SwiftUI

struct ExpenseItemsReplaceAlertView: View {
    
    @EnvironmentObject var pr : ExpenseModel
    @Environment(\.dismiss) private var dismiss
    @State var hint_alert01 = false
    
    @State var count = 5
    @State var confirmBtnDisabled = true
    
    func counting() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            counting2()
        }
      
    }
    
    func counting2() {
        
        if count <= 0 {
            confirmBtnDisabled = false
        }
        else {
            count -= 1
            counting()
        }
      
    }
    
    
  var countingString : String {
        get{
            if count <= 0 {
                return ""
            }
            else {
                return "(\(count))"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
        VStack {
            VStack {
                Text("此動作無法還原")
                    .foregroundColor(Color.red)
                    .padding()
                Text("你確定要將")
                HStack{
                    Text("\(pr.searchResultCount)")
                        .fontWeight(.bold)
                        .background(Color.red)
                        .foregroundColor(Color.white)
                    Text("筆記錄的項目名稱")
                }.padding()
                
                Text("取代為以下文字嗎？")
                    .padding()
                Text("\(pr.replaceViewStr2)")
                    .fontWeight(.bold)
                    .background(Color.yellow)
                    .padding()
                    
            }
            .font(.title)
            HStack {
                Spacer()
                Button("確　定\(countingString)") {
                    pr.replaceViewStr1 = ""
                    pr.updateItemNames()
                    hint_alert01 = true
                }
                .padding()
                .background(Color.red)
                .foregroundColor(Color.white)
                .font(.title)
                .alert(isPresented: $hint_alert01) {
                    Alert(title: Text("訊息"), message: Text("取代完成"), dismissButton: .default(Text("確定")) {
                        dismiss()
                    })
                }
                .disabled(confirmBtnDisabled)
                .opacity(confirmBtnDisabled == true ? 0.5 : 1.0)
                Spacer()
                Button("取　消") {
                    dismiss()
                }
                .padding()
                .background(Color.green)
                .foregroundColor(Color.white)
                .font(.title)
                Spacer()
            }
            .padding()
            Spacer()
        }
            .navigationTitle("取代確認")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear() {
            counting()
        }
    }
}

struct SwiftUIViewReplaceAlert_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseItemsReplaceAlertView()
    }
}
