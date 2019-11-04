import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        setupAppearance()
        
        return true
    }

    private func setupAppearance() {
        UINavigationBar.appearance().tintColor = UIColor.red

        if #available(iOS 13, *) {
            let fontAttr = [NSAttributedString.Key.font: UIFont.medium14()]

            let buttonAppearance = UIBarButtonItemAppearance()
            buttonAppearance.normal.titleTextAttributes = fontAttr as [NSAttributedString.Key: Any]

            let navbarAppearance = UINavigationBarAppearance()
            navbarAppearance.configureWithOpaqueBackground()
            navbarAppearance.shadowImage = nil
            navbarAppearance.shadowColor = nil
            navbarAppearance.backgroundColor = UIColor.white
            navbarAppearance.buttonAppearance = buttonAppearance
            navbarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font: UIFont.bold18()]
            UINavigationBar.appearance().standardAppearance = navbarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navbarAppearance
        } else {
            UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red, NSAttributedString.Key.font: UIFont.medium14()], for: UIControl.State.normal)
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black, NSAttributedString.Key.font: UIFont.bold18()]
        }
    }
}
