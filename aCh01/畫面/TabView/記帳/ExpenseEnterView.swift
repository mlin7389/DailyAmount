//
//  MoneyGOGO.swift
//  aCh01 記帳畫面
//
//  Created by user on 2022/2/27.
//

import SwiftUI
import Combine
import MobileCoreServices // << for UTI types
import UniformTypeIdentifiers

struct ExpenseEnterView: View {
    
    @FocusState private var focused1 : Bool
    @FocusState private var focused2 : Bool
   
    @EnvironmentObject var pr : ExpenseModel
   
    @StateObject var navModel = NavigationModel()

    @State var hint_alert01 = false
    @State var selection: Int? = nil
    @State var showGroupInsertMessage = false
    init() {
        UITextField.appearance().clearButtonMode = .whileEditing
    }
    
    var body: some View {
        NavigationStack(path: $navModel.navPath)
        {
            VStack {
                VStack {
                    
                    //花費項目
                    HStack {
                        ZStack {
                            TextField("花費項目",text: $pr.enterViewExpenseItem.itemName)
                                .padding(.cusDefault)
                                .focused($focused1)
                                .border(Color.gray)
                                .foregroundColor(pr.enterViewModifyMode == false ? Color.black : Color.red)
                                .font(.cusTextField())
                                .alert(isPresented: $hint_alert01) {
                                    Alert(title:Text("提示"),
                                          message: Text("此欄位輸入建議的內容是想統計的項目名稱，而非商品明細，不然群組統計畫面統計的項目會非常分散喔。若項目名稱未來需要調整或更換，可使用右上方「尋找取代」功能。\n\n清單左右滑到底可刪除或修改"), dismissButton: .default(Text("知道了")))
                                }

                            //編輯時，不要出現提示
                            if focused1 == false {
                                VStack (alignment: .trailing) {
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            hint_alert01 = true
                                        }, label: {
                                            Image(systemName: "exclamationmark.circle")
                                                .foregroundColor(Color.orange)
                                        })
                                        .font(.system(size: 22))
                                    }
                                }
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 6))
                            }
                            
                        }
                        
                        Button {
                            navModel.focusedText = focused1
                            navModel.focusedAmount = focused2
                            navModel.pushingViewBack = true    //回主畫面時要重設焦點
                            navModel.navPath.append(NavigationPathView.ExpenseNamePickerView)
                        } label: {
                            Image(systemName: "text.book.closed")
                                .font(.system(size: 24))
                        }
                        .alert(isPresented: $showGroupInsertMessage) {
                            Alert(title: Text("訊息"), message: Text("共新增\(pr.groupInsertCount)筆記錄"), dismissButton: .default(Text("知道了")) {
                                pr.groupInsertCount = 0
                            })
                        }
                    }
                    
                    //花費金額
                    HStack {
                        TextField("花費金額", text:$pr.enterViewExpenseItem.totalAmount)
                            .focused($focused2)
                            .keyboardType(.numberPad)
                            .padding(.cusDefault)
                            .border(Color.gray)
                            .foregroundColor(pr.enterViewModifyMode == false ? Color.black : Color.red)
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing:33))
                            .font(.cusTextField())
                    }
                    
                    //日期選擇_新增按鈕
                    HStack {
                        HStack{
                            Button(action: {
                                pr.changeDate(-1)
                            }, label: {
                                Image(systemName: "chevron.compact.left")
                                    .font(.system(size: 30))
                            })
                            DatePicker("",selection: $pr.enterViewSelectedDate,displayedComponents: .date)
                                .labelsHidden()
                                .environment(\.locale, Locale.init(identifier: "zh_TW"))
                                .padding(EdgeInsets(top: 0, leading: 6, bottom: 0, trailing: 6))
                            Button(action: {
                                pr.changeDate(1)
                            }, label: {
                                Image(systemName: "chevron.compact.right")
                                    .font(.system(size: 30))
                            })
                        }
                        Spacer()
                        Button(action: {
                            pr.enterViewAddExpenseItem()
                            focused1 = false
                            focused2 = false
                        }, label: {
                            Text(pr.enterViewModifyMode == false ? " 新  增 " : " 修  改 ")
                                .font(.system(size: 18))
                                .padding(.cusDefault)
                                .foregroundColor(pr.enterViewModifyMode == false ? Color.blue : Color.red)
                            
                        })
                        .alert(isPresented: $pr.newItemErrorMessageFlg) {
                            Alert(title: Text("訊息"), message: Text(pr.newItemErrorMessage), dismissButton: .default(Text("知道了")))
                        }
                    }
                    
                }
                .padding(EdgeInsets(top: 10, leading: 20, bottom: 0, trailing: 20))
                
                //關閉鍵盤
                if focused1 == true || focused2 == true {
                    Button(action: {
                        focused1 = false
                        focused2 = false
                    }, label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .font(.system(size: 24))
                    })
                }
                
                //學習模式
                if pr.sqlModel.demoDBMode == true {
                    Text("學習模式資料")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .background(Color.red)
                }
                
                //資料清單
                List {
                    ForEach(pr.enterViewExpenseItems, id:\.self) { item in
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(item.itemName)")
                                    .font(.cusListTitle())
                                    .textSelection(.enabled)
                                Spacer()
                                Text("$\(item.totalAmountInt)")
                                    .font(.cusListTitle())
                            }
                            .padding(EdgeInsets(top: 8, leading: 0, bottom: 6, trailing: 10))
                            Text("\(item.purhaseDateString)")
                                .font(.cusListSubTitle())
                                .foregroundColor(.cusGray)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                if pr.enterViewModifyMode == true {
                                    pr.modifyModeMessageFlg = true
                                }
                                else {
                                    pr.enterViewPutItemToUpdateMode(item: item)
                                    focused2 = true
                                }
                            } label: {
                                Text("修改")
                            }
                            .tint(.green)
                            
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                if pr.enterViewModifyMode == true {
                                    pr.modifyModeMessageFlg = true
                                }
                                else {
                                    pr.enterViewDeleteItem(item: item)
                                }
                            } label: {
                                Text("刪除")
                            }
                            .tint(.red)
                            
                        }
                    }
                    .font(.cusListTitle())
                }
                .listStyle(.plain)
                .animation(.default, value: UUID())
                .alert(isPresented: $pr.modifyModeMessageFlg) {
                    Alert(title: Text("訊息"), message: Text("請先完成目前正在修改的項目"), dismissButton: .default(Text("知道了")))
                }
                
                Spacer()
                
                //金額合計
                HStack {
                    Text("金額合計：")
                        .foregroundColor(Color.cusDrakRed)
                        .bold()
                    Spacer()
                    Text("$\(pr.enterViewSubtotal)")
                        .foregroundColor(Color.cusDrakRed)
                        .bold()
                }
                .padding()
                .font(.cusSubTotal())
            }
    
        
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button {
                        navModel.focusedText = focused1
                        navModel.focusedAmount = focused2
                        navModel.pushingViewBack = true    //回主畫面時要重設焦點
                        navModel.navPath.append(NavigationPathView.ExpenseItemsReplaceView)
                    } label: {
                        //Text("尋找取代")
                        Image(systemName: "magnifyingglass.circle")
                    }
                })
                
            }
            
            .navigationDestination(for: NavigationPathView.self) { item in
                
                if item ==  NavigationPathView.ExpenseItemsReplaceView {
                    ExpenseItemsReplaceView(firstTimePushAppear: true)
                }
                else if item  ==  NavigationPathView.ExpenseAmountCountSettingView  {
                    ExpenseAmountCountSettingView()
                }
                else if item  ==  NavigationPathView.ExpenseNamePickerView  {
                    ExpenseNamePickerView(firstTimePushAppear: true)
                }
                
            }
            .onAppear() {
               
                if navModel.pushingViewBack == true {
                    focused1 = navModel.focusedText
                    focused2 = navModel.focusedAmount
                    
                    navModel.focusedText = false
                    navModel.focusedAmount = false
                    
                    navModel.pushingViewBack = false
                    if pr.groupInsertCount > 0 {
                        self.showGroupInsertMessage = true
                    }
                }
                
                if pr.itemName != "" {
                    pr.enterViewUpdateExpenseItemText(selectText: pr.itemName)
                    pr.itemName = ""
                }

                if pr.itemAmount != "" {
                    pr.enterViewUpdateExpenseItemAmount(amount: Int(pr.itemAmount)!)
                    pr.itemAmount = ""
                }
               
            }
            .navigationTitle("記流水帳")
            .navigationBarTitleDisplayMode(.inline)
        }
      
        //.navigationViewStyle(StackNavigationViewStyle())
        //.navigationViewStyle(.stack)
    }
    
    func limitText(_ upper: Int) {
        if pr.enterViewExpenseItem.totalAmount.count > upper {
            pr.enterViewExpenseItem.totalAmount = String(pr.enterViewExpenseItem.totalAmount.prefix(upper))
        }
    }
    
}

struct MoneyGOGO_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseEnterView()
            .environmentObject(ExpenseModel())
    }
}
