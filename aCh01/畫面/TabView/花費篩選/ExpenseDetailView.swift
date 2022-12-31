//
//  ExpenseDetailView.swift
//  aCh01
//
//  Created by user on 2022/3/1.
//

import SwiftUI

struct ExpenseDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var pr : ExpenseModel
    
    @FocusState private var focused : Bool

    @State private var showAllDateNotify : Bool = false

    
    init() {
        UISegmentedControl.appearance().setTitleTextAttributes([
            .font: UIFont.systemFont(ofSize: 16),
        ], for: .normal)
    }

    var body: some View {
        
        NavigationStack {
            VStack {
                
                DisclosureGroup (isExpanded: $pr.disclosureGroupIsExpanded, content: {
                    
                    //快速日期選擇
                    HStack {
                        Text("快速日期選擇：")
                        Picker("quickPickerDate", selection: $pr.quickPickerDate) {
                            ForEach(QuickPickerDate.allCases, id: \.self) { type in
                                Text("\(type.rawValue)").tag(type.rawValue)
                            }
                        }
                        .onChange(of: pr.quickPickerDate, perform: { value in
                            if value == .allDays {
                                showAllDateNotify = true
                            }
                            else {
                                pr.updateSearchDate()
                            }
                        })
                        .alert(isPresented: $showAllDateNotify) {
                            Alert(title: Text("訊息"), message: Text("若資料量較多，例如:有數年的資料，畫面可能會稍有延遲。"), dismissButton: .destructive(Text("確定")) {
                                pr.updateSearchDate()
                            })
                        }
                    }
                    
                    //起迄日期選擇
                    HStack{
                        DatePicker("",selection: $pr.detailViewSelectDate1, displayedComponents: .date)
                            .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                            .labelsHidden()
                            //.transformEffect(.init(scaleX: 0.7, y: 0.7))
                            .environment(\.locale, Locale.init(identifier: "zh_TW"))
                        Text("～")
                            .font(.cusTextField())
                            .bold()
                            .frame(width: 30)
                        DatePicker("",selection: $pr.detailViewSelectDate2, displayedComponents: .date)
                            .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                            .labelsHidden()
                            .environment(\.locale, Locale.init(identifier: "zh_TW"))
                    }
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: -1, trailing: 0))
                    
                    //篩選條件 : 名稱
                    HStack {
                        TextField("項目名稱",text: $pr.srchItemName)
                            .focused($focused)
                            .padding(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
                            .border(Color.gray)
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    .font(.cusTextField())
                    
                    //篩選條件 : 金額
                    HStack {
                        TextField("金額區間", text: $pr.srchMinAmount)
                            .focused($focused)
                            .padding(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
                            .keyboardType(.numberPad)
                            .border(Color.gray)
                        Text("～")
                        TextField("金額區間",text: $pr.srchMaxAmount)
                            .focused($focused)
                            .padding(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
                            .keyboardType(.numberPad)
                            .border(Color.gray)
                    }
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    .font(.cusTextField())
                    
                    
                    //清單群組顯示方式
                    HStack{
                        Picker("detailGroupType", selection: $pr.detailViewGroupType) {
                            ForEach(ExpenseDetailGroupType.allCases, id: \.self) { type in
                                Text("\(type.rawValue)").tag(type.rawValue)
                                
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: pr.detailViewGroupType, perform: { value in
                            pr.reloadDeatilViewExpenseItems()
                        })
                    }
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                    
                    //排序方式
                    if pr.detailViewExpenseItems.count > 0 {
                        HStack {
                            Button(action: {
                                focused = false
                                pr.sort_Order_DESC.toggle()
                                pr.detailViewItemsSortByName()
                            }, label: {
                                Image(systemName: "arrow.up.arrow.down")
                            })
                            Spacer()
                            Text(pr.detail_Order_DESCString())
                                .font(.system(size: 14))
                                .foregroundColor(Color.cusLightBlue)
                            Spacer()
                            Button(action: {
                                 focused = false
                                 pr.sort_Order_DESC.toggle()
                                pr.detailViewItemsSortByAmount()

                            }, label: {
                                Image(systemName: "arrow.up.arrow.down")
                            })
                        }
                        .padding(EdgeInsets(top: 2, leading: 20, bottom: 2, trailing: 20))
                    }
                    
                }, label: {
                    VStack (alignment: .leading) {
                        if pr.disclosureGroupIsExpanded == false {
                            Text(pr.detail_Conditions_String1())
                            Text(pr.detail_Conditions_String2())
                        }
                        else {
                            Text("花費篩選")
                        }
                    }
                    .font(.system(size: 16))
                })
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                
                //關閉鍵盤
                if focused == true {
                    Button(action: {
                        focused = false
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
                
                
                //列表清單
                List {
                    ForEach(pr.detailViewExpenseItems, id:\.self) { item in
                        
                        if pr.detailViewGroupType == .List {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("\(pr.detailViewItemName(item: item,displayType: pr.detailViewGroupType))")
                                        .textSelection(.enabled)
                                        .font(fontSize())
                                    Spacer()
                                    Text("$\(item.totalAmountInt)")
                                        .font(.cusListTitle())
                                }
                                .padding(EdgeInsets(top: 8, leading: 0, bottom: 6, trailing: 10))
                                
                                Text("\(pr.detailViewPurhaseDateString(item: item,displayType: pr.detailViewGroupType))")
                                    .font(.cusListSubTitle())
                                    .foregroundColor(.cusGray)
                            }
                            
                        }
                        else{
                            NavigationLink(value: item) {
                                
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("\(pr.detailViewItemName(item: item,displayType: pr.detailViewGroupType))")
                                            .textSelection(.enabled)
                                            .font(fontSize())
                                        Spacer()
                                        Text("$\(item.totalAmountInt)")
                                            .font(.cusListTitle())
                                    }
                                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10))
                                    
                                    
                                }
                            }
                        }
                       
                    }
                    .font(.cusListTitle())
                }
                .listStyle(.plain)
                .navigationDestination(for: ExpenseItem.self) { item in
                    ExpenseDetailSubView(selectItem: item)
                }
                
                Spacer()
                
                //底部合計
                VStack {
                    HStack {
                        Text("合計")
                            .foregroundColor(Color.cusDrakRed)
                            .bold()
                        Spacer()
                        Text("$\(pr.detailViewSubtotal)")
                            .foregroundColor(Color.cusDrakRed)
                            .bold()
                    }
                    Divider()
                    HStack {
                        Text("平均")
                        Spacer()
                        Text("$\(pr.detailViewAvg)")
                    }
                    .foregroundColor(Color.cusPurle(cs: colorScheme))
                   
                }
                
                .padding()
                .font(.cusListTitle())
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear() {
                
            }
        } .navigationViewStyle(StackNavigationViewStyle())
        
    }
    
    func fontSize() -> Font {
        switch (pr.detailViewGroupType) {
        case .List:
            return .cusListTitle()
        case.GroupByDate:
            return .cusListTitle()
        case .GroupByName:
            return .cusListTitle()
        }
    }
}

struct ExpenseDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseDetailView()
            .environmentObject(ExpenseModel())
    }
}
