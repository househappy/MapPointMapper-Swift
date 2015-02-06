//
//  Parser.swift
//  MapPointMapper
//
//  Created by Daniel on 11/20/14.
//  Copyright (c) 2014 dmiedema. All rights reserved.
//

import Foundation
import MapKit

class Parser {
    // MARK: - Public
    class func parseString(input: NSString) -> [[CLLocationCoordinate2D]] {
        return self.init().parseInput(input)
    }
    
    class func parseArray(input: [String]) -> [[CLLocationCoordinate2D]] {
        return self.init().parseInput(input)
    }
    
    class func parseDictionary(input: [String: String]) -> [[CLLocationCoordinate2D]] {
        return self.init().parseInput(input)
    }
    
    // MARK: - Private
    private var longitudeFirst = false
    
    // MARK: Parsing
    private func parseInput(input: AnyObject) ->  [[CLLocationCoordinate2D]] {
        var results = [[(String, String)]()]
        
        if let arr = input as? Array<Dictionary<String, String>> {
        } else {
            var first = ""
            var array = [[NSString]]()
            
            if let line = input as? NSString {
                var str: NSString = line
            
                if isPolygon(line) {
                    longitudeFirst = true
                    var polygons = [NSString]()
                    
                    if isMultipolygon(line) {
                        polygons = stripExtraneousCharacters(line).componentsSeparatedByString("), ")
                    } else {
                        polygons = [stripExtraneousCharacters(line)]
                    }
                    
                    array = polygons.map({ self.formatPolygonString($0) }).map({ self.formatCustomLatLongString($0)})
                    
                    
                    // Convert commas to new lines since that becomes our delimiter
                } else {
//                    str = str.stringByReplacingOccurrencesOfString("\n", withString: ",")
//                    
//                    array = [str.componentsSeparatedByString(",") as [NSString]]
//                    
//                    // array = array.filter { (s) -> Bool in !s.isEmpty }
//                    array = array.filter { ($0.length > 0) }
//                    
//                    if array.isEmpty { return [] }
//                    first = array.first!
                }
            } else if let arr = input as? [NSString] {
//                array = arr
//                first = arr.first!
            }
            
            if isSpaceDelimited(first) {
//                let delimiter = " "
//                results = array.map { self.splitLine($0, delimiter: delimiter) }
            } else {
//                array.map { self.splitLine("\($0),\($1)", delimiter: ",") }
                var tmpResults = [(String, String)]()
                for arr in array {
                    for var i = 0; i < arr.count - 1; i += 2 {
                        tmpResults.append((arr[i], arr[i + 1]))
                    }
                    if tmpResults.count == 1 {
                        tmpResults.append(tmpResults.first!)
                    }
                    results.append(tmpResults)
                    tmpResults.removeAll(keepCapacity: false)
                }
                
                
            }
        } // end else
        
        // Handle the case of only getting a single point.
        // We add the point twice so that we can still draw a 'line' between the points
//        if results.count == 1 {
//            results.append(results.first!)
//        }
        
        
        return results.filter({ !$0.isEmpty }).map{ self.convertToCoordinates($0) }
    }
    
    private func formatPolygonString(input: NSString) -> NSString {
        return input
            .stringByReplacingOccurrencesOfString("(", withString: "")
            .stringByReplacingOccurrencesOfString(")", withString: "")
            .stringByReplacingOccurrencesOfString(", ", withString: "\n")
            .stringByReplacingOccurrencesOfString(" ", withString: ",")
    }
    
    private func formatCustomLatLongString(input: NSString) -> [NSString] {
        return input.stringByReplacingOccurrencesOfString("\n", withString: ",").componentsSeparatedByString(",") as [NSString]
    }
    
    private func splitLine(input: String, delimiter: String) -> (String, String) {
        let array = input.componentsSeparatedByString(delimiter)
        return (array.first!, array.last!)
    }
    
    private func convertToCoordinates(pairs: [(String, String)]) -> [CLLocationCoordinate2D] {
        var coordinates = [CLLocationCoordinate2D]()
        for pair in pairs {
            var lat: Double = 0.0
            var lng: Double = 0.0
            if longitudeFirst {
                lat = (pair.1 as NSString).doubleValue
                lng = (pair.0 as NSString).doubleValue
            } else {
                lat = (pair.0 as NSString).doubleValue
                lng = (pair.1 as NSString).doubleValue
            }
            coordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lng))
        }
        return coordinates
    }
    
    private func stripExtraneousCharacters(input: String) -> String {
        let regex = NSRegularExpression(pattern: "\\w+ \\(\\((.*)\\)\\)", options: .CaseInsensitive, error: nil)
        let match: AnyObject? = regex?.matchesInString(input, options: .ReportCompletion, range: NSMakeRange(0, input.utf16Count)).first
        let range = match?.rangeAtIndex(1)
        
        let loc = range?.location as Int!
        let len = range?.length as Int!
        
        return (input as NSString).substringWithRange(NSRange(location: loc, length: len))
    }
    
    private func isPolygon(input: String) -> Bool {
        if let isPolygon = input.rangeOfString("POLYGON ", options: .RegularExpressionSearch) {
            return true
        }
        return false
    }
    
    private func isMultipolygon(input: String) -> Bool {
        if let isPolygon = input.rangeOfString("MULTIPOLYGON ", options: .RegularExpressionSearch) {
            return true
        }
        return false
    }
    
    /**
    Determines if a the collection is space delimited or not
    
    :note: This function should only be passed a single entry or else it will probably have incorrect results
    
    :param: input a single entry from the collection as a string
    
    :returns: `true` if elements are space delimited, `false` otherwise
    */
    private func isSpaceDelimited(input: String) -> Bool {
        let array = input.componentsSeparatedByString(" ")
        return array.count > 1
    }
}
