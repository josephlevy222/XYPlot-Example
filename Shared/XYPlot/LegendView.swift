//
//  LegendView.swift
//  Mode Analyzer-1D
//
//  Created by Joseph Levy on 3/4/22.
//

import SwiftUI


struct LegendView: View {
    @Binding var data: PlotData
    
    var lines : [PlotLine] {  data.plotLines }
    
    private var lineNumber : Int { data.settings.selection ?? 0}
    
    var arrows : Bool { data.settings.showSecondaryAxis }
    @State private var isPresented = false
    
    @ViewBuilder func arrow(show: Bool, left: Bool = true) -> some View {
        if data.settings.showSecondaryAxis {
            ShapeView(shape: .init(shape: Arrow(left: left).path, color: show ? .black : .white))}
        else { EmptyView() }
    }
    
    var body: some View {
        if (data.settings.legend ) {
            Group {
            VStack(spacing: 0) {
                Color.clear.frame(width: 50, height: 2)
                ForEach(0..<lines.count, id: \.self) { i in
                    Button(action: {
                        let lines = data.plotLines
                        var settings = data.settings
                        settings.selection = i
                        // nix the lines in data and reintroduce to guarantee State mutation
                        // this seems like a bug but this fixes it
                        data = PlotData(settings: settings)// Force copy below
                        data = PlotData(plotLines: lines, settings: settings)
                        isPresented = true
                        print("Trace \(lineNumber) tapped")
                    }) { // Label
                        HStack(alignment: .bottom) {
                            Color.clear.frame(width: 1, height: 2)
                            arrow(show: !lines[i].secondary, left: true)
                            VStack(spacing: 0) {
                                Color.clear.frame(width: 50, height: 2)
                                let legend = (lines[i].legend ?? "" == "" ) ?  "Trace \(i)" : lines[i].legend!
                                Text(legend).font(.footnote).frame(minWidth: 50).padding(.bottom, 4)
                                ZStack {
                                    Path { path in path.move(to: .zero); path.addLine(to: CGPoint(x: 50, y: 0))}
                                        .stroke(lines[i].lineColor, style: lines[i].lineStyle)
                                        #if os(iOS) && !targetEnvironment(macCatalyst)
                                        .frame(width: 50, height: 0.5) // height 0.5 makes the line centered on the points !?
                                        #else
                                        .frame(width: 50, height: 1.0)
                                    #endif
                                    ShapeView(shape: lines[i].pointShape)
                                        .offset(x: -10.0, y: 0).frame(height: 2)
                                    ShapeView(shape: lines[i].pointShape).frame(height: 1)
                                        .offset(x:  10.0, y: 0)
                                }
                            }
                            arrow(show: lines[i].secondary, left: false)
                            Color.clear.frame(width: 1, height: 1)
                        }
                    }.contentShape(Rectangle()).buttonStyle(.plain)
                }
                Color.clear.frame(width: 50, height: 10)
            }.background(Color.white).contentShape(Rectangle()).border(Color.black)
            }.popover(isPresented:  $isPresented )  { PlotLineDialog(plotData: $data)  }
        } else { EmptyView() }
    }
}

struct LegendView_Previews: PreviewProvider {
    static var previews: some View {
            StatefulPreviewWrapper(testPlotLines) {
                LegendView(data: $0 ) }//testPlotLines ) //}
    }
}




