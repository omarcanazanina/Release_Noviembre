//
//  Login.swift
//  fastgi
//
//  Created by Hegaro on 04/11/2020.
//

import Foundation
import Alamofire
import Combine
import SwiftUI
import SDWebImageSwiftUI

class Login: ObservableObject {
    @Published var ruta: String? = ""
    @Published var isloading = false
    @Published var iscomplete = false
    @Published var loginResponse = false
    @Published var messageError :String = ""
    
    @EnvironmentObject private var authState : AuthState
    private let tokenKey = "token"
    private let idKey = "usuario._id"
    
    //Storage
    private let storage = UserDefaults.standard
    //rutas
    var navigationRoot = NavigationRoot()
    //datauser
    @Published var userResponse:UpdateUserModel?
    
    func loginDetail(telefono:String) {
        self.isloading = true
        let parametros : Parameters = [
            "telefono": telefono
        ]
        guard let url = URL(string: "https://api.fastgi.com/sms") else { return }
        DispatchQueue.main.async {
            AF.request(url, method: .post, parameters: parametros)
                .responseData { (response) in
                    switch response.result {
                    case let .success(data):
                        //Cast respuesta a SmsResponse
                        if let decodedResponse = try? JSONDecoder().decode(SmsResponse.self, from: data) {
                            print(decodedResponse.usuario)
                            self.ruta = "idlogin"
                            self.isloading = false
                            self.iscomplete = true
                            return
                        }
                        //Cast respuesta a ErrorResponce
                        if let decodedResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                            print(decodedResponse.err.message)
                            //  self.ErrorRes = decodedResponse.err.message
                            self.isloading = false
                            self.iscomplete = true
                            return
                        }
                    case let .failure(error):
                        self.isloading = false
                        print(error)
                    }
                }
        }
    }
    
    func confirmCode(telefono:String,pin:String) {
        self.isloading = true
        let parametros : Parameters = [
            "telefono": telefono,
            "pin": pin
        ]
        guard let url = URL(string: "https://api.fastgi.com/loginsms") else { return }
        DispatchQueue.main.async {
            AF.request(url, method: .post, parameters: parametros)
                .responseData { (response) in
                    switch response.result {
                    case let .success(data):
                        //Cast respuesta a LoginSmsResponse
                        if let decodedResponse = try? JSONDecoder().decode(LoginSmsResponse.self, from: data) {
                            print(decodedResponse.usuario)
                            //sesion
                            self.storage.set(decodedResponse.token, forKey: self.tokenKey)
                            self.storage.set(decodedResponse.usuario._id, forKey: self.idKey)
                            
                            SDWebImageDownloader.shared.setValue(decodedResponse.token, forHTTPHeaderField: "token")
                            print(decodedResponse)
                            //
                            self.loginResponse = true
                            // self.authState.isAuth = true
                            self.navigationRoot.setRootView()
                            self.isloading = false
                            self.iscomplete = true
                            return
                        }
                        //Cast respuesta a ErrorResponce
                        if let decodedResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                            print(decodedResponse.err.message)
                            self.messageError = decodedResponse.err.message
                            self.isloading = false
                            self.iscomplete = true
                            return
                        }
                    case let .failure(error):
                        self.isloading = false
                        self.iscomplete = true
                        self.messageError = "Código incorrecto "
                        print(error)
                    }
                }
        }
        
    }
    
    
    func DataUser(){
        // creando headers
        var headers: HTTPHeaders = [
            "Accept": "application/json"
        ]
        if let token = storage.string(forKey: tokenKey){
            headers.add(name: "token", value: token)
        }
        let idusu = storage.string(forKey: idKey)!
        guard let url = URL(string: "https://api.fastgi.com/usuario/\(idusu)") else { return }
            DispatchQueue.main.async {
                AF.request(url,method:.get,headers: headers )
                    .validate(contentType: ["application/json"])
                    .responseData{response in
                        print(response)
                        switch response.result {
                        case let .success(data):
                            //Cast respuesta a MeResponce
                            if let decodedResponse = try? JSONDecoder().decode(DataUserResponse.self, from: data) {
                                print(decodedResponse.usuario._id)
                                self.userResponse=decodedResponse.usuario
                                return
                            }
                            //Cast respuesta a ErrorResponce
                            if let decodedResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                                print(decodedResponse.err.name)
                                if decodedResponse.err.name == "TokenExpiredError" || decodedResponse.err.name == "JsonWebTokenError"{
                                    self.navigationRoot.changeRootClose()
                                }
                                return
                            }
                        case let .failure(error):
                            print(error)
                        }
                }
            }
    }
    
    
}
