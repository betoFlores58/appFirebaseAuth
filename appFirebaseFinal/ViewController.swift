//
//  ViewController.swift
//  appFirebaseFinal
//
//  Created by Alberto Flores on 24/01/21.
//  Copyright © 2021 Alberto Flores. All rights reserved.
//

import UIKit
import FirebaseAnalytics
import FirebaseAuth
import Firebase
import GoogleSignIn

class ViewController: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPwd: UITextField!
    @IBOutlet weak var btnIngresar: UIButton!
    @IBOutlet weak var btnRegistrar: UIButton!
    @IBOutlet weak var btnGoogle: UIButton!
    @IBOutlet weak var loginStack: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //comprobamos la sesion del usr
        let defaults = UserDefaults.standard
        if let email = defaults.value(forKey: "email") as? String, let proveedor = defaults.value(forKey: "proveedor") as? String {
            loginStack.isHidden = true
            navigationController?.pushViewController(HomeViewController(email: email, proveedor: ProviderType.init(rawValue: proveedor)!), animated: false)
        }
        GIDSignIn.sharedInstance()?.presentingViewController=self
        GIDSignIn.sharedInstance()?.delegate=self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loginStack.isHidden = false
    }

    @IBAction func btnGoogleA(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signOut()
        GIDSignIn.sharedInstance()?.signIn()
        
        
    }
    

    @IBAction func btnLogin(_ sender: Any) {
        if let email = txtEmail.text, let pwd = txtPwd.text{
            
            Auth.auth().signIn(withEmail: email, password: pwd){
                (result,error) in
                self.showHome(result: result, error: error, provider: .basic)
        }
    }
}
    @IBAction func btnSignUp(_ sender: Any) {
        if let email = txtEmail.text, let pwd = txtPwd.text{
            
            Auth.auth().createUser(withEmail: email, password: pwd){
                (result,error) in
                
                if let resultado = result, error == nil{
                    self.navigationController?.pushViewController(HomeViewController(email: resultado.user.email!, proveedor: .basic), animated: true)
                    let alerta = UIAlertController(title: "Usuario creado", message: "Usuario creado con exito", preferredStyle: .alert)
                    alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    self.present(alerta, animated: true, completion: nil)
                }else{
                    let alerta = UIAlertController(title: "ERROR", message: "Se ha producido un error al registrar al usuario", preferredStyle: .alert)
                    alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    self.present(alerta, animated: true, completion: nil)
                }
            }
        }
    }
    private func showHome(result: AuthDataResult?,error: Error?,provider: ProviderType){
        if let result = result, error == nil{
            self.navigationController?.pushViewController(HomeViewController(email: result.user.email!, proveedor: provider), animated: true)
            let alerta = UIAlertController(title: "Correcto.!", message: "Bienvenido", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
            self.present(alerta, animated: true, completion: nil)
        }else{
            let alerta = UIAlertController(title: "ERROR", message: "Se ha producido un error, revisa tu email y contraseña de \(provider.rawValue)", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
            self.present(alerta, animated: true, completion: nil)
        }
    }
    
}

extension ViewController: GIDSignInDelegate{
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error == nil && user.authentication != nil{
            let credentials = GoogleAuthProvider.credential(withIDToken: user.authentication.idToken, accessToken: user.authentication.accessToken)
            Auth.auth().signIn(with: credentials){
                (result,error) in
                self.showHome(result: result, error: error, provider: .google)
            }
        }
    }
}
