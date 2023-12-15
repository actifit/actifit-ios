//
//  Date+Extension.swift
//  Actifit
//
//  Created by Hitender kumar on 31/08/18.
//  Copyright © 2018 actifit.io. All rights reserved.
//

import Foundation

extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
    func dateComponents(components: Set<Calendar.Component> = [.day, .month, .year]) -> DateComponents {
        let calendar = Calendar.current
        return calendar.dateComponents(components, from: self)
    }
    
    func dateString(withFormat format: String = "yyyy-MM-dd") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func dateTimeString(withFormat format: String = "yyyy-MM-dd hh:mm") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    func getTodaysDateWithMonthAndDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d, yyyy"
        return dateFormatter.string(from: Date())
    }
    
    func getTodaysDateYearAndMonthAndDay() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: Date())
    }
    
 
    func dayAfter () -> Date {
            let oneDay:Double = 60 * 60 * 24
            return addingTimeInterval(oneDay) as Date
        }
    func dayBefor () -> Date {
            let oneDay:Double = 60 * 60 * 24
            return addingTimeInterval(-(Double(oneDay))) as Date
        }
    
    public func setTime(hour: Int, min: Int, sec: Int) -> Date? {
        let x: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let cal = Calendar.current
        var components = cal.dateComponents(x, from: self)

        //components.timeZone = NSTimeZone.local //TimeZone(abbreviation: timeZoneAbbrev)
        components.hour = hour
        components.minute = min
        components.second = sec

        return cal.date(from: components)
    }
    
    func currentDay() -> String {
           let dateFormatter = DateFormatter()
           dateFormatter.dateFormat = "dd"
           
           return dateFormatter.string(from: self)
       }
    
    static func convertServerDateString(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

        if let date = dateFormatter.date(from: dateString) {
            let outputDateFormatter = DateFormatter()
            outputDateFormatter.dateFormat = "yyyy-MM-dd"
            return outputDateFormatter.string(from: date)
        } else {
            return nil
        }
    }
    
    func compareDates(dateString1: String, dateString2: String) -> ComparisonResult? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date1 = dateFormatter.date(from: dateString1),
           let date2 = dateFormatter.date(from: dateString2) {
            return date1.compare(date2)
        }
        
        return nil // Return nil in case of invalid date strings
    }
    
    func dateDifferenceByNumberOfDates(startDate: String, endDate: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if let startDate = dateFormatter.date(from: startDate),
           let endDate = dateFormatter.date(from: endDate) {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: startDate, to: endDate)
            return components.day
        }
        
        return nil  // Return nil if date parsing fails
    }
    
    
}
   

