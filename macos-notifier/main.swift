import AppKit
import ArgumentParser

struct MacOSNotifier: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "macos-notifier",
        abstract: "Display macOS notifications from the command line"
    )

    @Option(name: .long, help: "The notification title")
    var title: String

    @Option(name: .long, help: "The notification content/body")
    var content: String

    @Option(name: .long, help: "Path to an image file to attach to the notification")
    var image: String?

    @Option(name: .long, help: "Bundle identifier of app to activate when notification is clicked (e.g., com.jetbrains.pycharm)")
    var activate: String?

    func run() throws {
        let app = NSApplication.shared
        let delegate = AppDelegate(
            title: title,
            content: content,
            imagePath: image,
            activateBundleId: activate
        )
        app.delegate = delegate
        app.run()
    }
}

MacOSNotifier.main()
