//
//  String.swift
//  ULTRA
//
//  Created by  Artem Mazheykin on 10.03.2018.
//  Copyright © 2018 Morodin. All rights reserved.
//

import Foundation

extension String{
    
    func getSongId() -> String{
        
        let components = self.components(separatedBy: ".0")
        if components.count > 1{
            return components.first!
        }
        return ""
    }
}

extension DateFormatter {
    
    convenience init (format: String) {
        self.init()
        dateFormat = format
        locale = Locale.current
    }
}

extension String {
    
    func toDate (format: String) -> Date? {
        return DateFormatter(format: format).date(from: self)
    }
    
    func toDateString (inputFormat: String, outputFormat:String) -> String? {
        if let date = toDate(format: inputFormat) {
            return DateFormatter(format: outputFormat).string(from: date)
        }
        return nil
    }
    
    func toDateComponents() -> DateComponents?{
        
        let format = "dd.MM.yyyy'T'HH:mm:ss"
        
        if let date = toDate(format: format){
            
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.day,.month,.year,.hour,.minute,.second], from: date)
            return dateComponents
        }
        
        return nil
    }
    
}

extension Date {
    
    func toString (format:String) -> String? {
        return DateFormatter(format: format).string(from: self)
    }
    
    func extractYearMonthDayHourMinuteSecond() -> (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int)?{
        
        let calendar = Calendar.current
        let dateComponent = calendar.dateComponents([.day,.month,.year,.hour,.minute,.second], from: self)
        if let day = dateComponent.day, let month = dateComponent.month, let year = dateComponent.year, let hour = dateComponent.hour, let minute = dateComponent.minute, let second = dateComponent.second{
            return (year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        }
        
        
        return nil
    }
    
    func toDateComponents() -> DateComponents{
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.day,.month,.year,.hour,.minute,.second], from: self)
        return dateComponents
    }
    
}
