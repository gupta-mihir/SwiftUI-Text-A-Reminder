//
//  Appointments.swift
//  SecondSwiftUIApp
//
//  Created by idia dev on 12/20/24.
//
import SwiftData
import Foundation

@Model
class Appointments: Identifiable, ObservableObject {
    var id : String
    var name: String
    var date: Date
    var duration: Int // Duration in minutes
    var phoneNumber: String
    var reminderSent: Bool
    var contactImage: Data? //New property for storing image data
    
    init(name: String, date: Date, duration: Int, phoneNumber: String, reminderSent: Bool, contactImage: Data?) {
        self.id = UUID().uuidString
        self.name = name
        self.date = date
        self.duration = duration
        self.phoneNumber = phoneNumber
        self.reminderSent = false
        self.contactImage = contactImage
    }
}
