//
//  AppDelegate.swift
//  VieTaxi-Chofer
//
//  Created by usuario on 15/12/16.
//  Copyright © 2016 vietaxi. All rights reserved.
//

import UIKit
import CoreData
import FacebookCore
import Fabric
import Crashlytics
import Google
import GoogleSignIn
import GGLSignIn
import GoogleMaps
import SocketIO
import Alamofire


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    
    public static var TableBarInit:UINavigationController?
    public static let socket = SocketIOClient(socketURL: URL(string: "http://apirt.vietaxi.com")!, config: [.log(false), .forcePolling(true)])
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let settings = UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        UIApplication.shared.applicationIconBadgeNumber = 0
        //Facebook
        SDKApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        //Fabric
        Fabric.with([Crashlytics.self])
        //Google Sing-in
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        //assert(configureError == nil, "Error configuring Google services: \(configureError)")
        //AIzaSyCAhqJmhpR-Qx9rFWRLsWXl3uadQqXPQJs
        GMSServices.provideAPIKey("AIzaSyAuUZ6NMESHtvDALYZjEjlh9bYoW0VwdEU")
        
        GIDSignIn.sharedInstance().delegate = self
        
        PayPalMobile.initializeWithClientIds(forEnvironments: [PayPalEnvironmentProduction: "Ab8RoUjDYTS7_0x90mVyxzmkfEofWmdStkQhRyx_pLkpTRuYwoEbscey9hhOqxn1XHmhj6L8tNDSPFDR",
                                                               PayPalEnvironmentSandbox:
            "AVIh-mjsr9vEz1EaRdbm3JwC0-_qdV-MNVzjalBA2fiHJX6VEJeu04y92RMicG44R0PuD03Ud3Or-a-d"])
      
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        AppDelegate.TableBarInit = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as? UINavigationController
        let Login = storyboard.instantiateViewController(withIdentifier: "LoginVC") as? LoginController
        if let tok = UserDefaults.standard.string(forKey: "token")
        {
            print(tok)
            Alamofire.request("http://api.vietaxi.com/chofer/?token="+tok).validate().responseJSON { response in
                switch response.result {
                case .success:
                    print("Validation Successful")
                    
                    AppDelegate.SocketIOConnect()
                    var token = ""
                    if let tok = UserDefaults.standard.string(forKey: "token")
                    {
                        token = tok
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                        AppDelegate.socket.emit("registro", token)
                    })
                    
                    if let json = response.result.value {
                        print("JSON: \(json)")
                        do{
                            let result = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String:Any]
                            if let nombre = result["nombre"] as? String{UserDefaults.standard.setValue(nombre, forKey: "nombre")}
                            if let apellidos = result["apellidos"] as? String{UserDefaults.standard.setValue(apellidos, forKey: "apellidos")}
                            if let telefono = result["telefono"] as? String{UserDefaults.standard.setValue(telefono, forKey: "telefono")}
                            if let email = result["email"] as? String{UserDefaults.standard.setValue(email, forKey: "email")}
                            if let rfc = result["rfc"] as? String{UserDefaults.standard.setValue(rfc, forKey: "rfc")}
                            if let calificacion = result["calificacion"] as? String{UserDefaults.standard.setValue(calificacion, forKey: "calificacion")}
                            if let domicilio = result["domicilio"] as? String{UserDefaults.standard.setValue(domicilio, forKey: "domicilio")}
                            if let licencia = result["licencia"] as? String{UserDefaults.standard.setValue(licencia, forKey: "licencia")}
                        }
                        catch let error as NSError{
                            print("Error: \(error.localizedDescription)")
                        }
                    }
                    self.window?.rootViewController = AppDelegate.TableBarInit
                    self.window?.makeKeyAndVisible()
                    
                case .failure(let error):
                    print(error)
                    self.window?.rootViewController = Login
                    self.window?.makeKeyAndVisible()
                }
                
            }
        }else{
            self.window?.rootViewController = Login
            self.window?.makeKeyAndVisible()
        }

        return true
    }
    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        let isFacebookURL = SDKApplicationDelegate.shared.application(app,
                                                                      open: url,
                                                                      sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                                      annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        let isGooglePlusURL = GIDSignIn.sharedInstance().handle(url,
                                                                sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                                annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        
        return isFacebookURL || isGooglePlusURL
    }
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let fullName = user.profile.name
            let givenName = user.profile.givenName
            let familyName = user.profile.familyName
            let email = user.profile.email
            print("Welcome: ,\(fullName), \(givenName), \(familyName), \(email)")
            
            /* check for user's token
             if GIDSignIn.sharedInstance().hasAuthInKeychain() {
             /* Code to show your tab bar controller */
             print("user is signed in")
             let sb = UIStoryboard(name: "Main", bundle: nil)
             if let tabBarVC = sb.instantiateViewController(withIdentifier: "TabController") as? UITabBarController {
             window!.rootViewController = tabBarVC
             }
             } else {
             print("user is NOT signed in")
             /* code to show your login VC */
             let sb = UIStoryboard(name: "Main", bundle: nil)
             if let tabBarVC = sb.instantiateViewControllerWithIdentifier("ViewController") as? ViewController {
             window!.rootViewController = tabBarVC
             }
             }
             */
        } else {
            print("\(error.localizedDescription)")
        }
    }
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        application.applicationIconBadgeNumber = 0
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    public static var NotificationReceive:Bool = false
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
         if let message = notification.alertBody{
         print(message)
            DispatchQueue.main.async {
                AppDelegate.NotificationReceive = true
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                AppDelegate.TableBarInit = storyboard.instantiateViewController(withIdentifier: "NavigationVC") as? UINavigationController
                self.window?.rootViewController?.present(AppDelegate.TableBarInit!, animated: true, completion: nil)
            }
         }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        SocketIOReconnect()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        SocketIOReconnect()
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("Complete")
        completionHandler(UIBackgroundFetchResult.newData)
        SocketIOReconnect()
        
    }
    public static var ReconnectOk:Bool = false
    public static func SocketIOConnect(){
        var token = ""
        if let tok = UserDefaults.standard.string(forKey: "token")
        {
            token = tok
        }
        AppDelegate.socket.on("disconnect"){data, ack in
            print("\(AppDelegate.socket.sid)")
        }
        AppDelegate.socket.on("registro"){data, ack in
            print(data)
        }
        AppDelegate.socket.on("aceptar"){data, ack in
            self.SocketIOEvent(dato: data)
        }
        AppDelegate.socket.on("chofer"){data, ack in
            self.SocketIOEvent(dato: data)
        }
        AppDelegate.socket.on("viaje"){data, ack in
            self.SocketIOEvent(dato: data)
        }
        AppDelegate.socket.joinNamespace("/chofer")
        AppDelegate.socket.connect()
        ReconnectOk = true
    }
    public static var latitude:Double = 0.0
    public static var longitud:Double = 0.0
    public static func SocketIOEvent(dato:Any){
        if let data = dato as? [[String: Any]] {
            print(data)
            if let mensaje = data[0]["msj"] as? String {
                print(mensaje)
                let localNotification = UILocalNotification()
                localNotification.fireDate = Date(timeIntervalSinceNow: 5)
                localNotification.timeZone = NSTimeZone.local
                localNotification.alertBody = mensaje
                localNotification.alertTitle = "VieTaxi"
                localNotification.applicationIconBadgeNumber = 1
                UIApplication.shared.scheduleLocalNotification(localNotification)
                
            }
            if let origen = data[0]["origen"] as? [String: Any] {
                if let lat = origen["lat"] as? Double{ AppDelegate.latitude = lat}
                if let lng = origen["lng"] as? Double{ AppDelegate.longitud = lng}
            }
        }
        
    }
    func SocketIOReconnect(){
        if(AppDelegate.ReconnectOk){
        AppDelegate.socket.disconnect()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
            AppDelegate.SocketIOConnect()
            var token = ""
            if let tok = UserDefaults.standard.string(forKey: "token")
            {
                token = tok
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                AppDelegate.socket.emit("registro", token)
            })
        })
        }
    }
}


