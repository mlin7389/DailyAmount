//
//  ImportView.swift
//  aCh01
//
//  Created by user on 2022/3/19.
//

import SwiftUI

struct ImportView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var subModel : SubscriptionModel
    @EnvironmentObject var pr : ExpenseModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focused : Bool
    
    var onImportCompleted: (() -> ())
    var importFileType : ImportFileType
    let edgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
    
    let edgeInsets2 = EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 0)
    
    init(_ importFileType:ImportFileType,_ onImportCompleted:@escaping () -> ()) {
        self.importFileType = importFileType
        self.onImportCompleted = onImportCompleted
    }
    
    @State var importActionFlg = false
    @State var showAlertMsg : Bool = false
    @State var confirmText : String = ""
    @State var confirmMSG : String = ""
    @State var importedCounting = 0.0
    @State var importTotalCount = 100.0
    @State var import_acv_flg = false
    @State var importing = false
    

    
    var body: some View {
        NavigationStack {
            VStack {
                VStack {
                    HStack {
                        Button(action: {
                            if disableImport() {
                                return
                            }
                            confirmMSG = "覆蓋匯入"
                            
                        }, label: {
                            Text("覆蓋匯入")
                                .font(.system(size: 18))
                                .foregroundColor(Color.white)
                            
                        })
                        .disabled(importing)
                        .padding(edgeInsets)
                        .background(Color.orange)
                        .opacity(confirmMSG == "覆蓋匯入" ? 1.0 : 0.5)
                        Spacer()
                        
                        Button(action: {
                            if disableImport() {
                                return
                            }
                            confirmMSG = "新增匯入"
                        }, label: {
                            Text("新增匯入")
                                .font(.system(size: 18))
                                .foregroundColor(Color.white)
                        })
                        .disabled(importing)
                        .padding(edgeInsets)
                        .background(Color.red)
                        .opacity(confirmMSG == "新增匯入" ? 1.0 : 0.5)
                        Spacer()
                        Button(action: {
                            dismiss()
                        }, label: {
                            Text("取消匯入")
                                .font(.system(size: 18))
                                .foregroundColor(Color.white)
                            
                        })
                        .disabled(importing)
                        .padding(edgeInsets)
                        .background(Color.green)
                        
                    }
                    .padding()
                    
                    if confirmMSG != "" {
                        VStack {
                            HStack {
                                if confirmMSG == "新增匯入" {
                                    Text("目前資料仍會保留，以附加方式新增資料")
                                        .padding(edgeInsets2)
                                }
                                else if confirmMSG == "覆蓋匯入" {
                                    Text("將會清除目前所有資料，以匯入資料取代")
                                        .padding(edgeInsets2)
                                }
                                else {
                                    Text("")
                                        .padding(edgeInsets2)
                                }
                                Spacer()
                            }
                            .foregroundColor(Color.red)
                            
                            HStack {
                                TextField("請輸入「\(confirmMSG)」", text: $confirmText)
                                    .focused($focused)
                                    .padding(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
                                    .border(Color.gray)
                                    .padding(edgeInsets2)
                                
                                Button(action: {
                                    
                                    if disableImport() {
                                        return
                                    }
                                    
                                    if confirmText == confirmMSG {
                                        import_acv_flg = true
                                        importing = true
                                        focused = false
                                        DispatchQueue.global().async(execute: {
                                            
                                            if confirmMSG == "新增匯入" {
                                                if self.importFileType == .ExpenseItems {
                                                    pr.importActionAppend(onImporting)
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                                        pr.importActionAfter()
                                                    })
                                                }
                                                else {
                                                    subModel.importActionAppend(onImporting)
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                                        subModel.importActionAfter()
                                                    })
                                                }
                                                importActionFlg = true
                                                
                                            }
                                            else {
                                                if self.importFileType == .ExpenseItems {
                                                    pr.importActionReplace(onImporting)
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                                        pr.importActionAfter()
                                                    })
                                                }
                                                else {
                                                    subModel.importActionReplace(onImporting)
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                                        subModel.importActionAfter()
                                                    })
                                                }
                                                importActionFlg = true
                                            }
                                            
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                                                dismiss()
                                            })
                                        })
                                        
                                    }
                                    else {
                                        import_acv_flg = false
                                        importing = false
                                        showAlertMsg.toggle()
                                    }
                                }, label: {
                                    Text("匯　入")
                                    if importing == true {
                                        ActivityIndicator(isAnimating: $import_acv_flg, style: .large)
                                    }
                                    
                                })
                                .disabled(importing)
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 40))
                                .font(.system(size: 20))
                                .alert(isPresented: $showAlertMsg) {
                                    Alert(title: Text("訊息"), message: Text("請輸入「\(confirmMSG)」中文字後，再按「確定」"), dismissButton: .default(Text("重新輸入")))
                                }
                            }
                            
                            ProgressView(processString(), value:importedCounting, total: importTotalCount)
                                .padding(EdgeInsets(top: 2, leading: 20, bottom: 2, trailing: 20))
                                .foregroundColor(Color.cusPurle(cs: colorScheme))
                        }
                    }
                    
                }
                
                VStack {
                    if self.importFileType == .ExpenseItems {
                        if pr.importFormatCheck == false{
                            Text("欄位格式解析有誤，請再確認。")
                                .foregroundColor(Color.red)
                                .font(.title)
                        }
                        if pr.sqlModel.demoDBMode == true {
                            Text("學習模式資料")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .foregroundColor(Color.white)
                                .background(Color.red)
                        }
                        List {
                            ForEach(pr.importExpenseItems, id:\.self) { item in
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("\(item.itemName)")
                                            .font(.system(size: 20))
                                            .textSelection(.enabled)
                                        Spacer()
                                        Text("$\(item.totalAmountInt)")
                                            .font(.system(size: 20))
                                    }
                                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 6, trailing: 10))
                                    Text("\(item.purhaseDateString)")
                                        .font(.system(size: 14))
                                        .foregroundColor(.cusGray)
                                }
                            }
                        }
                        .font(.system(size: 20))
                        .listStyle(.plain)
                        .onTapGesture(perform: {
                            self.focused = false
                        })
                    }
                    else {
                        if subModel.importFormatCheck == false{
                            Text("欄位格式解析有誤，請再確認。")
                                .foregroundColor(Color.red)
                                .font(.title)
                        }
                        List {
                            ForEach(subModel.importSubscriptions, id:\.self) { item in
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
                                    Text("\(item.typeOfAmount)費用 \(item.cycleName) \(item.cycleNote) 支出 \(item.amountInt)")
                                        .font(.system(size: 16))
                                        .foregroundColor(Color.cusGray)
                                }
                            }
                            
                        }
                        .font(.system(size: 20))
                        .listStyle(.plain)
                        .onTapGesture(perform: {
                            self.focused = false
                        })
                    }
                    
                }
                Spacer()
                
                
            }
            .navigationTitle("匯入資料檢視")
        }.navigationViewStyle(StackNavigationViewStyle())
            .onDisappear() {
                if  importActionFlg == true {
                    self.onImportCompleted()
                }
            }
            .onAppear() {
                if self.importFileType == .ExpenseItems {
                    importTotalCount = Double(pr.importExpenseItems.count)
                }
                else {
                    importTotalCount = Double(subModel.importSubscriptions.count)
                }
            }
    }
    func onImporting(_ cnt:Int) {
        importedCounting = Double(cnt)
    }
    func processString() -> String {
        if importing == true {
            return "正在匯入第\(Int(importedCounting))筆/共\(Int(importTotalCount))筆"
        }
        else {
            return "共\(Int(importTotalCount))筆"
        }
    }
    func disableImport() -> Bool {
        if pr.importFormatCheck == false || subModel.importFormatCheck == false {
            return true
        }
        else {
            return false
        }
    }
}

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        ImportView(.ExpenseItems, { })
            .environmentObject(SubscriptionModel())
            .environmentObject(ExpenseModel())
    }
}
