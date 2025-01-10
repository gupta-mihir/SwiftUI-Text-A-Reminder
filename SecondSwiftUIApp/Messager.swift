//
//  Untitled.swift
//  SecondSwiftUIApp
//
//  Created by idia dev on 12/22/24.
//

import SwiftUI
import MessageUI


struct MessageComposeView: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    var recipients: [String]
    var messageBody: String
    var onSent: (() -> Void)? //callback when the message is sent

    class Coordinator: NSObject, MFMessageComposeViewControllerDelegate {
        var parent: MessageComposeView

        init(parent: MessageComposeView) {
            self.parent = parent
        }

        func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
            controller.dismiss(animated: true) {
                        
                switch result {
                case .sent:
                    print("Message sent successfully.")
                    self.parent.onSent?() //notify parent view when message is sent
                case .cancelled:
                    print("Message sending cancelled.")
                case .failed:
                    print("Failed to send message.")
                @unknown default:
                    print("Unknown result.")
                }
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> MFMessageComposeViewController {
        
        let controller = MFMessageComposeViewController()
        controller.recipients = recipients
        print("These are the recipients: \(String(describing: controller.recipients))")
        controller.body = messageBody
        print("This is the message body: \(String(describing: controller.body))")
        controller.messageComposeDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: MFMessageComposeViewController, context: Context) {
        // No updates needed
    }
}
