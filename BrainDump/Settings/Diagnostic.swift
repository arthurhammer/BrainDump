import Foundation

extension Bundle {

    var name: String {
        info(for: "CFBundleDisplayName") ?? info(for: "CFBundleName") ?? ""
    }

    var version: String {
        info(for: "CFBundleShortVersionString") ?? ""
    }

    var build: String {
        info(for: "CFBundleVersion") ?? ""
    }

    var formattedVersion: String {
        let format = NSLocalizedString("bundle.formattedVersion", value: "%@ %@ (%@)", comment: "<App Name> <Version Number> (<Build Number>)")
        return String.localizedStringWithFormat(format, name, version, build)
    }

    private func info<T>(for key: String) -> T? {
        (localizedInfoDictionary?[key] as? T)
            ?? (infoDictionary?[key] as? T)
    }
}

import UIKit

extension UIDevice {
    /// A string of the form:
    ///   Brain Dump 1.0 (4)
    ///   iOS 12.3.1
    ///   iPhone7,2
    func formattedDiagnostics(forBundle bundle: Bundle = .main) -> String {
        "\(bundle.formattedVersion)\n\(systemName) \(systemVersion)\n\(type ?? model)"
    }
}

extension UIDevice {
    /// Device type, e.g. "iPhone7,2".
    var type: String? {
        // From the world wide webs.
        var systemInfo = utsname()
        uname(&systemInfo)

        return withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0)
            }
        }
    }
}
