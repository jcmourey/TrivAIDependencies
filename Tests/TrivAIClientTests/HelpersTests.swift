import Testing
import InlineSnapshotTesting
@testable import TrivAIClient

struct GrowingTests {
    let loremIpsum = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."

    @Test
    func basic() {
        var generator = LCGRandomNumberGenerator(seed: 123_456_789)
        let result = loremIpsum.growing(using: &generator)
        assertInlineSnapshot(of: result, as: .arrayOfStrings) {
            """
            Lorem ipsum 
            Lorem ipsum do
            Lorem ipsum dolor sit amet
            Lorem ipsum dolor sit amet, con
            Lorem ipsum dolor sit amet, consectetur 
            Lorem ipsum dolor sit amet, consectetur adipisci
            Lorem ipsum dolor sit amet, consectetur adipiscing e
            Lorem ipsum dolor sit amet, consectetur adipiscing eli
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, se
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor inc
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incid
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut lab
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore 
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore m
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna 
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
            """
        }
    }
    
    @Test func tooShort() async throws {
        assertInlineSnapshot(of: "test".growing(by: 5...10), as: .arrayOfStrings) {
            """
            test
            """
        }
    }
    
    @Test func empty() async throws {
        assertInlineSnapshot(of: "".growing(), as: .arrayOfStrings) {
            """

            """
        }
    }
    
    @Test func oneCharacter() async throws {
        assertInlineSnapshot(of: "Lorem ipsum dolor sit amet.".growing(by: 1...1), as: .arrayOfStrings) {
            """
            Lo
            Lor
            Lore
            Lorem
            Lorem 
            Lorem i
            Lorem ip
            Lorem ips
            Lorem ipsu
            Lorem ipsum
            Lorem ipsum 
            Lorem ipsum d
            Lorem ipsum do
            Lorem ipsum dol
            Lorem ipsum dolo
            Lorem ipsum dolor
            Lorem ipsum dolor 
            Lorem ipsum dolor s
            Lorem ipsum dolor si
            Lorem ipsum dolor sit
            Lorem ipsum dolor sit 
            Lorem ipsum dolor sit a
            Lorem ipsum dolor sit am
            Lorem ipsum dolor sit ame
            Lorem ipsum dolor sit amet
            Lorem ipsum dolor sit amet.
            """
        }
    }
    
    @Test func veryLong() async throws {
        var generator = LCGRandomNumberGenerator(seed: 123_456_789)
        let result = loremIpsum.growing(by: 50...100, using: &generator)
        assertInlineSnapshot(of: result, as: .arrayOfStrings) {
            """
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labo
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
            """
        }
    }
    
    @Test func negative() async throws {
        var generator = LCGRandomNumberGenerator(seed: 123_456_789)
        let result = loremIpsum.growing(by: -100...10, using: &generator)
        assertInlineSnapshot(of: result, as: .arrayOfStrings) {
            """
            Lo
            Lor
            Lorem 
            Lorem i
            Lorem ip
            Lorem ips
            Lorem ipsu
            Lorem ipsum
            Lorem ipsum 
            Lorem ipsum dolor si
            Lorem ipsum dolor sit
            Lorem ipsum dolor sit 
            Lorem ipsum dolor sit amet
            Lorem ipsum dolor sit amet,
            Lorem ipsum dolor sit amet, 
            Lorem ipsum dolor sit amet, c
            Lorem ipsum dolor sit amet, co
            Lorem ipsum dolor sit amet, con
            Lorem ipsum dolor sit amet, cons
            Lorem ipsum dolor sit amet, consectetur
            Lorem ipsum dolor sit amet, consectetur 
            Lorem ipsum dolor sit amet, consectetur a
            Lorem ipsum dolor sit amet, consectetur ad
            Lorem ipsum dolor sit amet, consectetur adi
            Lorem ipsum dolor sit amet, consectetur adip
            Lorem ipsum dolor sit amet, consectetur adipi
            Lorem ipsum dolor sit amet, consectetur adipis
            Lorem ipsum dolor sit amet, consectetur adipisc
            Lorem ipsum dolor sit amet, consectetur adipisci
            Lorem ipsum dolor sit amet, consectetur adipiscin
            Lorem ipsum dolor sit amet, consectetur adipiscing
            Lorem ipsum dolor sit amet, consectetur adipiscing elit,
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, 
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, s
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, se
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed 
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed d
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do 
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusm
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmo
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod 
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod t
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod te
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tem
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod temp
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempo
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor 
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor i
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor in
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor inc
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor inci
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incid
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incidi
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incidid
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididu
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididun
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt 
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt u
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut 
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut l
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut la
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut lab
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labo
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labor
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore 
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore e
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et 
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et d
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et do
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dol
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolo
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolor
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore 
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore m
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore ma
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna a
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna al
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna ali
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliq
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqu
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua
            Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.
            """
        }
    }
}
    
