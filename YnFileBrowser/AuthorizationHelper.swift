import Foundation
import ServiceManagement

struct AuthorizationHelper {
    enum AuthorizationError: Error {
        case errorCreate
        case errorCopyRight
        case errorBless
        case errorSMPrivilegedExecutables
    }
    
    private let authorizationRef: AuthorizationRef
    
    init() throws {
        var authorizationRef: AuthorizationRef?
        let osStatus = AuthorizationCreate(nil, nil, [], &authorizationRef)
        guard osStatus == 0,
              let authorizationRef = authorizationRef else {
            throw AuthorizationError.errorCreate
        }
        
        self.authorizationRef = authorizationRef
    }

    func isHelperInstalled() -> Bool {
        var isHelperInstalled = false
        if let helperToolName = (Bundle.main.infoDictionary?["SMPrivilegedExecutables"]
            as? [String: Any])?.first?.key {
            let helperLaunchdPath = URL(fileURLWithPath: "/Library/LaunchDaemons/\(helperToolName).plist")
            let helperInstalledPath = URL(fileURLWithPath: "/Library/PrivilegedHelperTools/\(helperToolName)")
            isHelperInstalled = FileManager.default
                .fileExists(atPath: helperLaunchdPath.path) &&
                FileManager.default.fileExists(atPath: helperInstalledPath.path)
        }
        else {
            NSLog("Failed to find helper in bundle")
        }

        return isHelperInstalled
    }

    func authorizationCopyRight(name: String) -> OSStatus {
        return name.withCString { namePtr -> OSStatus in
            var right = AuthorizationItem(name: namePtr, valueLength: 0, value: nil, flags: 0)
            return withUnsafeMutablePointer(to: &right) { rightPtr -> OSStatus in
                var rights = [AuthorizationRights(count: 1, items: rightPtr)]
                let flags = AuthorizationFlags([.extendRights, .interactionAllowed])
                return AuthorizationCopyRights(
                    authorizationRef,
                    &rights,
                    nil,
                    flags,
                    nil)
            }
        }
    }

    ///  Install the privileged helper tool as a launch daemon.
    func installHelper() throws {
        let osStatus = authorizationCopyRight(
            name: kSMRightBlessPrivilegedHelper)
        
        guard osStatus == 0 else {
            throw AuthorizationError.errorCopyRight
        }

        guard let executables = Bundle.main.infoDictionary?["SMPrivilegedExecutables"] as? [String: String],
              executables.count == 1,
              let privilegedExecutable = executables.first?.key else {
            throw AuthorizationError.errorSMPrivilegedExecutables
        }

        var unmanagedError: Unmanaged<CFError>?
        let result = SMJobBless(
            kSMDomainSystemLaunchd,
            privilegedExecutable as CFString,
            authorizationRef,
            &unmanagedError)
        if let error = unmanagedError?.takeUnretainedValue() {
            defer { unmanagedError?.release() }
            throw error
        }
        else if !result {
            throw AuthorizationError.errorBless
        }
    }
}
