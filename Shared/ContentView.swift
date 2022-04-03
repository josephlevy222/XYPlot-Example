//
//  ContentView.swift
//  XYPlot
//
//  Created by Joseph Levy on 12/5/21.
//
import SwiftUI

extension AttributedString {
    func setFont(_ newFont: Font) -> AttributedString {
        var a = self
        a.font = newFont
        return a
    }
 }

struct ContentView: View {
    var settings  = PlotSettings(
        title: AttributedString("Also a very very long plot title").setFont(.largeTitle),
        xAxis: AxisParameters(title: AttributedString("Much Longer Horizontal Axis Title").setFont(.title2) ),
        yAxis: AxisParameters(title: AttributedString("Incredibly Long Vertical Axis Title").setFont(.title2) ),
        sAxis: AxisParameters(title: AttributedString("Smaller Font Secondary Axis Title").setFont(.title2) )
    )
    
    @State var plotThis = testPlotLines  // assigns original lines defined in XYPlot.swift

    var body: some View {
        VStack {
            Button("Change Plot") { // assigns new lines
                plotThis.settings.showSecondaryAxis.toggle()
                if plotThis.settings.showSecondaryAxis  {
                    // assigns a new line 1
                    plotThis.plotLines[1].secondary = true
                    let π = Double.pi
                    plotThis.plotLines[1].values = (0...300).map { i in
                        let x = 0.01*Double(i)
                        return PlotPoint(x,0.6*(cos(π*x) + 0.0))
                    }
                } else {
                    plotThis.plotLines[1].secondary = false
                }
                plotThis.scaleAxes()
            }
            Button("Change x size") {
                if plotThis.plotLines[1].last == PlotPoint(4.0,0.0) {
                    plotThis.plotLines[1].values.removeLast()
                } else {
                     plotThis.plotLines[1].append(PlotPoint(4.0,0.0))
                }
                plotThis.scaleAxes()
            }
            XYPlot(data: $plotThis).padding()
               .onAppear { plotThis.settings = settings; plotThis.scaleAxes() }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
