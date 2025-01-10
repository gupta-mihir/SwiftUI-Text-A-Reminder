import SwiftUI
import ContactsUI

struct EditAppointmentView: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var appointments: Appointments
    
    var body: some View {
        VStack{
            // Display customer image if available
            if let imageData = appointments.contactImage,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                    .padding(.top)
            } else {
                // Placeholder for missing image
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
                    .padding(.top)
            }
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
}

