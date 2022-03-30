//
//  AdjustAxis.swift
//  XYPlot
//
//  Created by Joseph Levy on 12/9/21.
//
import Foundation

func pow10(_ x: Double ) -> Double { pow(10.0,x) }
typealias MajorMinor = (Int,Int)

let safe=0.999; // allow 0.1% out of axes.

func bestTics(min: inout Double, max: inout Double) -> MajorMinor {
    let d = (max-min)
    var p = MajorMinor(10,5)
    var incRange = 0.0
    switch(d) {
    case       2: p=(10,4)
    case       3: p=(6,5)
    case       4: p=(8,5)
    case       5: p=(10,5)
    case       6: p=(6,4)
    case  7...11: p=(Int(d),5)
    case      12: p=(6,4)
    case      13: p=(7,4); incRange=1
    case      14: p=(7,4)
    case      15: p=(10,3)
    case      16: p=(8,4)
    case      17: p=(9,4); incRange=1
    case      18: p=(9,4)
    case      19: p=(10,4); incRange=1
    case      20: p=(10,4)
    case      21: p=(7,3)
    case      22: p=(11,4)
    case      23: p=(6,4); incRange=1
    case      24: p=(6,4)
    case      25: p=(10,5)
    case      26: p=(9,3); incRange=1
    case      27: p=(9,3)
    case      28: p=(7,4)
    case      29: p=(6,5); incRange=1
    case      30: p=(6,5)
    case      31: p=(8,4); incRange=1
    case      32: p=(8,4)
    case      33: p=(11,3)
    case      34: p=(7,5); incRange=1
    case      35: p=(7,5)
    case 36...40: p=(8,5); incRange=(40-d)
    case 41...45: p=(9,5); incRange=(45-d)
    case 46...50: p=(10,5); incRange=(50-d)
    case 51...55: p=(11,5); incRange=(55-d)
    case 56...60: p=(6,5); incRange=(60-d)
    case 61...70: p=(7,5); incRange=(70-d)
    case 71...80: p=(8,5); incRange=(80-d)
    case 81...90: p=(9,5); incRange=(90-d)
    case 91...100: p=(10,5); incRange=(100-d)
        
    default      : p = (10,5)
    }
    /// What is this supposed to do?
    if min<0  {
        min-=incRange
        let step = Int(max-min)/p.0
        if step != 0 {
            min += Double(Int(min) % step)
            max += Double(Int(max) % step)
            p.0 =  Int(max-min)/step
        }
    } else { max+=incRange }
    return p
}

func adjustAxis( _ lower: inout Double, _ upper: inout Double) -> MajorMinor {
    // Translated from C++. May need more work.
    // An excellent autoscaler or close enough
    // Adjusts the upper and lower to round numbers that include
    // the called range.
    // Returns good choices for major and minor tics in
    // a tuple MajorMinor = (majortics,minortics)
    // Makes good choices when min and max are opposite signs too but does
    // not force a 0 on major tic, could change this to force 0 major tic.
    // MajorMinor(0,0) when bounds are infinity or the same value
    // February 2022.  Updates to alway make a 0 majorTic when min and max are
    // opposite signs
    if lower>upper { swap(&lower,&upper) }
    if lower.isNaN || upper.isNaN || lower.isInfinite || upper.isInfinite {
        upper = 1; lower = 0
    }
    var exponent: Double? {
        let nabs=max(abs(lower),abs(upper));
        if nabs==Double.infinity || nabs==0.0 || lower == upper { return nil }
        return pow10(floor(log10(nabs*safe))-1.0);
    }
    
    guard let e = exponent else { lower=0.0; upper=1.0; return (0,0) }
    var imax = (upper<0.0) ? (ceil(upper/safe/e)) : (ceil(upper*safe/e))
    var imin = (lower<0.0) ? (floor(lower*safe/e)) : (floor(lower/safe/e))
    var p = MajorMinor(10,5)  // default value
    // Force zero tics
    var zero = 0.0
    if imin < 0 && imax > 0 { // make zero a tic
        var pu = bestTics(min: &zero, max: &imax)
        var pl = bestTics(min: &imin, max: &zero)
        if imax*Double(pl.0) != -imin*Double(pu.0) {
            if imax > -imin {
                imin  = -ceil(-imin/imax*Double(pu.0))*imax/Double(pu.0)
                p.0 = pu.0 - Int(floor(imin*Double(pu.0)/imax))
            } else  {
                imax  = -ceil(-imax/imin*Double(pl.0))*imin/Double(pl.0)
                p.0 = pl.0 - Int(floor(imax*Double(pl.0)/imin))
                swap(&pu,&pl)
                swap(&imin,&imax)
            }
        }
        if p.0 > 12 {
            let step = (imax-imin)/Double(p.0)
            if pu.0 % 2 == 0 { // u even
                if (p.0 - pu.0) % 2 != 0 { // l odd
                    imin -= step
                    p.0 = (p.0+1)/2
                } else { // l even
                    p.0 = p.0/2
                }
            } else { // u odd
                imax += step
                if (p.0 - pu.0) % 2 != 0 { // l odd
                    imin -= step
                    p.0 = p.0/2 + 1
                } else { // l even
                    p.0 = (p.0+1)/2
                }
            }
        }
        if imax < imin { swap(&imin,&imax)}
    }
    else { p = bestTics(min: &imin, max: &imax)}
    
    upper=e*imax
    lower=e*imin;
    return p;
}

extension PlotData {
    
    mutating func scaleAxes() {//}-> PlotData {
        if settings.autoScale { return axesScale() }
        //return self
    }
    
    mutating func axesScale() {//}-> PlotData {
        var newData = self // new copy (COW)
        // Get X range and Y ranges of all plots
        var xMin = Double.infinity, xMax = -xMin
        var yMax = xMax, yMin = xMin
        var sMax = xMax, sMin = xMin
        if plotLines.isEmpty { return }//newData } // Do nothing
        var secondaryPresent : Bool = false
        for plotLine in plotLines {
            secondaryPresent = secondaryPresent || plotLine.secondary
            xMin = min(plotLine.values.map { $0.x}.min() ?? xMin, xMin)
            xMax = max(plotLine.values.map { $0.x}.max() ?? xMax, xMax)
            if plotLine.secondary && newData.settings.showSecondaryAxis {
                sMin = min(plotLine.map { $0.y}.min() ?? sMin, sMin)
                sMax = max(plotLine.map { $0.y}.max() ?? sMax, sMax)
            } else {
                yMin = min(plotLine.map { $0.y}.min() ?? yMin, yMin)
                yMax = max(plotLine.map { $0.y}.max() ?? yMax, yMax)
                if !newData.settings.showSecondaryAxis {
                    sMin = yMin
                    sMax = yMax
                }
            }
        }
        var xTics = adjustAxis(&xMin, &xMax)
        var yTics = adjustAxis(&yMin, &yMax)
        var sTics = adjustAxis(&sMin, &sMax)
        if sTics.0 != 0 && !settings.independentTics { // makes secondary axis tics use y axis tics or vica versa
            if yTics.0 != 0  {
                if sTics.0 > yTics.0  { // Generally use sTics
                    if sTics.0*10 > yTics.0*15 { // still use yTics
                        let step = (sMax-sMin)/Double(sTics.0)
                        let ticChange = yTics.0*2-sTics.0
                        if sMin < 0 && sMax > 0  {
                            sMin -= Double(ticChange-ticChange/2)*step
                            sMax += Double(ticChange/2)*step
                        } else {
                            sMax += Double(ticChange)*step
                        }
                        sTics = yTics // now need to put zero back in mix
                    } else {// use sTics
                        let step = (yMax-yMin)/Double(yTics.0)
                        let ticChange = sTics.0-yTics.0
                        if yMin < 0 && yMax > 0  {
                            yMin -= Double(ticChange-ticChange/2)*step
                            yMax += Double(ticChange/2)*step
                        } else {
                            yMax += Double(ticChange)*step
                        }
                        yTics = sTics
                    }
                } else {
                    if yTics.0*10 > sTics.0*15 { // still use sTics
                        let step = (yMax-yMin)/Double(yTics.0)
                        let ticChange = sTics.0*2-yTics.0
                        if sMin < 0 && sMax > 0 && -sMin > sMax {
                            yMin -= Double(ticChange-ticChange/2)*step
                            yMax += Double(ticChange/2)*step
                        } else {
                            yMax += Double(ticChange)*step
                        }
                        yTics = sTics
                    } else { // use
                        let step = (sMax-sMin)/Double(sTics.0)
                        let ticChange = (yTics.0-sTics.0)
                        if sMin < 0 && sMax > 0 {
                            sMin -= Double(ticChange-ticChange/2)*step
                            sMax += Double(ticChange/2)*step
                        } else {
                            sMax += Double(ticChange)*step
                        }
                        sTics = yTics
                    }
                }
                if settings.showSecondaryAxis {
                    if  !secondaryPresent  {
                        newData.settings.showSecondaryAxis = false
                    }
                }
            } else { yTics = sTics; yMax = sMax; yMin = sMin; newData.settings.showSecondaryAxis = false}
        } else { // independentTics or no sTics
            // Check that the axes have some tics and if not change so it does
            if yTics.0 == 0 { yTics = (10,5) }
            if sTics.0 == 0 { sTics = (10,5) }
            if xTics.0 == 0 { xTics = (10,5) }
        }
        // Assign to settings
        newData.settings.xAxis = AxisParameters(min: xMin, max: xMax, majorTics: xTics.0, minorTics: xTics.1, title: settings.xAxis?.title)
        newData.settings.yAxis = AxisParameters(min: yMin, max: yMax, majorTics: yTics.0, minorTics: yTics.1, title: settings.yAxis?.title)
        newData.settings.sAxis = AxisParameters(min: sMin, max: sMax, majorTics: sTics.0, minorTics: sTics.1, title: settings.sAxis?.title)
    
        newData.settings.legendPos = self.settings.legendPos
       
        self = newData
    }
}
