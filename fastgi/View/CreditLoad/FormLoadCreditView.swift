//
//  FormLoadCreditView.swift
//  fastgi
//
//  Created by Hegaro on 04/11/2020.
//

import SwiftUI

struct FormLoadCreditView: View {
    @State  var SelectEm :BtnEm
    @State private  var telefono = ""
    @State var montoRecarga1: BtnCA
    @State  var montoRecarga :String
    @ObservedObject var RecargaVM = RecargaViewModel()
    //contacts
    @ObservedObject var contactsVM1 = ImportContactsViewModel()
    @ObservedObject var contactsVM = ContactsViewModel()
    @ObservedObject var contacts = Contacts()
    //navegation
    @State private var action:Int? = 0
    //
    @State var showingSheet = false
    @State private  var nombreContact = ""
    
    var body: some View {
        ScrollView{
            //botones de la empresa
            HStack{
                BtnsEmView(currentBtnEm: $SelectEm)
            }.padding()
            VStack{
                //campo para ingresar numero de contacto
                HStack{
                    TextField("Número de teléfono", text: $telefono)
                        .padding(.horizontal,12)
                        .padding(.vertical,8)
                        .keyboardType(.numbersAndPunctuation)
                    Button(action: {
                        if self.contactsVM.listContacts.count == 0{
                            print("no hay contactos")
                            print(self.contactsVM.listContacts.count)
                            self.contacts.sendContacts()
                            self.contactsVM.getContacts()
                           // self.showingSheet.toggle()
                        }else{
                            print("si hay contactos")
                            print(self.contactsVM.listContacts.count)
                            self.showingSheet.toggle()
                        }
                    })
                    {
                        Image(systemName: "person.2")
                            .foregroundColor(Color("primary"))
                            .padding(12)
                    }
                    //ListcontactsView
                    .sheet(isPresented: $showingSheet) {
                        ListContactsView(showingSheet: self.$showingSheet, telefono: self.$telefono, nombre: self.$nombreContact, modal: self.$showingSheet)
                    }
                    //end
                }.background(Color("input"))
                .clipShape(Capsule())
            }.padding()
            //Card select
            NavigationLink(destination: SelectCreditCardView()) {
                HStack{
                    Text("Seleccionar tarjeta")
                        .foregroundColor(Color.primary)
                        .padding(.horizontal,12)
                        .padding(.vertical,8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            
                .background(Color("input"))
                        .clipShape(Capsule())
                .padding(.horizontal)
            }
            // amounts select
            VStack{
                ContentButtonsView(currentBtn: $montoRecarga1,text: "", montoRecarga:  $montoRecarga)
                Button(action: {
                    print(self.SelectEm)
                    print(self.montoRecarga)
                    print(self.telefono)
                        self.RecargaVM.SendRecarga(empresa: self.SelectEm, recarga: self.montoRecarga, telefono: self.telefono,  text: "")
                        self.action = 1
                          //self.login.ruta = "recarga"
                   
                }){
                    Text("Aceptar")
                    .foregroundColor(Color.white)
                    .frame(maxWidth:.infinity)
                    .padding(8)
                    .background(Color("primary"))
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 2, y: 3)
                    .padding()
                        
                }
            }
            //end
            if self.RecargaVM.control != ""{
                NavigationLink(destination: TransactionDetailView(fecha: "", empresa:  self.RecargaVM.recargaData.empresa, phone: self.RecargaVM.recargaData.telefono, monto: self.RecargaVM.recargaData.recarga, control: 1, fechaFormat: "", horaFormat: ""), tag: 1, selection: self.$action) {
                        EmptyView()
                }
                
            }
        }
    }
}

struct FormLoadCreditView_Previews: PreviewProvider {
    static var previews: some View {
        FormLoadCreditView(SelectEm: .Entel, montoRecarga1: .Btn10, montoRecarga: "")
    }
}
