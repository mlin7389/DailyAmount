//
//  GroupViewModel.swift
//  aCh01
//
//  Created by user on 2022/9/25.
//

import Foundation

extension ExpenseModel {
    
    func reloadGroupExpenseData() {
        switch self.groupViewMergeType {
        case .GroupByName:
            loadGroupByName()
        case .GroupByDate:
            loadGroupByDate()
        }
        sort_GroupDetailViewItems()
    }
    
    func loadGroupByName() {
        groupExpenseItems = []
        self.loadGroupByNameWithDay()
    }
    
    func loadGroupByDate() {
        groupExpenseItems = []
        self.loadGroupByDateWithDay()
    }
    
    func loadGroupByNameWithDay() {

        var rootRow = ExpenseItem()
        let arr = sqlModel.queryExpenseItemForGroupNameDisplay(startDate: groupViewSelectDate1,
                                                               endDate: groupViewSelectDate2,
                                                               displayType: self.groupMergeTypeByDate,
                                                               srchString: self.srchGroupViewItemName)
        var tmpAmount = 0
        var tmpCount = 0
        for item in arr {
            
            if rootRow.itemName != item.itemName {
                
                if rootRow.itemName != "" {
                    
                    rootRow.totalAmount = String(tmpAmount)
                    if rootRow.subExpenseItems.count > 1 {
                        var footRow = ExpenseItem()
                        footRow.extraName = "　"
                        footRow.totalAmount = String(tmpAmount)
                        footRow.isLastItem = true
                        
                        rootRow.subExpenseItems.append(footRow)
                        rootRow.totalAmount = String(tmpAmount)
                        
                        var avg = 0
                        if tmpCount > 0 {
                            avg = tmpAmount / tmpCount
                        }
                        var footRow2 = ExpenseItem()
                        footRow2.extraName = "　"
                        footRow2.totalAmount = String(avg)
                        footRow2.isLastItem2 = true
                        
                        rootRow.subExpenseItems.append(footRow2)
                        
                    }

                    groupExpenseItems.append(rootRow)
                    tmpAmount = 0
                    tmpCount = 0
                }

                rootRow = item
            }
            
            var item_tmp = item
            switch self.groupMergeTypeByDate {
            case .Day:
                break
            case .Month:
                item_tmp.extraName = item_tmp.purhaseDateString.substring(to: 8)
            case .Season:
                break
            case .HalfYear:
                break
            case .Year:
                item_tmp.extraName = item_tmp.purhaseDateString.substring(to: 5)
            }
            tmpAmount += item_tmp.totalAmountInt
            tmpCount += 1
            rootRow.subExpenseItems.append(item_tmp)
           
        }
        rootRow.totalAmount = String(tmpAmount)
        
        if rootRow.subExpenseItems.count > 1 {
            var footRow = ExpenseItem()
            footRow.extraName = "　"
            footRow.totalAmount = String(tmpAmount)
            footRow.isLastItem = true
            
            rootRow.subExpenseItems.append(footRow)
            rootRow.totalAmount = String(tmpAmount)
           
            var avg = 0
            if tmpCount > 0 {
                avg = tmpAmount / tmpCount
            }
            
            var footRow2 = ExpenseItem()
            footRow2.extraName = "　"
            footRow2.totalAmount = String(avg)
            footRow2.isLastItem2 = true
            
            rootRow.subExpenseItems.append(footRow2)
        }
      
        groupExpenseItems.append(rootRow)
    }
    
    func reSortGroupExpenseItems(sortByAmount:Bool) {
        
        let cnt_root = groupExpenseItems.count - 1
 
        if cnt_root == -1 {
            return
        }
        
        for rootIndex in 0...cnt_root {
            
            if groupExpenseItems[rootIndex].subExpenseItems.count <= 1 {
                continue
            }
            
            let subCount = groupExpenseItems[rootIndex].subExpenseItems.count - 1
            
            let it_total = groupExpenseItems[rootIndex].subExpenseItems[subCount-1]
            let it_avg = groupExpenseItems[rootIndex].subExpenseItems[subCount]
            groupExpenseItems[rootIndex].subExpenseItems.removeLast()
            groupExpenseItems[rootIndex].subExpenseItems.removeLast()
            
            if sortByAmount == true {
                if groupView_sort_Order_DESC == true {
                    groupExpenseItems[rootIndex].subExpenseItems.sort {
                        $0.totalAmountInt > $1.totalAmountInt
                    }
                }
                else {
                    groupExpenseItems[rootIndex].subExpenseItems.sort {
                        $0.totalAmountInt < $1.totalAmountInt
                    }
                }
            }
            else {
                if groupView_sort_Order_DESC == true {
                    groupExpenseItems[rootIndex].subExpenseItems.sort {
                        $0.purhaseDate > $1.purhaseDate
                    }
                }
                else {
                    groupExpenseItems[rootIndex].subExpenseItems.sort {
                        $0.purhaseDate < $1.purhaseDate
                    }
                }
            }
           

            groupExpenseItems[rootIndex].subExpenseItems.append(it_total)
            groupExpenseItems[rootIndex].subExpenseItems.append(it_avg)
        }
    }
    
    func loadGroupByDateWithDay() {
      
        let arr = sqlModel.queryExpenseItemForGroupDateDisplay(startDate: groupViewSelectDate1,
                                                               endDate: groupViewSelectDate2,
                                                               displayType: self.groupMergeTypeByDate,
                                                               srchString: self.srchGroupViewItemName)
        var tmpAmount = 0
        for item in arr {

            var item_tmp = item
            switch self.groupMergeTypeByDate {
            case .Day:
                break
            case .Month:
                item_tmp.extraName = item_tmp.purhaseDateString.substring(to: 8)
            case .Season:
                break
            case .HalfYear:
                break
            case .Year:
                item_tmp.extraName = item_tmp.purhaseDateString.substring(to: 5)
            }
            
            tmpAmount += item_tmp.totalAmountInt
            groupExpenseItems.append(item_tmp)
        }
        
        groupByDateTotal = tmpAmount
        if groupExpenseItems.count >= 1 {
            groupByDateAvg = tmpAmount / groupExpenseItems.count
        }
        else {
            groupByDateAvg = 0
        }

    }
    
    internal func sort_GroupDetailViewItems() {
        
        if groupView_sort_Field_Amount == true {
            sort_GroupFieldOfAmount()
            reSortGroupExpenseItems(sortByAmount: true)
        }
        else {
            sort_GroupFieldOfName()
        }

    }
    
    func sort_GroupFieldOfAmount() {
        
        if groupView_sort_Order_DESC == true {
            groupExpenseItems.sort {
                $0.totalAmountInt > $1.totalAmountInt
            }
        }
        else {
            groupExpenseItems.sort {
                $0.totalAmountInt < $1.totalAmountInt
            }
        }
    }
    
    func sort_GroupFieldOfName() {
        
        if self.groupViewMergeType == .GroupByDate {
            sort_group_date_date()
        }
        else {
            sort_group_date_name()
        }
    }

    
   private func sort_group_date_date() {
        if groupView_sort_Order_DESC == true {
            groupExpenseItems.sort {
                $0.purhaseDate > $1.purhaseDate
            }
        }
        else {
            groupExpenseItems.sort {
                $0.purhaseDate < $1.purhaseDate
            }
        }
    }
    
    private func sort_group_date_name() {
        
        reSortGroupExpenseItems(sortByAmount: false)
        
        if groupView_sort_Order_DESC == true {
            groupExpenseItems.sort {
                $0.subExpenseItems[0].purhaseDate > $1.subExpenseItems[0].purhaseDate
            }
        }
        else {
            groupExpenseItems.sort {
                $0.subExpenseItems[0].purhaseDate < $1.subExpenseItems[0].purhaseDate
            }
        }
    }
  
    
    func group_Order_DESCString() -> String {
  
        if groupView_sort_Field_Amount == true {
            return groupView_sort_Order_DESC == true ? "依金額【大到小】排序" : " 依金額【小到大】排序"
        }
        else {
            return groupView_sort_Order_DESC == true ? "依日期【近到遠】排序" : "依日期【遠到近】排序"
        }
    }

    func group_Conditions_String1() -> String {

        let s3 = groupViewSelectDate1.DateStringType3()
        let s4 = groupViewSelectDate2.DateStringType3()
    
        return "\(s3) ~ \(s4)"
    }

    func group_Conditions_String2() -> String {
     
        let s1 = groupViewMergeType.rawValue
        let s2 = group_Order_DESCString()
        
    
        return "【\(s1)】\(s2)"
    }
    
}
