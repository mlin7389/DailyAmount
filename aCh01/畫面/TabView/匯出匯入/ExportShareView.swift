//
//  ExportShareView.swift
//  aCh01
//
//  Created by user on 2022/3/5.
//

import SwiftUI
import UniformTypeIdentifiers

struct ExportShareView: View {
    
    @EnvironmentObject var subModel : SubscriptionModel
    @EnvironmentObject var pr : ExpenseModel
    
    @State var document: MessageDocument = MessageDocument(message: "", coding: .big5)
    @State var export_ExpenseItem_acv = false
    @State var export_Subscription_acv = false
    @State var isImporting = false
    @State var isExporting = false
    @State var showingExporter = false
    @State var fileName = ""
    @State var selectionCoding : MessageDocument.CusCodingType = .big5
    @State var dataAction : MessageDocument.DataAction = .Export
    @State var presentImportView = false
    @State var importFileType = ImportFileType.ExpenseItems
    @State var alertMsg = ""
    @State var alertTitle = ""
    @State var alert_flg = false
    @State var showInfoView = false
    @State var resetDB_flg = false
    @State var resetDB_success_flg = false
    @State var resetDB_msg = ""
    
    @State var sqlDemoDBMode = false
    
    var body: some View {

        NavigationStack {
            ScrollView([.vertical]) {
                VStack {
                    
                    VStack {
                        
                        Toggle("切換到App學習模式", isOn: $sqlDemoDBMode)
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                            .onChange(of: sqlDemoDBMode, perform: { _ in
                                pr.sqlModel.demoDBMode = sqlDemoDBMode
                                pr.reloadAllExpenseViewItems(true)
                                subModel.reloadAllData()
                            })
                        
                        HStack {
                            Text("切換學習模式後原資料不會消失，僅切換為學習模式資料供操作學習使用，新增、刪除、修改皆不會變更正常模式資料。")
                                .font(.system(size: 14))
                                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                                .alert(isPresented: $resetDB_success_flg) {
                                    Alert(title: Text("訊息") ,
                                          message: Text(resetDB_msg),
                                          dismissButton: .default(Text("確定")))
                                }
                            Spacer()
                        }
                        
                        HStack {
                            Button("重置學習模式資料") {
                                resetDB_flg = true
                            }
                            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                            .font(.system(size: 16))
                            .alert(isPresented: $resetDB_flg) {
                                
                                Alert(title: Text("訊息"),
                                      message: Text("是否確定要重置學習模式資料？") ,
                                      primaryButton: .destructive(Text("確定"), action: {
                                    let res = pr.sqlModel.resetDemoDB()
                                    if res.resut == true {
                                        pr.reloadAllExpenseViewItems(true)
                                        subModel.reloadAllData()
                                        resetDB_msg = "學習模式資料重置完成。\n資料期間為：\(res.firstDate) ~ \(res.lastDate)"
                                    }
                                    else {
                                        resetDB_msg = "學習模式資料重置失敗，原因不明"
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        self.resetDB_success_flg.toggle()
                                    }
                                }), secondaryButton: .default(Text("取消"), action: {
                                    
                                }))
                            }
                            Spacer()
                        }
                    }
                    .padding()
                    .border(Color.gray)
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 6, trailing: 16))
                    
                    //學習模式
                    if pr.sqlModel.demoDBMode == true {
                        Text("學習模式資料")
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .foregroundColor(Color.white)
                            .background(Color.red)
                    }
                    
                    
                    VStack(alignment: .leading) {
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Button(action: {
                                    showInfoView = true
                                }, label: {
                                    Image(systemName: "exclamationmark.circle")
                                        .foregroundColor(Color.orange)
                                })
                                .font(.system(size: 20))
                                Text("匯入匯出及編碼格式選擇")
                            }
                            HStack {
                                Text("將以 【\(self.selectionCoding.rawValue)】 【\(dataAction.rawValue)】 資料：")
                                Spacer()
                            }
                            .padding(EdgeInsets(top: 4, leading: 10, bottom: 0, trailing: 0))
                            
                            Picker("", selection: $dataAction) {
                                Text("匯出").tag(MessageDocument.DataAction.Export)
                                Text("匯入").tag(MessageDocument.DataAction.Import)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            Picker("", selection: $selectionCoding) {
                                Text("Big5編碼").tag(MessageDocument.CusCodingType.big5)
                                Text("UTF-8編碼").tag(MessageDocument.CusCodingType.utf8)
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            
                            Divider()
                            HStack {
                                Button(action: {
                                    
                                    if dataAction == .Export {
                                        self.export(.ExpenseItems)
                                    }
                                    else {
                                        importFileType = .ExpenseItems
                                        
                                        self.isImporting = false
                                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                                            self.isImporting = true
                                        })
                                    }
                                    
                                }, label: {
                                    if dataAction == .Export {
                                        Image(systemName: "square.and.arrow.up")
                                    }
                                    else {
                                        Image(systemName: "square.and.arrow.down")
                                            .foregroundColor(Color.orange)
                                    }
                                    Text("流水帳清單")
                                    ActivityIndicator(isAnimating: $export_ExpenseItem_acv,  style: .large)
                                })
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                                .font(.system(size: 20))
                                Spacer()
                            }
                            Divider()
                            HStack {
                                Button(action: {
                                    
                                    if dataAction == .Export {
                                        self.export(.Subscripttion)
                                    }
                                    else {
                                        importFileType = .Subscripttion
                                        
                                        self.isImporting = false
                                        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                                            self.isImporting = true
                                        })
                                    }
                                    
                                    
                                }, label: {
                                    if dataAction == .Export {
                                        Image(systemName: "square.and.arrow.up")
                                    }
                                    else {
                                        Image(systemName: "square.and.arrow.down")
                                            .foregroundColor(Color.orange)
                                    }
                                    Text("訂閱定期付費清單")
                                    ActivityIndicator(isAnimating: $export_Subscription_acv, style: .large)
                                })
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                                .font(.system(size: 20))
                                Spacer()
                            }
                        }
                        .padding()
                        .border(Color.gray)
                        .padding(EdgeInsets(top: 6, leading: 16, bottom: 0, trailing: 16))
                        
                    }
                    .sheet(isPresented: $showInfoView, content: {
                        ExportImportInfoView()
                    })
                    .fullScreenCover(isPresented: $presentImportView) {
                        ImportView(self.importFileType, onImportCompleted)
                    }
                    .fileImporter(isPresented: $isImporting,
                                  allowedContentTypes: [UTType.plainText],
                                  allowsMultipleSelection: false) { result in
                        do {
                            
                            guard let selectedFileURL: URL = try result.get().first else {
                                showAlertViewMessage("錯誤","取得檔案路徑失敗。")
                                return
                            }
                            
                            if ( selectedFileURL.startAccessingSecurityScopedResource()) {
                                
                                if FileManager.default.fileExists(atPath: selectedFileURL.path) {
                                    Trace.mPrint("檔案已準備完成", .ExecuteFlow)
                                } else {
                                    Trace.mPrint("檔案未準備完成", .ExecuteFlow)
                                }
                                
                                //嘗試讀取檔案大小，讓未準備完成的檔案從雲端下載
                                var error: NSError?
                                NSFileCoordinator().coordinate(readingItemAt: selectedFileURL,
                                                               options: .forUploading,
                                                               error: &error) { url in
                                    do {
                                        let resources = try selectedFileURL.resourceValues(forKeys:[.fileSizeKey])
                                        let fileSize = resources.fileSize!
                                        Trace.mPrint("檔案大小是:\(fileSize)", .ExecuteFlow)
                                    } catch {
                                        Trace.mPrint("雲端下載發生錯誤: \(error)", .Error)
                                        showAlertViewMessage("錯誤","讀取檔案發生錯誤。")
                                        return
                                    }
                                }
                                
                                
                                do {
                                    guard let message = String(data: try Data(contentsOf: selectedFileURL), encoding: MessageDocument.StringCoding.documentCoding(self.selectionCoding)) else {
                                        Trace.mPrint("開啟發生錯誤: \(selectedFileURL.absoluteString)", .Error)
                                        showAlertViewMessage("錯誤","檔案開啟失敗，請確認檔案編碼或格式是否有誤。")
                                        return
                                    }
                                    
                                    if self.importFileType == .ExpenseItems {
                                        pr.importMessage = message
                                    }
                                    else {
                                        subModel.importMessage = message
                                    }
                                    
                                    self.presentImportView = true
                                }
                            }
                            else {
                                showAlertViewMessage("錯誤","存取檔案權限未開啟")
                            }
                        } catch {
                            showAlertViewMessage("錯誤","發生未預期錯誤")
                            
                            Trace.mPrint(error.localizedDescription, .Error)
                        }
                    }
                                  .alert(isPresented: $alert_flg) {
                                      Alert(title: Text(self.alertTitle) ,
                                            message: Text(self.alertMsg),
                                            dismissButton: .default(Text("確定")))
                                  }
                                  .fileExporter(isPresented: $isExporting,
                                                document: document,
                                                contentType: UTType.plainText,
                                                defaultFilename: self.fileName) { result in
                                      if case .success = result {
                                          showAlertViewMessage("訊息","檔案匯出作業完成。")
                                      } else {
                                          showAlertViewMessage("錯誤","檔案匯出發生不明原因失敗！")
                                      }
                                  }
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading){
                            HStack {
                                Toggle("App關閉時不保留篩選條件", isOn: $pr.notKeepAppSettings)
                                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                            }
                            HStack {
                                Text("打開此選項後，若App完全關閉後重新開啟，所有日期選擇等及篩選條件會次每都是預設值，日期預設為當天")
                                    .font(.system(size: 14))
                                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                                Spacer()
                            }
                        }
                        .padding()
                        .border(Color.gray)
                        .padding(EdgeInsets(top: 6, leading: 16, bottom: 0, trailing: 16))
                    }
                    Spacer()
                }
                
            }
            .navigationTitle("其它功能")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())

    }
   
    func showAlertViewMessage(_ title:String,_ msg:String) {
        alertTitle = title
        alertMsg = msg
        alert_flg = true
    }
    
    func onImportCompleted() {
        showAlertViewMessage("訊息","檔案作業完成")
    }
    
    func export(_ importType:ImportFileType) {
        
        pr.disableTabView = true

        if importType == .ExpenseItems {
            
            if selectionCoding == .big5 {
                if pr.sqlModel.demoDBMode == true {
                    fileName = "流水帳(Big5)_學習模式資料_\(Date.now.DateStringType1()).csv"
                }
                else {
                    fileName = "流水帳(Big5)_\(Date.now.DateStringType1()).csv"
                }
            }
            else {
                
                if pr.sqlModel.demoDBMode == true {
                    fileName = "流水帳(UTF-8)_學習模式資料_\(Date.now.DateStringType1()).csv"
                }
                else {
                    fileName = "流水帳(UTF-8)_\(Date.now.DateStringType1()).csv"
                }
            }
            
            export_ExpenseItem_acv = true
            
            DispatchQueue.global().async(execute: {
                
                document.message = pr.exportExpenseItems()
                document.messageCoding = self.selectionCoding
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isExporting = true
                    pr.disableTabView = false
                    export_ExpenseItem_acv = false
                }
            })
        }
        else {
            if selectionCoding == .big5 {
                if pr.sqlModel.demoDBMode == true {
                    fileName = "訂閱(Big5)_學習模式資料_\(Date.now.DateStringType1()).csv"
                }
                else {
                    fileName = "訂閱(Big5)_\(Date.now.DateStringType1()).csv"
                }
            }
            else {
                if pr.sqlModel.demoDBMode == true {
                    fileName = "訂閱(UTF-8)_學習模式資料_\(Date.now.DateStringType1()).csv"
                }
                else {
                    fileName = "訂閱(UTF-8)_\(Date.now.DateStringType1()).csv"
                }
            }
            
            export_Subscription_acv = true
            
            DispatchQueue.global().async(execute: {
                
                document.message = subModel.sourceSubscriptionsToCSV()
                document.messageCoding = self.selectionCoding
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isExporting = true
                    pr.disableTabView = false
                    export_Subscription_acv = false
                }
            })
        }
       
    }
    
}

struct ExportShareView_Previews: PreviewProvider {
    static var previews: some View {
        ExportShareView()
            .environmentObject(SubscriptionModel())
            .environmentObject(ExpenseModel())
    }
}

