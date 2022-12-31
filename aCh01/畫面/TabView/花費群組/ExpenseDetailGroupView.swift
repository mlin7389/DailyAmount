//
//  ExpenseGroupView1.swift
//  aCh01
//
//  Created by user on 2022/4/4.
//

import SwiftUI
import Combine

struct ExpenseDetailGroupView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var pr : ExpenseModel
    @FocusState private var focused : Bool
    @State var showAllDateNotify : Bool = false
    @State var showPivotView : Bool = false

    var body: some View {
        
        NavigationStack {
            
            VStack {

                DisclosureGroup (isExpanded: $pr.groupViewDisclosureGroup, content: {
                    
                    //快速日期選擇
                    HStack {
                        Text("快速日期選擇：")
                        Picker("quickPickerDate2", selection: $pr.quickPickerDate2) {
                            ForEach(QuickPickerDate.allCases, id: \.self) { type in
                                Text("\(type.rawValue)").tag(type.rawValue)
                            }
                        }
                        .onChange(of: pr.quickPickerDate2, perform: { value in
                            focused = false
                            if value == .allDays {
                                showAllDateNotify = true
                            }
                            else {
                                pr.updateSearchDate2()
                            }
                        })
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    }
                    
                    //日期區間選擇
                    HStack{
                        DatePicker("",selection: $pr.groupViewSelectDate1, displayedComponents: .date)
                            .padding(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
                            .labelsHidden()
                            .environment(\.locale, Locale.init(identifier: "zh_TW"))
                            .onChange(of: pr.groupViewSelectDate1, perform: { value in
                                focused = false
                            })
                        Text("～")
                            .font(.cusTextField())
                            .bold()
                            .frame(width: 30)
                            .alert(isPresented: $showAllDateNotify) {
                                Alert(title: Text("訊息"), message: Text("若資料量較多，例如:有數年的資料，畫面可能會稍有延遲。"), dismissButton: .destructive(Text("確定")) {
                                    pr.updateSearchDate2()
                                })
                            }
                        DatePicker("",selection: $pr.groupViewSelectDate2, displayedComponents: .date)
                            .padding(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
                            .labelsHidden()
                            .environment(\.locale, Locale.init(identifier: "zh_TW"))
                            .onChange(of: pr.groupViewSelectDate2, perform: { value in
                                focused = false
                            })
                    }
                    .padding(EdgeInsets(top: 0, leading: 6, bottom: -1, trailing: 6))
                    
                    //合併方式
                    Picker("groupMergeType", selection: $pr.groupViewMergeType) {
                        ForEach(GroupMergeType.allCases, id: \.self) { type in
                            Text("\(type.rawValue)").tag(type.rawValue)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: pr.groupViewMergeType, perform: { value in
                        focused = false
                        pr.reloadGroupExpenseData()
                    })
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    
                    //合併方式-日期顯示方式
                    Picker("groupMergeTypeByDate", selection: $pr.groupMergeTypeByDate) {
                        ForEach(GroupMergeTypeByDate.allCases, id: \.self) { type in
                            Text("\(type.rawValue)").tag(type.rawValue)
                            
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: pr.groupMergeTypeByDate, perform: { value in
                        focused = false
                        pr.reloadGroupExpenseData()
                    })
                    .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    
                    //搜尋項目名稱
                    TextField("搜尋項目名稱",text: $pr.srchGroupViewItemName)
                        .font(.cusTextField())
                        .focused($focused)
                        .padding(EdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6))
                        .border(Color.gray)
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    
                    
                    //顯示排序按鈕
                    if pr.groupExpenseItems.count > 0 {
                        HStack {
                            Button(action: {
                                focused = false
                                pr.groupView_sort_Order_DESC.toggle()
                                pr.groupView_sort_Field_Amount = false
                                pr.sort_GroupDetailViewItems()
                            }, label: {
                                Image(systemName: "arrow.up.arrow.down")
                            })
                            
                            Spacer()
                            Text(pr.group_Order_DESCString())
                                .font(.system(size: 14))
                                .foregroundColor(Color.cusLightBlue)
                            Spacer()
                            Button(action: {
                                focused = false
                                pr.groupView_sort_Order_DESC.toggle()
                                pr.groupView_sort_Field_Amount = true
                                pr.sort_GroupDetailViewItems()
                            }, label: {
                                Image(systemName: "arrow.up.arrow.down")
                            })
                        }
                        .padding(EdgeInsets(top: 2, leading: 20, bottom: 2, trailing: 20))
                    }
                    
                }, label: {
                    
                    VStack (alignment: .leading) {
                        if pr.groupViewDisclosureGroup == false {
                            Text(pr.group_Conditions_String1())
                            Text(pr.group_Conditions_String2())
                        }
                        else {
                            Text("花費群組篩選")
                        }
                    }
                    .font(.system(size: 16))
                })
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
      

                
                if pr.sqlModel.demoDBMode == true {
                    Text("學習模式資料")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .background(Color.red)
                }
               
                if pr.groupViewMergeType == .GroupByDate {
                    List {
                        ForEach(pr.groupExpenseItems, id:\.self) { item in
                            HStack {
                                if item.extraName == "" {
                                    Text(item.purhaseDateString)
                                        .textSelection(.enabled)
                                }
                                else {
                                    Text(item.extraName)
                                        .textSelection(.enabled)
                                }
                                
                                Spacer()
                                Text("\(item.totalAmountInt)")
                                
                            }
                            .padding(EdgeInsets(top: 10, leading: 06, bottom: 10, trailing: 5))
                        }
                        
                    }
                    .listStyle(.plain)
                    
                }
                else {
                    List {
                        ForEach(pr.groupExpenseItems, id:\.self) { item in
                            VStack {
                                HStack {
                                    Text(item.itemName)
                                        .textSelection(.enabled)
                                        .font(.cusListTitle())
                                    Spacer()
                                }
                                ForEach(item.subExpenseItems, id:\.self) { subItem in
                                    HStack {
                                        if subItem.extraName == "" {
                                            Text(subItem.purhaseDateString)
                                        }
                                        else {
                                            Text(subItem.extraName)
                                        }
                                        Spacer()
                                        if subItem.isLastItem {
                                            Text("合計：\(subItem.totalAmountInt)")
                                                .foregroundColor(Color.cusDrakRed)
                                                .bold()
                                        }
                                        else if subItem.isLastItem2 {
                                            Text("平均：\(subItem.totalAmountInt)")
                                                .foregroundColor(Color.cusPurle(cs: colorScheme))
                                                .bold()
                                        }
                                        else {
                                            Text("\(subItem.totalAmountInt)")
                                        }
                                    }
                                    .font(.cusListSubTitle())
                                    .foregroundColor(Color.cusDarkGray)
                                    .padding(EdgeInsets(top: 2, leading: 6, bottom: 2, trailing: 6))
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .onTapGesture(perform: {
                        focused = false
                    })
                }
                
                if pr.groupViewMergeType == .GroupByDate {
                    VStack {
                        HStack {
                            Text("合計")
                                .foregroundColor(Color.cusDrakRed)
                                .bold()
                            Spacer()
                            Text("$\(pr.groupByDateTotal)")
                                .foregroundColor(Color.cusDrakRed)
                                .bold()
                        }
                        Divider()
                        HStack {
                            Text("平均")
                            Spacer()
                            Text("$\(pr.groupByDateAvg)")
                        }
                        .foregroundColor(Color.cusPurle(cs: colorScheme))
                    }
                    
                    .padding()
                    .font(.cusListTitle())
                }
                Spacer()
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
   
}

struct ExpenseGroupView1_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseDetailGroupView()
            .environmentObject(ExpenseModel())
    }
}
