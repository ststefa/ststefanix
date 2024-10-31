import Cocoa
import CoreFoundation

func switchToApp(named windowOwnerName: String) {
    let options = CGWindowListOption(arrayLiteral: CGWindowListOption.excludeDesktopElements, CGWindowListOption.optionOnScreenOnly)
    let windowListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
    guard let infoList = windowListInfo as NSArray? as? [[String: AnyObject]] else { return }

    if let window = infoList.first(where: { ($0["kCGWindowOwnerName"] as? String) == windowOwnerName}), let pid = window["kCGWindowOwnerPID"] as? Int32 {
        let app = NSRunningApplication(processIdentifier: pid)
        app?.activate(options: .activateIgnoringOtherApps)
    }
}
