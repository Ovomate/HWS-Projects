import UIKit

// MARK: Get index of Char in string
let name = "Stefan Storm"

let letter = name[name.index(name.startIndex, offsetBy: 3)]

extension String{
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}
let letterExtension = name[9]

//Alwayse better to use
name.isEmpty
//than
name.count == 0

//MARK: Delete prefix || suffix

let password = "123456"
password.hasPrefix("123")
password.hasSuffix("456")

extension String{
    func deletePrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else {return self}
        return String(self.dropFirst(prefix.count))
    }
}

extension String{
    func deleteSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else {return self}
        return String(self.dropLast(suffix.count))
    }
}

//MARK: Capitalize first letter
let weather = "it's going to rain"

extension String {
    var capitalizedFirst : String {
        guard let firstLetter = self.first else {return ""}
        return firstLetter.uppercased() + self.dropFirst()
    }
}

//MARK: Check whether string and array contains a match

let input = "Swift is like objective-c without the C"
input.contains("Swift") // true

let languages = ["Swift", "Python", "C#",]
languages.contains("Swift") // true

//Check if there is a match between array and string

languages.contains(where: input.contains)

//Check specific "Swift"
let check = languages.filter{input.contains($0)}.contains("Swift")

//MARK: Formatting strings with NSAttributedString

let string = "This is a test string!"

let attributes : [NSAttributedString.Key: Any] = [
    .foregroundColor : UIColor.white,
    .backgroundColor : UIColor.red,
    .font : UIFont.boldSystemFont(ofSize: 40),
    .strokeColor : UIColor.green
    ]

let attributedString = NSAttributedString(string: string, attributes: attributes)

let attributedStringSample = NSMutableAttributedString(string: string)
attributedStringSample.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 4))
attributedStringSample.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 5, length: 2))
attributedStringSample.addAttribute(.font, value: UIFont.systemFont(ofSize: 24), range: NSRange(location: 8, length: 1))
attributedStringSample.addAttribute(.font, value: UIFont.systemFont(ofSize: 32), range: NSRange(location: 10, length: 4))
attributedStringSample.addAttribute(.font, value: UIFont.systemFont(ofSize: 40), range: NSRange(location: 15, length: 6))


//Challenge
//MARK: WithPrefix method
let str1 = "key"
let str2 = "mon"
let str3 = "monkey"

extension String {
    func withPrefix(_ prefix: String) -> String{
        guard !self.hasPrefix(prefix) else {return ""}
        return prefix + self
    }
}

str1.withPrefix(str2)
str1.withPrefix(str1)
str3.withPrefix(str2)
str2.withPrefix(str1)

//MARK: Check if string is number

let one = "1"
let two = "two"


extension String {
    func isNumeric() -> Bool {
        if let number = Int(self){
            return true
        }else{
            return false
        }
    }
}

one.isNumeric()
two.isNumeric()

//MARK: Add lines \n

let testString = "this\nis\na\ntest"
let addBreakTestString = "This is a long string to test linebreaks!"

//Extension to place word in an array after every linebreak.
extension String {
    func createLineBreakArray() -> [String]{
        self.components(separatedBy: "\n")
    }
    
}

//Extension to add a linebreak after every word.
extension String {
    func addLineBreakAfterEveryWord() -> String{
        self.replacingOccurrences(of: " ", with: "\n")
    }
}

testString.createLineBreakArray()
addBreakTestString.addLineBreakAfterEveryWord()

