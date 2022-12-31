//
//  SwiftUIViewReplace.swift
//  aCh01
//
//  Created by user on 2022/4/5.
//

import SwiftUI

struct ExpenseItemsReplaceView: View {
    
    @EnvironmentObject var pr : ExpenseModel
    @FocusState private var focused : Bool
    
    @State var duringModifyAlert : Bool = false
    @State var searchFieldInspectAlert : Bool = false
    @State var replaceFieldInspectAlert : Bool = false
    @State var showReplaceAlertView : Bool = false
    @State var replaceAlertMessage = ""
    @State var firstTimePushAppear : Bool
    @State var searchResult: Bool = false
    
    var body: some View {
        VStack {
          
            VStack {
                VStack {
                    Picker("searchType", selection: $pr.searchType) {
                        ForEach(SearchType.allCases, id: \.self) { type in
                            Text("\(type.rawValue)").tag(type.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    HStack{
                        VStack {
                            TextField("要搜尋的項目名稱", text: $pr.replaceViewStr1)
                                .focused($focused)
                                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                                .border(Color.gray)
                            HStack {
                                TextField("金額區間", text: $pr.replaceMinAmount)
                                    .focused($focused)
                                    .padding(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
                                    .keyboardType(.numberPad)
                                    .border(Color.gray)
                                Text("～")
                                TextField("金額區間",text: $pr.replaceMaxAmount)
                                    .focused($focused)
                                    .padding(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
                                    .keyboardType(.numberPad)
                                    .border(Color.gray)
                               
                            }
                            .font(.cusTextField())
                        }
                        .alert(isPresented: $searchResult) {
                            Alert(title: Text("訊息"), message: Text("沒有找到資料"), dismissButton: .default(Text("知道了")))
                        }
                        
                        Button(action: {
                            if pr.replaceViewStr1 == "" &&
                                pr.replaceMaxAmount.isNumber == false && pr.replaceMinAmount.isNumber == false {
                                searchFieldInspectAlert = true
                            }
                            else {
                                focused = false
                                pr.searchItemName()
                                
                                if pr.searchResultCount == 0 {
                                    searchResult = true
                                }
                            }
                        }, label: {
                            Text("搜尋")
                                .frame(width: 60)
                        })
                        .alert(isPresented: $searchFieldInspectAlert) {
                            Alert(title: Text("訊息"), message: Text("搜尋名稱或金額不可空白"), dismissButton: .default(Text("知道了")))
                        }
                    }
                    
                    if pr.searchResultItemNames.count > 0 {
                        HStack {
                            TextField("要將項目名稱取代成文字", text: $pr.replaceViewStr2)
                                .focused($focused)
                                .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                                .border(Color.gray)
                            Button(action: {
                                if pr.replaceViewStr2 == "" {
                                    replaceAlertMessage = "取代名稱不可空白"
                                    replaceFieldInspectAlert = true
                                }
                                else {
                                    if pr.searchResultItemNames.count > 0 {
                                        showReplaceAlertView = true
                                    }
                                    else {
                                        replaceAlertMessage = "無資料可取代"
                                        replaceFieldInspectAlert = true
                                    }
                                }
                            }, label: {
                                Text("全部取代")
                                    .frame(width: 80)
                            })
                            .alert(isPresented: $replaceFieldInspectAlert) {
                                Alert(title: Text("訊息"), message: Text(replaceAlertMessage), dismissButton: .default(Text("知道了")))
                            }
                            .sheet(isPresented: $showReplaceAlertView, content: {
                                ExpenseItemsReplaceAlertView()
                            })
                        }
                    }
                    
                    
                    if pr.searchResultCount >= 0 {
                        HStack {
                            Text("共找到\(pr.searchResultCount)筆")
                                .foregroundColor(Color.cusDrakRed)
                            Spacer()
                        }
                        
                    }
                    
                }
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 4, trailing: 10))
                
                if pr.sqlModel.demoDBMode == true {
                    Text("學習模式資料")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .background(Color.red)
                }
                
                List {
                    ForEach(pr.searchResultItemNames, id:\.self) { item in
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
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                pr.updateSearchItemName(item)
                            } label: {
                                Text("排除")
                            }
                            .tint(.orange)
                            
                        }
                        .onTapGesture(perform: {
                            pr.replaceViewStr1 = item.itemName
                        })
                    }
                }
                .onTapGesture(perform: {
                    focused = false
                })
                .listStyle(.plain)
                .animation(.spring(), value: UUID())
            }
            Spacer()
        }
        .navigationTitle("取代項目名稱")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    duringModifyAlert = true
                }, label: {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(Color.orange)
                })
                .alert(isPresented: $duringModifyAlert) {
                    Alert(title:Text("提示") ,
                          message: Text("若要大量更換項目前，建議先匯出流水帳後再作業，以防「後悔」或「改錯」了。"), dismissButton: .default(Text("知道了")))
                }
            }
        }
        .onAppear() {
            if firstTimePushAppear == true {
                firstTimePushAppear = false
                pr.searchType = .LikeSearch
                pr.replaceViewStr1 = ""
                pr.replaceMinAmount = ""
                pr.replaceMaxAmount = ""
                pr.replaceViewStr2 = ""
                pr.searchResultItemNames.removeAll()
                pr.searchResultCount = 0
            }
        }
        
    }
}

struct SwiftUIViewReplace_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseItemsReplaceView(firstTimePushAppear: true)
            .environmentObject(ExpenseModel())
    }
}
