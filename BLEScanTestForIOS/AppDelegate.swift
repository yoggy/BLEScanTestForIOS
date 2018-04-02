import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        message("application()")

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        message("applicationWillResignActive()")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        message("applicationDidEnterBackground()")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        message("applicationWillEnterForeground()")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        message("applicationDidBecomeActive()")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        message("applicationWillTerminate")
    }
    
    func message(_ msg:String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss : "
        let now = Date()
        let date_str = formatter.string(from: now)
        
        print(date_str + msg)
    }
}

