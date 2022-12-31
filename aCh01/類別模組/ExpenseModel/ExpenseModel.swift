//
//  MoneyProvider.swift
//  aCh01
//
//  Created by user on 2022/2/28.
//

import Foundation
import UIKit

class ExpenseModel : ObservableObject {

    @Published  var sqlModel : SQLPorvider

    // MARK: - 初始化
    // MARK: -
    init() {
        sqlModel = SQLPorvider.shared
        mustReload = false
        initPass = true
        isSetByPicker = true
      

        //設定值屬性 DeatilView ===========================================================================
        self.disclosureGroupIsExpanded = true
        self.quickPickerDate = .Today

        self.enterViewExpenseItems  = sqlModel.queryExpenseItemByBetweenDate(Date.now, Date.now,.List)
        self.detailViewExpenseItems = sqlModel.queryExpenseItemByBetweenDate(detailViewSelectDate1, detailViewSelectDate2,.List)
        
        let disclosureGroupTmp = sqlModel.queryAppSetting(name: SettingNames.detailViewDisclosureGroup)
        self.disclosureGroupIsExpanded = disclosureGroupTmp == "true" ? true : false
        
        self.quickPickerDate = .CusPick
   
        let detailViewSelectDate1Tmp = sqlModel.queryAppSetting(name: SettingNames.detailViewSelectDate1)
        self.detailViewSelectDate1 = Date.DateStringType2ToDate(dateString: detailViewSelectDate1Tmp)
     
        let detailViewSelectDate2Tmp = sqlModel.queryAppSetting(name: SettingNames.detailViewSelectDate2)
        self.detailViewSelectDate2 = Date.DateStringType2ToDate(dateString: detailViewSelectDate2Tmp)

        self.srchItemName = sqlModel.queryAppSetting(name: SettingNames.detailViewsrchItemName)
        self.srchMaxAmount = sqlModel.queryAppSetting(name: SettingNames.detailViewsrchMaxAmount)
        self.srchMinAmount = sqlModel.queryAppSetting(name: SettingNames.detailViewsrchMinAmount)
        
        let detailViewExpenseDetailGroupTypeTmp = sqlModel.queryAppSetting(name: SettingNames.detailViewExpenseDetailGroupType)
        self.detailViewGroupType = ExpenseDetailGroupType(rawValue: detailViewExpenseDetailGroupTypeTmp) ?? .List

        let detailViewSortDESCTmp = sqlModel.queryAppSetting(name: SettingNames.detailViewSortDESC)
        self.sort_Order_DESC = detailViewSortDESCTmp == "true" ? true : false
        
        let detailViewSortAmountTmp = sqlModel.queryAppSetting(name: SettingNames.detailViewSortAmount)
        self.sort_Field_Amount = detailViewSortAmountTmp == "true" ? true : false
        
        reloadDeatilViewExpenseItems()
        //===============================================================================================

        
        //設定值屬性 GroupView ===========================================================================
   
        let groupViewDisclosureGroupTmp = sqlModel.queryAppSetting(name: SettingNames.groupViewDisclosureGroup)
        self.groupViewDisclosureGroup = groupViewDisclosureGroupTmp == "true" ? true : false

        self.quickPickerDate2 = .CusPick
        
        let groupViewSelectDate1Tmp = sqlModel.queryAppSetting(name: SettingNames.groupViewSelectDate1)
        self.groupViewSelectDate1 = Date.DateStringType2ToDate(dateString: groupViewSelectDate1Tmp)
        
        let groupViewSelectDate2Tmp = sqlModel.queryAppSetting(name: SettingNames.groupViewSelectDate2)
        self.groupViewSelectDate2 = Date.DateStringType2ToDate(dateString: groupViewSelectDate2Tmp)
        
        let groupViewsrchItemNameTmp = sqlModel.queryAppSetting(name: SettingNames.groupViewsrchItemName)
        srchGroupViewItemName = groupViewsrchItemNameTmp
        
        let groupMergeTypeTmp = sqlModel.queryAppSetting(name: SettingNames.groupMergeType)
        self.groupViewMergeType = GroupMergeType(rawValue: groupMergeTypeTmp) ?? .GroupByName
        
        let groupViewMergeTypeByDateTmp = sqlModel.queryAppSetting(name: SettingNames.groupViewMergeTypeByDate)
        self.groupMergeTypeByDate = GroupMergeTypeByDate(rawValue: groupViewMergeTypeByDateTmp) ?? .Day
        
        let groupViewSortDESCTmp = sqlModel.queryAppSetting(name: SettingNames.groupViewSortDESC)
        self.groupView_sort_Order_DESC = groupViewSortDESCTmp == "true" ? true : false
        
        let groupViewSortAmountTmp = sqlModel.queryAppSetting(name: SettingNames.groupViewSortAmount)
        self.groupView_sort_Field_Amount = groupViewSortAmountTmp == "true" ? true : false
      

        reloadGroupExpenseData()
        //===============================================================================================
        
        self.autoAmountCount = Int(sqlModel.queryAppSetting(name: SettingNames.autoAmountCount)) ?? 5
        
        
        let notKeepAppSettingsTmp = sqlModel.queryAppSetting(name: SettingNames.notKeepAppSettings)
        self.notKeepAppSettings = notKeepAppSettingsTmp == "true" ? true : false
        
        queryPickGroupName()
        
        self.initPass = false
        self.mustReload = true
    }
    
    // MARK: - 畫面設定值
    // MARK: -
    
    var initPass : Bool        //在init裡面的第二次更新屬性值時，不要觸發didset
    var mustReload : Bool      //用於View顯示的瞬間是否需要reload資料，不用每次切換畫面都reload
    var isSetByPicker : Bool   //如果是用戶自己選日期的話，畫面選項改為「手動選擇」
    
    @Published var autoAmountCount : Int = 10
    {
        didSet {
            if initPass == true {
                return
            }
            sqlModel.UpdateAppSetting(name: SettingNames.autoAmountCount, value: String(autoAmountCount))
        }
    }
    
    @Published var disclosureGroupIsExpanded : Bool {
        didSet {
            if initPass == true {
                return
            }
            let tmp = disclosureGroupIsExpanded == true ? "true" : "false"
            sqlModel.UpdateAppSetting(name: SettingNames.detailViewDisclosureGroup, value: tmp)
        }
    }
    
    @Published var quickPickerDate : QuickPickerDate {
        didSet {
            if initPass == true {
                return
            }
        }
    }

    @Published var detailViewSelectDate1 : Date = Date.now
    {
        didSet {
            if initPass == true {
                return
            }
            
            if mustReload == true {
                self.reloadDeatilViewExpenseItems()
            }
            
            if isSetByPicker == false {
                self.quickPickerDate = .CusPick
            }
            sqlModel.UpdateAppSetting(name: SettingNames.detailViewSelectDate1, value: detailViewSelectDate1.DateStringType2())
        }}
    
    @Published var detailViewSelectDate2 : Date = Date.now
    {
        didSet {
            
            if initPass == true {
                return
            }
            
            if mustReload == true {
                self.reloadDeatilViewExpenseItems()
            }
            
            if isSetByPicker == false {
                self.quickPickerDate = .CusPick
            }
            sqlModel.UpdateAppSetting(name: SettingNames.detailViewSelectDate2, value: detailViewSelectDate2.DateStringType2())
        }}

    // 梆定TextField didSet會進來兩次，第二次oldValue會與新值相同，忽略即可
    @Published var srchItemName : String = ""
    {
        didSet {
            if initPass == true {
                return
            }
            
            if oldValue != srchItemName {
                reloadDeatilViewExpenseItems()
                sqlModel.UpdateAppSetting(name: SettingNames.detailViewsrchItemName, value: srchItemName)
            }
            
        }
    }
    
    @Published var srchMinAmount : String = ""
    {
        didSet {
            if initPass == true {
                return
            }
            
            if oldValue != srchMinAmount {
                reloadDeatilViewExpenseItems()
                sqlModel.UpdateAppSetting(name: SettingNames.detailViewsrchMinAmount, value: srchMinAmount)
            }
        }
    }
    
    @Published var srchMaxAmount : String = ""
    {
        didSet {
            if initPass == true {
                return
            }
            
            if oldValue != srchMaxAmount {
                reloadDeatilViewExpenseItems()
                sqlModel.UpdateAppSetting(name: SettingNames.detailViewsrchMaxAmount, value: srchMaxAmount)
            }
        }
    }
    
    @Published var detailViewGroupType : ExpenseDetailGroupType = .List
    {
        didSet {
            if initPass == true {
                return
            }
            sqlModel.UpdateAppSetting(name: SettingNames.detailViewExpenseDetailGroupType, value: detailViewGroupType.rawValue)
        }
    }
    
    var sort_Field_Amount  : Bool = false
    {
        didSet {
            if initPass == true {
                return
            }
            let tmp = sort_Field_Amount == true ? "true" : "false"
            sqlModel.UpdateAppSetting(name: SettingNames.detailViewSortDESC, value: tmp)
        }
    }
    var sort_Order_DESC : Bool = false
    {
        didSet {
            if initPass == true {
                return
            }
            let tmp = sort_Order_DESC == true ? "true" : "false"
            sqlModel.UpdateAppSetting(name: SettingNames.detailViewSortAmount, value: tmp)
        }
    }
    

    func updateSearchDate() {
        self.isSetByPicker = true
        if self.quickPickerDate == .allDays {
            detailViewSelectDate1 = sqlModel.queryExpenseItemSingleDate(.FirstDate)
            detailViewSelectDate2 = sqlModel.queryExpenseItemSingleDate(.LastDate)
        }
        else if self.quickPickerDate == .CusPick {
            
        }
        else {
            let sd =  getRangeDateFromDic(self.quickPickerDate)
            self.detailViewSelectDate1 = sd.startDate
            self.detailViewSelectDate2 = sd.endDate
        }
        isSetByPicker = false
        self.quickPickerDate = .CusPick
    }
    
    var isSetByPicker2 : Bool = false
    var searchDateRangesDic : [QuickPickerDate:SearchDate] = MGGSearchDate.CalculateDate(Date.now)
    
    func updateSearchDate2() {
        self.isSetByPicker2 = true
        if self.quickPickerDate2 == .allDays {
            groupViewSelectDate1 = sqlModel.queryExpenseItemSingleDate(.FirstDate)
            groupViewSelectDate2 = sqlModel.queryExpenseItemSingleDate(.LastDate)
        }
        else if self.quickPickerDate2 == .CusPick {
            
        }
        else {
            let sd =  getRangeDateFromDic(self.quickPickerDate2)
            self.groupViewSelectDate1 = sd.startDate
            self.groupViewSelectDate2 = sd.endDate
        }
        isSetByPicker2 = false
        self.quickPickerDate2 = .CusPick
    }
    
    func getRangeDateFromDic(_ displayType:QuickPickerDate) -> SearchDate {
        let sd = searchDateRangesDic[.Today]!
        if sd.startDate.isNotSameDate(Date.now) {
            searchDateRangesDic = MGGSearchDate.CalculateDate(Date.now)
        }
        return searchDateRangesDic[displayType]!
    }
    
    
    
    //匯出資料過程暫時禁止TabView被按下
    @Published var disableTabView : Bool = false

    //新增花費畫面的日期選擇
    @Published var enterViewSelectedDate : Date =  Date.now
    {
        didSet {
            self.enterViewExpenseItem.purhaseDate = self.enterViewSelectedDate
            reloadEnterViewExpenseItems()
            reCalEnterViewSubTotal()
        }
    }
    
    //加減日期
    func changeDate(_ day:Int) {
        var dateComponent = DateComponents()
        dateComponent.day = day
        self.enterViewSelectedDate = Calendar.current.date(byAdding: dateComponent, to: self.enterViewSelectedDate)!
        reCalEnterViewSubTotal()
    }
    
    //新增項目檢核有誤訊息
    @Published var newItemErrorMessageFlg : Bool = false
    var newItemErrorMessage : String = ""
    
    //已有修改項目時，不可進行刪除及其它修改
    @Published var modifyModeMessageFlg : Bool = false
    
    
    // MARK: - 輸入畫面
    
    var itemName  = ""
    var itemAmount = ""
    @Published var enterViewExpenseItem : ExpenseItem = ExpenseItem()
    @Published var enterViewModifyMode : Bool = false
    @Published var enterViewSubtotal : Int = 0
    @Published var enterViewExpenseItems : [ExpenseItem] = []
    {
        didSet {
            reCalEnterViewSubTotal()
        }
    }
    
    // MARK: - 明細畫面
    var detailViewSubtotal : Int = 0
    var detailViewAvg : Int = 0
    
    @Published var detailViewExpenseItems : [ExpenseItem] = []
    {
        didSet {
            reCalDetailViewSubTotal()
        }
    }

    @Published var pickNameForSubscriptionItem : String = ""
    {
        didSet {
            self.loadExpenseNames2(text: pickNameForSubscriptionItem)
        }
    }
    
    @Published var expenseNames2 : [PickerName] = []

    
    // MARK: - 名稱挑選畫面

    @Published var pickGroupNames = [PickGroupExpenseItem]()
    var groupInsertCount = 0 
    
    ///花費項目名稱的清單，快速記帳挑選用
    @Published var expenseItemNames : [PickerName] = []

    ///避免進入畫面時重置變數DidSet時去觸發load資料
    var byassDidSetLoaditems = false
    
    @Published var searchItemNameContainText : String = "" {
        didSet {
            if byassDidSetLoaditems == false {
                self.loadExpensePickerNames(text: searchItemNameContainText,amount:searchItemAmountIsText)
                enterViewExpenseItem.itemName = searchItemNameContainText
            }
           
 
        }
    }
    
    @Published var searchItemAmountIsText : String = "" {
        didSet {
            if byassDidSetLoaditems == false {
                loadExpensePickerNames()
            }
        }
    }
    
    

    // MARK: - 明細清單詳細畫面
    
    var dsViewExpenseItems  : [ExpenseItem] = []
    var detailSubViewSubtotal : Int = 0

    @Published var pickerSelection : PickerName?
    
    @Published var detailGroupSelectItem : ExpenseItem? {
        willSet {
            if let value = newValue {
                if detailViewGroupType != .List {
                    raloadDetailItems(value)
                }
            }
        }
        didSet {
            if let _ = detailGroupSelectItem {
                if detailViewGroupType == .List {
                    detailGroupSelectItem = nil
                }
            }
        }
    }

    
    
    // MARK: - 群組檢視
    
    @Published var groupViewDisclosureGroup : Bool = true {
        didSet {
            if initPass == true {
                return
            }
            let tmp = groupViewDisclosureGroup == true ? "true" : "false"
            sqlModel.UpdateAppSetting(name: SettingNames.groupViewDisclosureGroup, value: tmp)
        }
    }
    
    @Published var quickPickerDate2 : QuickPickerDate = .Today {
        didSet {
            if initPass == true {
                return
            }
        }
    }

    @Published var groupViewSelectDate1 : Date = Date.now
    {
        didSet
        {
            if initPass == true {
                return
            }
            
            if mustReload == true {
                self.reloadGroupExpenseData()
            }
            
            if isSetByPicker2 == false {
                self.quickPickerDate2 = .CusPick
            }
            
            sqlModel.UpdateAppSetting(name: SettingNames.groupViewSelectDate1, value: groupViewSelectDate1.DateStringType2())
        }
    }

    @Published var groupViewSelectDate2 : Date = Date.now
    {
        didSet {
            if initPass == true {
                return
            }
            
            if mustReload == true {
                self.reloadGroupExpenseData()
            }
            
            if isSetByPicker2 == false {
                self.quickPickerDate2 = .CusPick
            }
            sqlModel.UpdateAppSetting(name: SettingNames.groupViewSelectDate2, value: groupViewSelectDate2.DateStringType2())
        }
    }
    
    @Published var groupViewMergeType : GroupMergeType = .GroupByName {
        didSet
        {
            if initPass == true {
                return
            }
            
            sqlModel.UpdateAppSetting(name: SettingNames.groupMergeType, value: groupViewMergeType.rawValue)
        }
    }
    
    @Published var groupMergeTypeByDate : GroupMergeTypeByDate = .Day {
        didSet
        {
            if initPass == true {
                return
            }
           
            sqlModel.UpdateAppSetting(name: SettingNames.groupViewMergeTypeByDate, value: groupMergeTypeByDate.rawValue)
        }
    }
    
    @Published var srchGroupViewItemName : String = ""
    {
        didSet {
            if initPass == true {
                return
            }
            
            if oldValue != srchGroupViewItemName {
              self.reloadGroupExpenseData()
            }
           
            sqlModel.UpdateAppSetting(name: SettingNames.groupViewsrchItemName , value: srchGroupViewItemName)
        }
    }
    

    @Published var groupExpenseItems : [ExpenseItem] = []
    @Published var groupViewShow : Bool = false
    @Published var groupByDateTotal : Int = 0
    @Published var groupByDateAvg : Int = 0
  

        
    var groupView_sort_Order_DESC : Bool = true
    {
        didSet {
            if initPass == true {
                return
            }
            let tmp = groupView_sort_Order_DESC == true ? "true" : "false"
            sqlModel.UpdateAppSetting(name: SettingNames.groupViewSortDESC, value: tmp)
        }
    }
    
    var groupView_sort_Field_Amount : Bool = false
    {
        didSet {
            if initPass == true {
                return
            }
            let tmp = groupView_sort_Field_Amount == true ? "true" : "false"
            sqlModel.UpdateAppSetting(name: SettingNames.groupViewSortAmount, value: tmp)
        }
    }
    

    
    // MARK: - 匯入匯出
    @Published var importFormatCheck = true
    
    var importExpenseItems = [ExpenseItem]()
    
    var importMessage : String = ""
    {
        didSet {
            if importMessage != "" {
                importMessageToExpenseItems()
            }
        }
    }
    
    @Published var notKeepAppSettings : Bool = false {
        didSet {
            if initPass == true {
                return
            }
            let tmp = notKeepAppSettings == true ? "true" : "false"
            sqlModel.UpdateAppSetting(name: SettingNames.notKeepAppSettings, value: tmp)
        }
    }

   
    
    // MARK: - 尋找與取代畫面
    
    @Published var replaceViewStr1 : String = ""
    @Published var replaceViewStr2 : String = ""
    @Published var replaceMinAmount : String = ""
    @Published var replaceMaxAmount : String = ""

    @Published var searchResultItemNames : [ExpenseItem] = []
    @Published var searchResultCount : Int = -1
    @Published var searchType : SearchType = .LikeSearch

    // MARK: - 訂閱及週期畫面的 詳細清單查詢
    
    @Published var subscriptionViewExpenseItems : [ExpenseItem] = []
    
    var subExpensetItemSubtotal : Int = 0
    var subExpenseItemAvg : Int = 0
    
    
 
    
}
