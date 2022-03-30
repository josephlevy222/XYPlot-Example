//
//  PlotLineDialog.swift
//  Mode Analyzer-1D
//
//  Created by Joseph Levy on 3/14/22.
//

import SwiftUI

struct PlotLineDialog: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var plotData: PlotData

    @State private var i : Int = 0
    @State private var lineName : String = ""
    @State private var lineColor : Color = .black
    @State private var lineWidth : CGFloat = 1.0
    @State private var lineStyle : Int = 0
    @State private var pointColor : Color = .black
    @State private var pointStyle : Int = 0
    
    @State private var showPointStyler = false
    @State private var pointFill = false
    @State private var pointSize: CGFloat = 1.0
    
    @State private var presenting: Bool = false
    @State private var showDropdown: Bool = false
    @State private var lineOff = false
    @State private var pointOff = false
    let lineStyles: [[CGFloat]] = [[], [15,5], [5], [5,5,15,5]]
    let lineStyleNames = ["Solid", "Dashed", "Dotted", "Dashdot"].map { HTMLParser($0).attributedString }
    var lines : [PlotLine] { plotData.plotLines }
    var legend : String { lineName == "" ? "Trace \(i)" : lineName
    }
    var newPointColor: Color  { pointOff ? Color.clear : pointColor }
    var newLineColor: Color { lineOff ? Color.clear : lineColor }
    @State private var savedLineColor: Color = .red
    @State private var savedPointColor: Color = .red
    
    var body: some View {
        VStack {
            List {
                HStack {
                    Text("\(legend)"); Spacer()
                    ZStack(alignment: .center) { // line sample
                        Path { path in path.move(to: .zero); path.addLine(to: CGPoint(x: 100, y: 0))}
                            .stroke(lineColor, style: StrokeStyle(lineWidth: lineWidth, dash: lineStyles[lineStyle] ))
                        #if os(iOS) && !targetEnvironment(macCatalyst)
                            .frame(width: 100, height: 0.5) // height 0.5 makes the line centered on the points !?
                        #else
                            .frame(width: 100, height: 1.0)
                        #endif
                        ShapeView(shape: ShapeParameters(shape: symbolShapes[pointStyle].shape, angle: symbolShapes[pointStyle].angle, filled: pointFill, color: pointColor, size: pointSize))
                            .offset(x: -25.0, y: 0)
                        ShapeView(shape: ShapeParameters(shape: symbolShapes[pointStyle].shape, angle: symbolShapes[pointStyle].angle, filled: pointFill, color: pointColor, size: pointSize))
                            .offset(x:  25.0, y: 0)
                    }}
                Section {
                    HStack {
                        Text("Line Name")
                        TextField("Name", text: $lineName)
                            .background(Color.white ).border( Color.black )
                    }
                    HStack(spacing: 0) {
                        ColorPicker("Line Color     ",selection: $lineColor).disabled(lineOff)
                        #if !targetEnvironment(macCatalyst)
                        .fixedSize()
                        #endif
                        Spacer()
                        Text(" Off ")
                        CheckBoxView(checked: $lineOff).onChange(of: lineOff) { off in
                            if off && lineColor != .clear { savedLineColor = lineColor }
                            lineColor = off ? .clear : savedLineColor
                        }
                    }
                    Stepper(value: $lineWidth, in: 0.0...10.0, step: 0.5 ) {
                        Text("Line Width: \(String(format: "%.1f", lineWidth))")
                        .onChange(of: lineWidth) { newWidth in
                            if newWidth == 0.0 { lineOff = true }
                        }
                    }
                    HStack {
                        Text("Line Style")
                        Spacer()
                        Dropdown(placeHolder: "Dash" , selection: $lineStyle, options: lineStyleNames)
                    }
                }
                Section {
                    HStack(spacing: 0) {
                        ColorPicker("Symbol Color",selection: $pointColor).disabled(pointOff)
                            #if !targetEnvironment(macCatalyst)
                            .fixedSize()
                            #endif
                        Spacer()
                        Text(" Off ")
                        CheckBoxView(checked: $pointOff).onChange(of: pointOff) { off in
                            if off && pointColor != .clear { savedPointColor = pointColor;  print("line 98", savedPointColor)}
                            pointColor = off ? .clear : savedPointColor
                            print("linr 99 pointcolor now: ", pointColor, " with off ", off, " and savedPointColor ", savedPointColor)
                        }
                    }
                    
                    HStack { Text("Symbol Filled");Spacer(); CheckBoxView(checked: $pointFill)}
                    HStack {
                        Text("Symbol Shape")
                        Spacer()
                        Button(action:  { showDropdown = true }) {
                            if(pointColor == Color.clear) { Text("None")}
                            else {
                                ShapeView(shape: ShapeParameters(shape: symbolShapes[pointStyle].shape, angle: symbolShapes[pointStyle].angle, filled: pointFill, color: pointColor, size: pointSize)) }
                        }
                        .popover(isPresented: $showDropdown, attachmentAnchor: .rect(.bounds), arrowEdge: .bottom) {
                            VStack(spacing: 0) {
                                ForEach(symbolShapes.indices, id:\.self) { i in
                                    VStack {
                                        Button(action: {
                                            showDropdown = false
                                            pointStyle = i
                                        }) { ShapeView(shape: symbolShapes[i]).padding(10) }
                                        Divider()
                                    }
                                    .textFieldStyle(.automatic)
                                    .buttonStyle(.plain)
                                    .background(Color.white)
                                }
                            }
                        }
                    }
                    Stepper(value: $pointSize, in: 0.2...3.0, step: 0.2 ) {
                        Text("Symbol Size: \(String(format: "%.2f", pointSize))").fixedSize()
                    }
                }
            }
            HStack {
                Button("Cancel") { dismiss() }.foregroundColor(.accentColor)
                Spacer()
                Button(action: {
                    var plotLine = plotData.plotLines[i]
                    plotLine.lineColor = lineColor
                    plotLine.lineStyle = StrokeStyle(lineWidth: lineWidth, dash: lineStyles[lineStyle])
                    let shape = symbolShapes[pointStyle]
                    plotLine.pointShape = ShapeParameters(shape: shape.shape, angle: shape.angle, filled: pointFill, color: pointColor, size: pointSize )
                    plotLine.legend = lineName
                    plotData.plotLines[i] = PlotLine() // needed to insure copy (see LegendView)
                    plotData.plotLines[i] = plotLine
                    print("Point Color ", String(format: "%x", pointColor.sRGBA))
                    dismiss()
                }) { Text("Ok").foregroundColor(.accentColor)}
            }.buttonStyle(RoundedCorners(color: .white.opacity(0.1), shadow: 2 ))
        }
        .background(Color.white)
        .frame(width: 300, height: 500)
        .padding()
        .onChange(of: savedPointColor) { color in print("line 155 saved color",savedPointColor, "new color", color) }
        .onAppear {
            i = plotData.settings.selection ?? 0
            print("In PlotLineDialog Trace \(i)")
            let plotLine : PlotLine = plotData.plotLines[self.i]
            lineName =  plotLine.legend ?? "Trace \(self.i)"
            //let
            if plotLine.lineColor == .clear { lineOff = true; savedLineColor = (plotLine.pointColor == .clear ? .black : plotLine.pointColor) }  else { lineOff = false }
            if plotLine.pointColor == .clear { pointOff = true; savedPointColor = (plotLine.lineColor == .clear ? .black : plotLine.lineColor) } else { pointOff = false }
            lineColor = plotLine.lineColor
            pointColor = plotLine.pointColor
            print("line 165 lineColor and pointColor", lineColor, pointColor)
            print(" and saved versions", savedLineColor, savedPointColor)
            lineWidth = plotLine.lineStyle.lineWidth
            lineStyle = lineStyles.firstIndex(of: plotLine.lineStyle.dash ) ?? 0
            pointStyle = symbolShapes.firstIndex(of: ShapeParameters(shape: plotLine.pointShape.shape, angle: plotLine.pointShape.angle, filled: false)) ?? 0
            pointFill = plotLine.pointShape.filled
            pointSize = plotLine.pointShape.size
        }
    }
}


var symbolShapes : [ShapeParameters] = [
    .init(shape: Polygon(sides: 4).path, filled: false), // Diamond
    .init(shape: Polygon(sides: 4).path, angle: .degrees(45.0), filled: false),// Square
    .init(shape: Circle().path, filled: false), // Circle
    .init(shape: Polygon(sides: 3).path, angle: .degrees(-90.0), filled: false),
    .init(shape: Polygon(sides: 6, openShape: true).path),// Asterix
    .init(shape: Polygon(sides: 4, openShape: true).path, angle: .degrees(45.0)), // X
    .init(shape: Polygon(sides: 4, openShape: true).path) // +
]


struct PlotLineDialog_Previews: PreviewProvider {
    
    static var previews: some View {
        Group {
            StatefulPreviewWrapper(testPlotLines) {
                PlotLineDialog(plotData: $0).border(Color.green)
            }
        }
    }
}
