//
//  enum.swift
//  aCh01
//
//  Created by user on 2022/9/24.
//

import Foundation

let AMOUNT_LIMIT = 9

enum CallViewType {
    case ExpenseItems
    case Subscripttion
}

enum ImportFileType {
    case ExpenseItems
    case Subscripttion
}

enum QuickPickerDate: String, CaseIterable, Encodable, Decodable {
    case CusPick = "快速選擇"
    case Today = "本日"
    case LastDay  = "昨日"
    case Week  = "本週"
    case LastWeek  = "上週"
    case Month  = "本月"
    case LasMonth  = "上月"
    case year = "本年"
    case LastYear = "去年"
    case allDays = "全期間起迄"
}

enum ExpenseDetailGroupType: String, CaseIterable, Encodable, Decodable {
    case List  = "明細清單"
    case GroupByName = "合併項目"
    case GroupByDate  = "合併日期"
}

enum PivotSourceType: String, CaseIterable {
    case Subscription = "訂閱"
    case Year2022  = "2022"
    case Year2021  = "2021"
    case AllRange  = "全期間"
}

enum GroupMergeType: String, CaseIterable {
    case GroupByName = "合併項目"
    case GroupByDate  = "合併日期"
}

enum GroupMergeTypeByDate: String, CaseIterable {
    case Day = "日"
    case Month  = "月"
    case Season  = "季"
    case HalfYear  = "半年"
    case Year  = "年"
}

enum SearchType : String, CaseIterable  {
    case LikeSearch = "模糊"
    case FullSearch  = "完整"
}


enum PickerNameTable : String {
    case CycleName = "CycleName"
    case ExpenseItem = "ExpenseItem"
    case Subscription = "Subscription"
    case AppSettngs = "AppSettngs"
    case PickGroupExpenseItem = "PickGroupExpenseItem"
}

enum ExpenseItemSingleDate  {
    case FirstDate
    case LastDate
}

enum SettingNames : String {
    case detailViewDisclosureGroup = "detailViewDisclosureGroup"
    case detailViewSelectDate1 = "detailViewSelectDate1"
    case detailViewSelectDate2 = "detailViewSelectDate2"
    case detailViewsrchItemName = "detailViewsrchItemName"
    case detailViewsrchMinAmount = "detailViewsrchMinAmount"
    case detailViewsrchMaxAmount = "detailViewsrchMaxAmount"
    case detailViewExpenseDetailGroupType = "detailViewExpenseDetailGroupType"
    case detailViewSortDESC = "detailViewSortDESC"
    case detailViewSortAmount = "detailViewSortAmount"
    
    case groupViewDisclosureGroup = "groupViewDisclosureGroup"
    case groupViewSelectDate1 = "groupViewSelectDate1"
    case groupViewSelectDate2 = "groupViewSelectDate2"
    case groupViewsrchItemName = "groupViewsrchItemName"
    case groupMergeType = "groupMergeType"
    case groupViewMergeTypeByDate = "groupMergeTypeByDate"
    case groupViewSortDESC = "groupViewSortDESC"
    case groupViewSortAmount = "groupViewSortAmount"
    
    case notKeepAppSettings = "notKeepAppSettings"
    
    case autoAmountCount = "autoAmountCount"
    case firstTimeAdd = "fistTimeAdd"
    case initAppV1 = "initAppV1"
}

enum DateFormatError: Error {
    case dateFormatError
}
