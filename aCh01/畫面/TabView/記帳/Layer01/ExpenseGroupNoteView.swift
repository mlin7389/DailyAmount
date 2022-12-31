//
//  ExpenseGroupNoteView.swift
//  aCh01
//
//  Created by user on 2022/10/1.
//

import SwiftUI


struct ExpenseGroupNoteView: View {
    
    @EnvironmentObject var pr : ExpenseModel
    @Environment(\.colorScheme) var colorScheme
    
    @State var myFunc:(() -> Void)
    @State var showMessage = false
    var body: some View {
        VStack {
            HStack {
                Button {
                    showMessage = true
                } label: {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 18))
                        .foregroundColor(Color.orange)
                }
                .alert(isPresented: $showMessage) {
                    Alert(title: Text("訊息"), message: Text("按群組清單的「新增所有」，一次會新增所有群組內的清單項目"), dismissButton: .default(Text("知道了")))
                }
                .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 0))
                Text("快速群組新增清單")
                    .padding(EdgeInsets(top: 4, leading: 10, bottom: 4, trailing: 0))
                Spacer()
                Button {
                    myFunc()
                } label: {
                    HStack{
                        Image(systemName: "arrowshape.turn.up.backward.2")
                            .font(.system(size: 24))
                        Text("新增所有")
                    }
                    .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 10))
                }
            }
            .background(colorScheme == .dark ? Color.cusDarkGray2 : Color.cusLightGray)
            
            List {
                ForEach(pr.pickGroupNames, id:\.self) { item in
                    HStack {
                        Text(item.name)
                        Spacer()
                        Text("\(item.amount)")
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button {
                            pr.deletePickGroupName(item: item)
                        } label: {
                            Text("刪除")
                        }
                        .tint(.red)
                    }
                    .font(.system(size: 18))
                    .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 5))
                }
            }
            .listStyle(.plain)
            //.animation(.default, value: UUID())
        }
    }
}

struct ExpenseGroupNoteView_Previews: PreviewProvider {
    static var previews: some View {
        ExpenseGroupNoteView(){
            
        }
            .environmentObject(ExpenseModel())
    }
}
