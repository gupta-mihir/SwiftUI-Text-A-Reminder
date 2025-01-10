//
//  ContentView.swift
//  SecondSwiftUIApp
//
//  Created by idia dev on 12/20/24.
//

import SwiftUI
import SwiftData

import MessageUI
import UserNotifications

struct ContentView: View {
    @Environment(\.modelContext) private var context
    
    //@State private var appointments: [Appointments] = []
    @State private var isAddingAppointment = false
    @State private var isEdittingAppointment = false
    @State private var isCheckingGraph = false
    
    @State private var selectedItem: Appointments?
    @State private var appointmentToEdit: Appointments? // Holds the appointment being edited

    
    @State private var showingMessageCompose = false
    @State private var currentRecipient = ""
    @State private var currentMessageBody = ""
    @State private var currentIndex = 0
    
    @Query private var appointments: [Appointments]

    var body: some View {
        
        NavigationSplitView {
            List {
                Section {
                    let activeAppointments = appointments.filter { $0.date >= Date() }.sorted { $0.date < $1.date }
                    
                    if activeAppointments.isEmpty {
                        Text("No active appointments")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(activeAppointments) { appointment in
                            appointmentRow(appointment)
                        }
                    }
                }
                                
            }
            // Button for Sending Text Reminders
            Button(action: sendTextReminders) {
                Text("Text Reminders")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            
           
            
            .padding()
            
            .toolbar {
                ToolbarItem {
                    
                    Button(action:
                            {isAddingAppointment.toggle()}
                                               ) {
                        Label("Add Item", systemImage: "plus")
                    }
                    
                    
                }
                ToolbarItem{
                    Button(action:
                            {isCheckingGraph.toggle()}
                                               ) {
                        Label("See Graph", systemImage: "chart.xyaxis.line")
                    }
                }
            }
            .sheet(isPresented: $isCheckingGraph) {
                AppointmentGraphView()
    
            }
            .sheet(isPresented: $isAddingAppointment) {
                NewAppointmentView { newAppointment in
                    //appointments.append(newAppointment)
                    context.insert(newAppointment)
                    print("Saveing data to context")
                    //try? context.save()
                    print("Data saved Succefully")
                    
                }
            }
            
            .onAppear()
            {
                requestNotificationPermission()
                handleDailyNotification(appointments: appointments)
            }
            .sheet(item: $appointmentToEdit) { appointment in
                EditAppointmentView(appointments: appointment)
            }
            
            
            .sheet(isPresented: $showingMessageCompose) {
                if !currentRecipient.isEmpty && !currentMessageBody.isEmpty {
                    MessageComposeView(
                        recipients: [currentRecipient],
                        messageBody: currentMessageBody
                    ) {
                        // Update reminderSent after sending
                        let pendingAppointments = appointments.filter { !$0.reminderSent && $0.date >= Date() }.sorted { $0.date < $1.date }
                        
                        if currentIndex < pendingAppointments.count {
                            let appointment = pendingAppointments[currentIndex]
                            appointment.reminderSent = true
                            try? context.save()
                            currentIndex += 1
                            sendTextReminders() // Proceed to the next reminder
                        }
                    }
                } else {
                    Text("Error: No valid recipients or message body")
                }
            }
            .navigationTitle("Appointments")

        } detail: {
            Text("Select an item")
        }
    }
    
    private func deleteItem(_ item: Appointments){
        context.delete(item)
    }
    
    private func updateItem(_ item: Appointments){
        item.name = "Updated Name"
        try? context.save()
    }
    /// Creates a row with swipe actions for an appointment.
    private func appointmentRow(_ appointment: Appointments) -> some View {
        Button(action: {
            selectedItem = appointment
            appointmentToEdit = appointment
            }) { HStack {
            VStack(alignment: .leading) {
                Text(appointment.name)
                    .font(.headline)
                Text(appointment.date, style: .date)
                    .font(.subheadline)
                Text(appointment.date, style: .time)
                    .font(.subheadline)
            }
            Spacer()
            if appointment.reminderSent {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2) // Adjust size as needed
            }
        }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                deleteItem(appointment)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)

            Button {
                appointmentToEdit = appointment
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        /*.sheet(isPresented: $isEdittingAppointment, onDismiss: {
            // Reset the selected appointment after dismissal
            selectedItem = nil
        }) {
            if let selectedItem = selectedItem {
                EditAppointmentView(
                    appointment: selectedItem,
                    onSave: { updatedAppointment in
                        // Update the appointment in your data source
                        //updateAppointment(updatedAppointment)
                        if let index = appointments.firstIndex(where: { $0.id == updatedAppointment.id }) {
                            //appointments[index] = updatedAppointment
                            context.delete(appointments[index])
                            context.insert(updatedAppointment)
                            print("Saveing data to context")
                            try? context.save()
                            print("Data saved Succefully")
                        }
                    }
                )
            }
        } */
    }
    private func updateAppointment(_ updatedAppointment: Appointments) {
        do {
            // Directly modify the passed object
            updatedAppointment.name = updatedAppointment.name
            updatedAppointment.date = updatedAppointment.date
            updatedAppointment.duration = updatedAppointment.duration
            updatedAppointment.phoneNumber = updatedAppointment.phoneNumber
            updatedAppointment.reminderSent = false // Reset reminder

            // Save the context
            print("Updating data in context")
            print(updatedAppointment.name)
            print(appointments.map { "\($0.name), \($0.date), \($0.duration)" })

            //try context.save()
            print("Data updated successfully")
        } catch {
            print("Failed to update appointment: \(error)")
        }
    }

/*
    private func sendTextReminders() {
        guard MFMessageComposeViewController.canSendText() else {
            print("Messaging not supported on this device")
            return
        }

        if let lastAppointment = items.last {
            currentRecipient = lastAppointment.phoneNumber
            print("First Appointment phone number: \(currentRecipient)")
            currentMessageBody = """
            Hello \(lastAppointment.name),
            This is a reminder for your appointment on \(lastAppointment.date.formatted(.dateTime)) for \(lastAppointment.duration) minutes.
            """
            print("First appointment message body: \(currentMessageBody)")
            showingMessageCompose = true
        }
        else{
            print("no appointments found")
        }
    }
 */
    private func sendTextReminders() {
        guard MFMessageComposeViewController.canSendText() else {
            print("Messaging not supported on this device")
            return
        }

        // Filter and sort pending appointments once
        let pendingAppointments = appointments.filter { !$0.reminderSent && $0.date >= Date() }
                                              .sorted { $0.date < $1.date }

        guard !pendingAppointments.isEmpty else {
            print("No pending reminders to send.")
            return
        }

        // Start processing reminders
        processNextReminder(from: pendingAppointments)
    }

    private func processNextReminder(from pendingAppointments: [Appointments]) {
        guard currentIndex < pendingAppointments.count else {
            print("All reminders sent.")
            currentIndex = 0 // Reset index for future use
            showingMessageCompose = false
            return
        }

        let currentAppointment = pendingAppointments[currentIndex]
        currentRecipient = currentAppointment.phoneNumber
        currentMessageBody = """
        Hello \(currentAppointment.name),
        This is a reminder for your appointment on \(currentAppointment.date.formatted(.dateTime)) for \(currentAppointment.duration) minutes.
        """

        if currentRecipient.isEmpty || currentMessageBody.isEmpty {
            print("Invalid data for appointment \(currentIndex + 1). Skipping...")
            currentIndex += 1
            processNextReminder(from: pendingAppointments)
        } else {
            print("Preparing message for appointment \(currentIndex + 1): \(currentMessageBody)")
            showingMessageCompose = true
        }
    }

    private func onMessageComposeDismissed(from pendingAppointments: [Appointments]) {
        // Mark the current appointment as processed
        let currentAppointment = pendingAppointments[currentIndex]
        currentAppointment.reminderSent = true // Mark reminder as sent
        try? context.save() // Save context if using CoreData or SwiftData

        // Move to the next appointment
        currentIndex += 1
        processNextReminder(from: pendingAppointments)
    }

    
    //MARK: - Push Notification Integration

    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permissions granted.")
            } else if let error = error {
                print("Error requesting notification permissions: \(error)")
            }
        }
    }
    
    func pendingAppointmentsCount(from appointments: [Appointments]) -> Int {
        let now = Date()
        print("the number of pending appointments is \(appointments.filter { !$0.reminderSent && $0.date > now }.count)")
        return appointments.filter { !$0.reminderSent && $0.date > now }.count
    }

    func scheduleDailyReminderNotification(pendingCount: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Daily Reminder"
        content.body = "You have \(pendingCount) appointments to send reminders for today."
        content.sound = .default

        // Create a trigger for the next morning at 9 AM
   //     var dateComponents = DateComponents()
   //     dateComponents.hour = 9
   //     let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60, repeats: true)

        // Create a unique identifier for the notification
        let identifier = "dailyReminderNotification"

        // Create the request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        // Schedule the notification
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier]) // Avoid duplicates
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully!")
            }
        }
    }
    func handleDailyNotification(appointments: [Appointments]) {
        let pendingCount = pendingAppointmentsCount(from: appointments)
        if pendingCount > 0 {
            scheduleDailyReminderNotification(pendingCount: pendingCount)
        }
    }


}





#Preview {
    ContentView()
        .modelContainer(for: Appointments.self)
}






