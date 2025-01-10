import SwiftUI
import ContactsUI

struct EditAppointmentView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var appointments: Appointments
    
    var body: some View {
        Form {
            Section(header: Text("Customer Details")) {
                TextField("Name", text: $appointments.name)
                TextField("Phone Number", text: $appointments.phoneNumber)
                    .keyboardType(.phonePad)
            }

            Section(header: Text("Appointment Details")) {
                DatePicker("Date", selection: $appointments.date, displayedComponents: [.date, .hourAndMinute])
                Stepper(value: $appointments.duration, in: 15...240, step: 15) {
                    Text("Duration: \(appointments.duration) minutes")
                }
            }
            Button("Send Reminder"){
                
            }
            Button("Save Changes") {
                dismiss()
            }
        }
        .navigationTitle("Edit Appointment")
    }
}

