//
//  CheckListView.swift
//  WatsPLAN
//
//  Created by Wenjiu Wang on 2020-06-14.
//  Copyright © 2020 Jiawen Zhang. All rights reserved.
//

import SwiftUI

let SELECT_ALL = 0
let SELECT_CHECK = 1
let SELECT_UNCHECK = 2

struct CheckListView: View {

    @EnvironmentObject var model : Model
    @State var selected = SELECT_ALL
    @State var showDialog = true
    @State var tempName = ""
        
    var body: some View {
        return ZStack {
            VStack(alignment: .center, spacing : 0) {
                Image("math_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 40.0)
                    .padding(.top, 20)
                    
                Text(model.majorName + (model.optionName == "" ? "" : " | " + model.optionName))
                    .font(.custom("Avenir Next Medium", size:15))
                    .background(Color.black)
                    .foregroundColor(Color.white)
                    .offset(y:-5)
                
                Picker(selection: $selected, label: Text("adasdas"), content: {
                    Text("ALL").tag(SELECT_ALL)
                    Text("CHECKED").tag(SELECT_CHECK)
                    Text("UNCHECKED").tag(SELECT_UNCHECK)
                })
                    .cornerRadius(0)
                    .pickerStyle(SegmentedPickerStyle())
                    .onAppear{
                        UISegmentedControl.appearance()
                            .selectedSegmentTintColor = UIColor(named: "uwyellow")
                        UISegmentedControl.appearance()
                            .setTitleTextAttributes([.font: UIFont.systemFont(ofSize: 15),.foregroundColor: UIColor.black], for: .selected)
                        UISegmentedControl.appearance()
                            .setTitleTextAttributes([.foregroundColor: UIColor(named: "uwyellow")!], for: .normal)
                    }
                
                List([Int](0..<model.cards.count)) { curId in
                    if self.selected == SELECT_ALL ||
                        (self.selected == SELECT_CHECK && self.model.cards[curId].progress == 100) ||
                    (self.selected == SELECT_UNCHECK && self.model.cards[curId].progress != 100)
                    {
                        ListItemView(id: curId)
                    }
                }
                .onAppear {
                    UITableView.appearance().separatorStyle = .none
                    UITableView.appearance().backgroundColor = .clear
                }
            }
            .disabled(self.showDialog)
            .background(Color.black)
            .onAppear {
                self.model.getCollection()
            }
            
            if self.showDialog {
                VStack(spacing: 0) {
                    ZStack {
                        Rectangle()
                            .fill(Color.black)
                            .frame(height: 50)
                        Text("SAVE")
                            .font(.custom("Avenir Next Medium", size:30))
                            .foregroundColor(Color("uwyellow"))
                    }
                    
                    VStack(alignment: .leading) {
                        Text(model.fileName == "" ? "Create a new save: " : "Overwrite save file " + model.fileName + "?")
                            .font(.custom("Avenir Next Medium", size:20))
                            .foregroundColor(Color.black)
                            .padding([.top, .leading], 20.0)


                        
                        if model.fileName == "" {
                            TextField("Please enter a file name", text: $tempName)
                                .padding(.horizontal, 20.0)
                            
                            
                            HStack {
                                Rectangle()
                                    .frame(height: 2)
                                    .background(Color.black)
                            }
                            .padding(.leading, 20)

                        }
                        
                        HStack(spacing: 30) {
                            Button(action: {
                                self.tempName = ""
                                withAnimation {
                                    self.showDialog = false;
                                }
                            }) {
                                Text("NO")
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 10)
                                    .background(Color.black)
                                    .foregroundColor(Color("uwyellow"))
                                    .font(.custom("Avenir Next Medium", size:18))

                            }
                            .cornerRadius(10)

                            Button(action: {
                                if self.model.fileName == "" && self.tempName != "" {
                                    self.model.saveModel(name: self.tempName)
                                } else if self.model.fileName != "" {
                                    self.model.saveModel(name: self.model.fileName)
                                } else {
                                    //alert user incorrect input
                                }
                                withAnimation {
                                    self.showDialog = false;
                                }
                                
                            }) {
                                Text("YES")
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 10)
                                    .background(Color.black)
                                    .foregroundColor(Color("uwyellow"))
                                    .font(.custom("Avenir Next Medium", size:18))

                            }
                            .cornerRadius(10)
                        }
                        .padding(.leading, 120)
                        .padding(.top, 20)
                        .padding(.bottom, 10)

                    }
                    .background(Color("uwyellow"))
                }
                .frame(width: 350)

                
            }
            
            
        }
    }
}

struct CheckListView_Previews: PreviewProvider {
    static var previews: some View {
        CheckListView()
        .environmentObject(Model())
    }
}

