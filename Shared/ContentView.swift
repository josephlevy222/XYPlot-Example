//
//  ContentView.swift
//  XYPlot
//
//  Created by Joseph Levy on 12/5/21.
//
import SwiftUI
import Utilities
import XYPlot

struct ContentView: View {
    
    @AppStorage("buttonPushed") var buttonPushed: Bool = false {
        didSet { // new line assigned if secondary
            if buttonPushed {// assigns a new line 1
                print("Assigning new line 1")
                plotThis.plotLines[1].secondary = true
                let π = Double.pi
                plotThis.plotLines[1].values = (0...300).map { i in
                    let x = 0.01*Double(i)
                    return PlotPoint(x,0.6*(cos(π*x) + 0.0))
                }
            }
            plotThis.scaleAxes()
        }
    }
    
//    @AppStorage("changePlotOdd") var savedShowSecondaryAxis: Bool = false {
//        didSet {
//            print("didSet saveShowSecondary")
//            if savedShowSecondaryAxis
//            } else {
//                plotThis.plotLines[1].secondary = false
//            }
//            plotThis.scaleAxes()
//        }
//    }
    
    @AppStorage("changeXSizeOdd") var savedXAxisAppended: Bool = false {
        didSet {
            print("didSet saveXAxisAppended")
            if savedXAxisAppended && plotThis.plotLines[1].last?.x == 3.0 {
                print("appended")
                plotThis.plotLines[1].append(PlotPoint(4.0,0.0))
            }
            if !savedXAxisAppended && plotThis.plotLines[1].last?.x == 4.0 {
                print("removedLast")
                plotThis.plotLines[1].values.removeLast()
            }
            plotThis.scaleAxes()
        }
    }
    
    @State public var plotThis =  { // assigns original lines defined in XYPlot.swift
        let coreDataManager = XYPlot.CoreDataManager.shared
        var testData: PlotData = testPlotLines
        var savedSettings = coreDataManager.getSettings()
        if savedSettings.isEmpty { // Make new Coredata Settings
            testData.settings.copyPlotSettingsToCoreData()
        } else {
            testData.settings.copySettingsFromCoreData(id: savedSettings[0].objectID)
            if savedSettings.count > 1 { // delete extra entities
                
            }
        }
        var lines = coreDataManager.getLines()
        print("\(lines.count) lines were saved")
        switch lines.count {
        case 0:
            testData.plotLines[0].copyLineSettingsToCoreData()
            testData.plotLines[1].copyLineSettingsToCoreData()
        case 1:  // should never happen
            testData.plotLines[0].copyLineSettingsFromCoreData(id: lines[0].objectID)
            testData.plotLines[1].copyLineSettingsToCoreData()
        default:
            testData.plotLines[0].copyLineSettingsFromCoreData(id: lines[0].objectID)
            testData.plotLines[1].copyLineSettingsFromCoreData(id: lines[1].objectID)
        }
        return testData
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
            Button("Change Plot") { // assigns new lines
                if buttonPushed == false { buttonPushed = true } // so does just once if false never if true
                plotThis.settings.showSecondaryAxis.toggle() // odd presses shows secondary
                if plotThis.settings.showSecondaryAxis { plotThis.plotLines[1].secondary.toggle() }
                plotThis.scaleAxes()
            }.padding(.leading)
            Button("Change x size") {
                savedXAxisAppended.toggle()
                
            }.padding(.leading)
            XYPlot(data: $plotThis).padding()
                .onAppear {
                    //Do button press state
                    // this is the 0th XYPlot
                    var managedSettings = XYPlot.CoreDataManager.shared.getSettings()
                    if managedSettings.isEmpty {
                        plotThis.settings.copyPlotSettingsToCoreData()
                        managedSettings = XYPlot.CoreDataManager.shared.getSettings()
                        print("Core data count: \(managedSettings.count)")
                    }
                    if(!managedSettings.isEmpty) { plotThis.settings.copySettingsFromCoreData(id: managedSettings[0].objectID)
                        plotThis.scaleAxes()
                        print("oldSettings \(plotThis.settings.legendPos)")
                    } else { print("Core data not working right")}
                    let lines = XYPlot.CoreDataManager.shared.getLines()
                    for i in plotThis.plotLines.indices {
                        plotThis.plotLines[i].copyLineSettingsFromCoreData(id: i < lines.count ? lines[i].objectID : nil)
                    }
                    // AppStorage used here to make things as they were force didSet
                    buttonPushed = buttonPushed // runs didSet
                    savedXAxisAppended = savedXAxisAppended // runs didSet
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

