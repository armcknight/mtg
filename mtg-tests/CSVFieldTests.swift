//
//  CSVFieldTests.swift
//  
//
//  Created by Andrew McKnight on 1/7/24.
//

import XCTest

final class CSVFieldTests: XCTestCase {
    func testRFC4180CompliantFieldWithDoubleQuotes() {
        [
            // "Test" should remain as "Test", where the double quotes are surrounding the entire field contents
            ("\"Test\"", "\"Test\""),
            
            // test that double quotes are properly escaped
            
            // ""Test"", where the field is surrounded by double quotes, and the field contents themselves are "Test", then the inner double quotes must be escaped to """Test"""
            ("\"\"Test\"\"", "\"\"\"Test\"\"\""),
            
            // "Test with "inner quotes"" escapes the double quotes around `inner quotes` to produce "Test with ""inner quotes"""
            ("\"Test with \"inner quotes\"\"", "\"Test with \"\"inner quotes\"\"\""),
            
            // ""Inner quote" test" escapes the double quotes around `Inner quote` to produce """Inner quote"" test"
            ("\"\"Inner quote\" test\"", "\"\"\"Inner quote\"\" test\""),
            
            // "Test with "inner quotes" in the string" escapes the double quotes around `inner quotes` to produce "Test with ""inner quotes"" in the string"
            ("\"Test with \"inner quotes\" in the string\"", "\"Test with \"\"inner quotes\"\" in the string\""),
            
            // test that quotes already escaped aren't escaped again, which would double their amounts each time
            
            ("\"\"\"Test\"\"\"", "\"\"\"Test\"\"\""),
            ("\"Test with \"\"inner quotes\"\"\"", "\"Test with \"\"inner quotes\"\"\""),
            ("\"\"\"Inner quote\"\" test\"", "\"\"\"Inner quote\"\" test\""),
            ("\"Test with \"\"inner quotes\"\" in the string\"", "\"Test with \"\"inner quotes\"\" in the string\""),
        ].forEach {
            XCTAssertEqual($0.1, $0.0.rfc4180CompliantFieldWithDoubleQuotes)
        }
    }

    func testValueOfRFC4180CompliantFieldWithDoubleQuotes() {
        [
            // "Test" should remain as "Test", where the double quotes are surrounding the entire field contents
            ("\"Test\"", "\"Test\""),
            
            // test that double quotes are properly unescaped
            
            // """Test""", where the field is surrounded by double quotes, and the field contents themselves are "Test", then the inner double quotes must be unescaped to ""Test""
            ("\"\"\"Test\"\"\"", "\"\"Test\"\""),
            
            // "Test with ""inner quotes""" unescapes the double quotes around `inner quotes` to produce "Test with ""inner quotes"""
            ("\"Test with \"\"inner quotes\"\"\"", "\"Test with \"inner quotes\"\""),
            
            // """Inner quote"" test" unescapes the double quotes around `Inner quote` to produce """Inner quote"" test"
            ("\"\"\"Inner quote\"\" test\"", "\"\"Inner quote\" test\""),
            
            // "Test with ""inner quotes"" in the string" unescapes the double quotes around `inner quotes` to produce "Test with "inner quotes" in the string"
            ("\"Test with \"\"inner quotes\"\" in the string\"", "\"Test with \"inner quotes\" in the string\""),
            
            // test that quotes already unescaped aren't escaped again, which would halve their amounts each time
            
            ("\"\"Test\"\"", "\"\"Test\"\""),
            ("\"Test with \"inner quotes\"\"", "\"Test with \"inner quotes\"\""),
            ("\"\"Inner quote\" test\"", "\"\"Inner quote\" test\""),
            ("\"Test with \"inner quotes\" in the string\"", "\"Test with \"inner quotes\" in the string\""),
        ].forEach {
            XCTAssertEqual($0.1, $0.0.valueOfRFC4180CompliantFieldWithDoubleQuotes)
        }
    }

}
