//
//  MainView.swift
//  aCh01
//
//  Created by user on 2022/3/1.
//

import SwiftUI

struct MainView: View {
    @StateObject var pr = ExpenseModel()
    @StateObject var subModel = SubscriptionModel()

    var body: some View {
        
        TabView {
            ExpenseEnterView()
                .tabItem {
                    Image(systemName: "square.and.pencil")
                    Text("記帳")
                }.tag(1)
            
            ExpenseDetailView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("花費篩選")
                }.tag(2)
            ExpenseDetailGroupView()
                .tabItem {
                    Image(systemName: "tray.2")
                    Text("花費群組")
                }.tag(3)
            
            SubscriptionView()
                .tabItem {
                    Image(systemName: "checkmark.seal")
                    Text("訂閱週期")
                }.tag(4)
            
            ExportShareView()
                .tabItem {
                    Image(systemName: "square.and.arrow.up.circle")
                    Text("匯出")
                }.tag(5)
        }
        .disabled(pr.disableTabView)
        .environmentObject(pr)
        .environmentObject(subModel)
        .onAppear() {
            UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        }
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(SubscriptionModel())
            .environmentObject(ExpenseModel())
    }
}
