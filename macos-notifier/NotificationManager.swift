import Foundation
import UserNotifications
import AppKit

class NotificationManager: NSObject {
    private let title: String
    private let content: String
    private let imagePath: String?
    private let activateBundleId: String?
    private var completionHandler: (() -> Void)?

    init(title: String, content: String, imagePath: String?, activateBundleId: String?) {
        self.title = title
        self.content = content
        self.imagePath = imagePath
        self.activateBundleId = activateBundleId
        super.init()
    }

    func sendNotification(completion: @escaping () -> Void) {
        self.completionHandler = completion
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error.localizedDescription)")
                completion()
                return
            }

            if !granted {
                print("Notification permission denied. Please enable notifications in System Settings.")
                completion()
                return
            }

            self.deliverNotification()
        }
    }

    private func deliverNotification() {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = content
        notificationContent.sound = .default

        if let imagePath = imagePath {
            let imageURL = URL(fileURLWithPath: (imagePath as NSString).expandingTildeInPath)

            if FileManager.default.fileExists(atPath: imageURL.path) {
                do {
                    let tempDir = FileManager.default.temporaryDirectory
                    let tempImageURL = tempDir.appendingPathComponent(UUID().uuidString + "." + imageURL.pathExtension)
                    try FileManager.default.copyItem(at: imageURL, to: tempImageURL)

                    let attachment = try UNNotificationAttachment(
                        identifier: UUID().uuidString,
                        url: tempImageURL,
                        options: nil
                    )
                    notificationContent.attachments = [attachment]
                } catch {
                    print("Warning: Could not attach image: \(error.localizedDescription)")
                }
            } else {
                print("Warning: Image file not found at path: \(imagePath)")
            }
        }

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: notificationContent,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error delivering notification: \(error.localizedDescription)")
                self.completionHandler?()
                return
            }

            // If no activate bundle specified, exit shortly after delivery
            // Otherwise, wait for user to click the notification
            if self.activateBundleId == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.completionHandler?()
                }
            }
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Activate the specified app when notification is clicked
        if let bundleId = activateBundleId {
            NSWorkspace.shared.launchApplication(
                withBundleIdentifier: bundleId,
                options: [],
                additionalEventParamDescriptor: nil,
                launchIdentifier: nil
            )
        }

        completionHandler()
        self.completionHandler?()
    }
}
