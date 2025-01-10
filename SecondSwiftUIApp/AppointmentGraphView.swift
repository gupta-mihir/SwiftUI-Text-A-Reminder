//
//  Untitled.swift
//  SecondSwiftUIApp
//
//  Created by idia dev on 1/5/25.
import SwiftUI
import Charts
import _SwiftData_SwiftUI

struct AppointmentGraphView: View {
    @Query var appointments: [Appointments] // Fetch appointments from SwiftData

    var body: some View {
        VStack {
            Text("Appointment Duration by Date")
                .font(.headline)
                .padding()

            Chart {
                ForEach(appointments) { appointment in
                    BarMark(
                        x: .value("Date", appointment.date, unit: .day),
                        y: .value("Duration (min)", appointment.duration)
                    )
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartXAxis {
                AxisMarks(position: .bottom, values: .stride(by: .day)) {
                    AxisValueLabel(format: .dateTime.day(.defaultDigits))
                }
            }
            .padding()
        }
        .padding()
    }
}
struct AppointmentGraphView_Previews: PreviewProvider {
    static var previews: some View {
        AppointmentGraphView()
            .modelContainer(for: Appointments.self, inMemory: true) // Use an in-memory model container for preview
    }
}



