//
//  SubscriptionView.swift
//  aCh01
//
//  Created by user on 2022/3/4.
//

import SwiftUI
import Combine


struct SubscriptionView: View {
    
    @EnvironmentObject var subModel : SubscriptionModel
    
    @StateObject  var navModelforSub = NavModelForSub()
    @Environment(\.colorScheme) var colorScheme
    @State var isEditMode: EditMode = .inactive
    
    var body: some View {
        NavigationStack (path: $navModelforSub.path) {
            VStack {
                
                if subModel.sqlModel.demoDBMode == true {
                    Text ("  ")
                    Text("學習模式資料")
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .foregroundColor(Color.white)
                        .background(Color.red)
                }
              

                if subModel.subscriptions.count == 0  {
                    HStack {
                        Image(systemName: "exclamationmark.shield")
                            .font(.system(size: 24))
                        Text("該功能用於記錄有週期性的花費，可以讓你記得每個月會噴多少錢出去😆")
                        
                    }
                    .foregroundColor(Color.cusDrakRed)
                    .padding()
                }
                
              
                List {
                    
                    ForEach(subModel.subscriptions, id:\.self) { item in
                        
                        NavigationLink(value: navModelforSub.newPath(subItem: item, viewType: .ShowDetail)) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("\(item.name)")
                                        .font(.cusListTitle())
                                        .textSelection(.enabled)
                                    Spacer()
                                    Text("$\(item.avgOfMonthAmountInt)")
                                        .font(.cusListTitle())
                                }
                                .padding(EdgeInsets(top: 8, leading: 0, bottom: 6, trailing: 10))
                                Text("\(item.cycleName) \(item.cycleNote) \(item.typeOfAmount_display)支出 \(item.amountInt)")
                                    .font(.cusListSubTitle())
                                    .foregroundColor(Color.cusDarkGray)
                            }}
                        
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            Button {
                                subModel.UpdateItem(item: item)
                                navModelforSub.appendPath(subItem: item, viewType: .AddandModeify)
                            } label: {
                                Text("修改")
                            }
                            .tint(.green)
                        }
                        
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button {
                                subModel.DeleteItem(item: item)
                            } label: {
                                Text("刪除")
                            }
                            .tint(.red)
                        }
                    }
                    .onMove(perform: move)
                }
                .environment(\.editMode, $isEditMode)
                .listStyle(.plain)
                
                Spacer()
                
                VStack {
                    Divider()
                    HStack {
                        Text("月支出：")
                        Spacer()
                        Text("$\(subModel.totalAvgOfMonthAmount)")
                    }
                    .bold()
                    .foregroundColor(Color.cusPurle(cs: colorScheme))
                }
                .padding()
                .foregroundColor(Color.cusDrakRed)
                .font(.cusListTitle())
                
            }
            .onAppear() {
                subModel.ViewModifyMode = false
            }
            .navigationBarTitle("訂閱及週期")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        
                        Button(action: {
                            switch isEditMode {
                            case .active:
                                self.isEditMode = .inactive
                            case .inactive:
                                self.isEditMode = .active
                            default:
                                break
                            }
                        }, label: {
                            if isEditMode == .inactive {
                                Image(systemName: "text.insert")
                            }
                            else {
                                Image(systemName: "text.append")
                                    .foregroundColor(Color.red)
                            }
                        })
                        
                        NavigationLink(destination: {
                            SubscriptionGroupView()
                        }, label: {
                            Image(systemName: "list.bullet.below.rectangle")
                        })
                        
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        subModel.subscriptionItem = Subscription()
                        navModelforSub.appendPath(subItem: subModel.subscriptionItem, viewType: .AddandModeify)
                    }, label: {
                        Image(systemName: "plus.square")
                    })
                }
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: NavModelForSub.NavPath.self) { path in
                switch(path.viewType) {
                case .AddandModeify :
                    SubscriptionNew(subItem: path.subItem)
                case .ShowDetail :
                    SubscriptionViewDetail(subItem: path.subItem)
                case .GroupPicker :
                    SubscriptionGroupView()
                case .AvgPicker :
                    CalcuateAvgView()
                case .NamePicker :
                   SubscriptionNamePickerView(firstTimePushAppear: true)
                case .CycleNamePicker :
                   CycleNamePickerView()
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .environmentObject(navModelforSub)
    }
    
    func move(from source: IndexSet, to destination: Int) {
        subModel.move(from: source, to: destination)
    }
    
}

struct SubscriptionView_Previews: PreviewProvider {
    static var previews: some View {
        SubscriptionView()
            .environmentObject(SubscriptionModel())
    }
}
