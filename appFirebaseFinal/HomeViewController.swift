//
//  HomeViewController.swift
//  appFirebaseFinal
//
//  Created by Alberto Flores on 24/01/21.
//  Copyright © 2021 Alberto Flores. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

enum ProviderType: String {
    case basic
    case google
}
class HomeViewController: UIViewController {

    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var lblProveedor: UILabel!
    @IBOutlet weak var btnCloseSesion: UIButton!
    @IBOutlet weak var txtTelefono: UITextField!
    @IBOutlet weak var txtDireccion: UITextField!
    
    private let email: String
    private let proveedor: ProviderType
    
    private let db = Firestore.firestore()
    
    init(email: String, proveedor: ProviderType) {
        self.email = email
        self.proveedor = proveedor
        super.init(nibName: "HomeViewController", bundle:nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.backBarButtonItem?.title="Regresar"
        lblEmail.text = "Email: \(email)"
        lblProveedor.text = "Proveedor: \(proveedor.rawValue)"
        navigationItem.setHidesBackButton(true, animated: false)
        
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "email")
        defaults.set(proveedor.rawValue, forKey: "proveedor")
        defaults.synchronize()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnRecuperar(_ sender: Any) {
        view.endEditing(true)
        db.collection("users").document(email).getDocument{
            (documentSnapshot,error) in
            if let document = documentSnapshot, error == nil{
                if let address = document.get("address") as? String {
                    self.txtDireccion.text = address
                }else{
                    self.txtDireccion.text = ""
                }
                if let phone = document.get("phone") as? String {
                self.txtTelefono.text = phone
                }else{
                    self.txtTelefono.text = ""
                }
            }else{
                self.txtDireccion.text = ""
                self.txtTelefono.text = ""
            }
        }
    }
    @IBAction func btnEliminar(_ sender: Any) {
        view.endEditing(true)
        
        db.collection("users").document(email).delete()
        let alerta = UIAlertController(title: "Datos eliminados", message: "Datos del usuario \(email) eliminados con éxito", preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
        self.present(alerta, animated: true, completion: nil)
    }
    @IBAction func btnGuardar(_ sender: Any) {
        view.endEditing(true)

         db.collection("users").document(email).setData(["provider":proveedor.rawValue,"address":txtDireccion.text ?? "","phone": txtTelefono.text ?? ""])
         let alerta = UIAlertController(title: "Éxito", message: "Datos del usuario \(email) guardados correctamente", preferredStyle: .alert)
         alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
         self.present(alerta, animated: true, completion: nil)
    }
    
    @IBAction func btnCerrarSesion(_ sender: Any) {
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "email")
        defaults.removeObject(forKey: "proveedor")
        defaults.synchronize()

        switch proveedor {
        case .basic:
            GIDSignIn.sharedInstance()?.signOut()

        case .google:
            GIDSignIn.sharedInstance()?.signOut()
            firebaseLogOut()
        }
        navigationController?.popViewController(animated: true)
    }
        private func firebaseLogOut(){
             do {
                    try Auth.auth().signOut()
                } catch {
                    let alerta = UIAlertController(title: "ERROR", message: "Se ha producido un error al cerrar la sesión", preferredStyle: .alert)
                    alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
                    self.present(alerta, animated: true, completion: nil)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    }

