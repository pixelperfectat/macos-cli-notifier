import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    private let title: String
    private let content: String
    private let imagePath: String?
    private let activateBundleId: String?
    private var notificationManager: NotificationManager?

    init(title: String, content: String, imagePath: String?, activateBundleId: String?) {
        self.title = title
        self.content = content
        self.imagePath = imagePath
        self.activateBundleId = activateBundleId
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        notificationManager = NotificationManager(
            title: title,
            content: content,
            imagePath: imagePath,
            activateBundleId: activateBundleId
        )

        notificationManager?.sendNotification { [weak self] in
            self?.terminateApp()
        }
    }

    private func terminateApp() {
        DispatchQueue.main.async {
            NSApplication.shared.terminate(nil)
        }
    }
}
