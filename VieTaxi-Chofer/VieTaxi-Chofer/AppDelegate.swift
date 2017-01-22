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

import Alamofire


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    
    public static var TableBarInit:UINavigationController?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
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
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //self.saveContext()
    }
    
    /* MARK: - Core Data stack
     
     @available(iOS 10.0, *)
     lazy var persistentContainer: NSPersistentContainer = {
     /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
     let container = NSPersistentContainer(name: "VieTaxi")
     container.loadPersistentStores(completionHandler: { (storeDescription, error) in
     if let error = error as NSError? {
     // Replace this implementation with code to handle the error appropriately.
     // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
     
     /*
     Typical reasons for an error here include:
     * The parent directory does not exist, cannot be created, or disallows writing.
     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
     * The device is out of space.
     * The store could not be migrated to the current model version.
     Check the error message to determine what the actual problem was.
     */
     fatalError("Unresolved error \(error), \(error.userInfo)")
     }
     })
     return container
     }()
     
     // MARK: - Core Data Saving support
     
     func saveContext () {
     if #available(iOS 10.0, *) {
     let context = persistentContainer.viewContext
     } else {
     // Fallback on earlier versions
     }
     if context.hasChanges {
     do {
     try context.save()
     } catch {
     // Replace this implementation with code to handle the error appropriately.
     // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
     let nserror = error as NSError
     fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
     }
     }
     }*/
    
}


