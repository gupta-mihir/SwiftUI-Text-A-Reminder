//
//  NewAppointmentView.swift
//  FirstSwiftUIApp
//
//  Created by idia dev on 12/20/24.
//

import SwiftUI

struct NewAppointmentView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var date: Date = Date()
    @State private var duration: Int = 60 // Default duration in minutes
    @State private var phoneNumber: String = ""

    var onSave: (Appointment) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Customer Details")) {
                    TextField("Name", text: $name)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                }

                Section(header: Text("Appointment Details")) {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    Stepper(value: $duration, in: 15...240, step: 15) {
                        Text("Duration: \(duration) minutes")
                    }
                }
            }
            .navigationTitle("New Appointment")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newAppointment = Appointment(name: name, date: date, duration: duration, phoneNumber: phoneNumber)
                        onSave(newAppointment)
                        dismiss()
                    }
                    .disabled(name.isEmpty || phoneNumber.isEmpty)
                }
            }
        }
    }
}
