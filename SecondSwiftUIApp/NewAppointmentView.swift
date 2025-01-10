import SwiftUI
import ContactsUI
import EventKit

struct NewAppointmentView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    @State private var date: Date = Date()
    @State private var duration: Int = 60 // Default duration in minutes
    
    @State private var showingContactPicker = false
    @State private var eventStore = EKEventStore() // Event Store for calendar events
    
    var onSave: (Appointments) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Customer Details")) {
                    TextField("Name", text: $name)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    
                    Button("Pick from Contacts") {
                        showingContactPicker = true
                    }
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
                        let newAppointment = Appointments(name: name, date: date, duration: duration, phoneNumber: phoneNumber, reminderSent: false)
                        onSave(newAppointment)
                        addToCalendar(appointment: newAppointment) // Add appointment to calendar
                        dismiss()
                    }
                    .disabled(name.isEmpty || phoneNumber.isEmpty)
                }
            }
            .sheet(isPresented: $showingContactPicker) {
                ContactPicker { contact in
                    name = contact.name
                    phoneNumber = contact.phoneNumber
                }
            }
        }
    }
    
    /// Adds the appointment to the iOS calendar using EventKit
    private func addToCalendar(appointment: Appointments) {
        eventStore.requestFullAccessToEvents() { granted, error in
            guard granted else {
                print("Calendar access not granted: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            let event = EKEvent(eventStore: eventStore)
            event.title = appointment.name
            event.startDate = appointment.date
            event.endDate = Calendar.current.date(byAdding: .minute, value: appointment.duration, to: appointment.date)
            event.calendar = eventStore.defaultCalendarForNewEvents
            
            do {
                try eventStore.save(event, span: .thisEvent)
                print("Event added to calendar successfully!")
            } catch {
                print("Failed to save event to calendar: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - ContactPicker Integration

struct Contact {
    let name: String
    let phoneNumber: String
}

struct ContactPicker: UIViewControllerRepresentable {
    var onSelect: (Contact) -> Void
    
    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }
    
    class Coordinator: NSObject, CNContactPickerDelegate {
        var onSelect: (Contact) -> Void
        
        init(onSelect: @escaping (Contact) -> Void) {
            self.onSelect = onSelect
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            let name = [contact.givenName, contact.familyName].filter { !$0.isEmpty }.joined(separator: " ")
            let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
            onSelect(Contact(name: name, phoneNumber: phoneNumber))
        }
        
        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {}
    }
}
