// NumericTextField.swift
import SwiftUI

/// A `TextField` replacement that limits user input to numbers.
public struct NumericTextField: View {
    public let title: LocalizedStringKey
    /// This is what consumers of the text field will access
    @Binding public var numericText: String
    public var style: NumericStringStyle = NumericStringStyle.defaultStyle
    
    /// onSubmit since iOS 15 can be used
    public var onEditingChanged: (Bool) -> Void = { _ in }
    public var onCommit: () -> Void = { }

  
    /// Creates a text field with a text label generated from a localized title string.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the localized title of the text field,
    ///     describing its purpose.
    ///   - numericText: The number to be displayed and edited.
    ///   - isDecimalAllowed: Should the user be allowed to enter a decimal number, or an integer
    ///   - isExponentAllowed: Should the user be allowed to enter a e or E exponent character
    ///   - isMinusAllowed:Should user be allow to enter negative numbers
    ///   - //formatter: NumberFormatter to use on getting focus or losing focus used by on EditingChanged now reformat
    ///   - onEditingChanged: An action thats called when the user begins editing `text` and after the user finishes editing `text`.
    ///     The closure receives a Boolean indicating whether the text field is currently being edited.
    ///   - onCommit: An action to perform when the user performs an action (for example, when the user hits the return key) while the text field has focus.
    /**/
    var range: ClosedRange<Double> {
        if let ld = style.range?.lowerBound {
            if let ud = style.range?.upperBound {
                return (ld...ud)
            } else { // u open
                return ld...Double.infinity
            }
        } else { //ld open
            if let ud = style.range?.upperBound {
                return -Double.infinity...ud
            }
        }
        return -Double.infinity...Double.infinity
    }
            
    public var body: some View {
        TextField(title, text: $numericText,//.string
            onEditingChanged: { exited in
                if !exited {
                    numericText = reformat(numericText)
                }
                onEditingChanged(exited)
            },
            onCommit: {
                  numericText = reformat(numericText)//see bounds comment above
                onCommit()
        })
            .numericText( number: $numericText, style: style )
            .onAppear { numericText = reformat(numericText)}
            .modifier(KeyboardModifier(isDecimalAllowed: style.decimalSeparator))
    }
}

func reformat(_ stringValue: String) -> String {
    let value = NumberFormatter().number(from: stringValue)
    if let v = value {
        let compare = v.compare(NSNumber(value: 0.0))
        if compare == .orderedSame {
            return String("0")
        }
        if compare == .orderedAscending { // v negative
            let compare = v.compare(NSNumber(value: -1e-3))
            if compare != .orderedDescending {
                let compare = v.compare(NSNumber(value: -1e5))
                if compare == .orderedDescending {
                    return String(v.decimalStyle)
                }
            }
        } else { // v positive
            let compare = v.compare(NSNumber(value: 1e5))
            if compare == .orderedAscending {
                let compare = v.compare(NSNumber(value: 1e-3))
                if compare != .orderedAscending {
                    return String(v.decimalStyle)
                }
            }
            return String(v.scientificStyle)
        }
    }
    return stringValue
}

private struct KeyboardModifier: ViewModifier {
    let isDecimalAllowed: Bool

    func body(content: Content) -> some View {
        #if os(iOS)
        return content
            .keyboardType(isDecimalAllowed ? .decimalPad : .numberPad)
        #else
        return content
        #endif
    }
}


struct NumericTextField_Previews: PreviewProvider {
    @State static var int = String("0")
    @State static var double = String("0")
    
    static var previews: some View {
        VStack {
            HStack {
                NumericTextField("Int", numericText: $int, style: NumericStringStyle(decimalSeparator: false))
                    .frame(width: 200)
                    .border(Color.black, width: 1)
                    .padding()
                
                Text(int + " is the Int), and ")}
            
            
            
            HStack {
                NumericTextField( "Double", numericText: $double)
                    .frame(width: 200)
                    .border(Color.black, width: 1)
                    .padding()
                
                Text( double + " is the double")}
        }
    }
}

extension NumericTextField {
    ///  Same as built-in init except title: is _
    public init(_ titleKey: LocalizedStringKey, numericText: Binding<String>, style: NumericStringStyle = NumericStringStyle(),
        //formatter: NumberFormatter =  {
        //    let formatter = NumberFormatter()
        //    formatter.numberStyle = .decimal
        //    return formatter}() }
        //self.formatter = formatter
        onEditingChanged: @escaping (Bool) -> Void = { _ in  },
        onCommit: @escaping () -> Void = {}) {
        self.title = titleKey
        self._numericText = numericText
        self.style = style
        self.onCommit = onCommit
        self.onEditingChanged = onEditingChanged
    }
}



