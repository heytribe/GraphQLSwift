//
//  GraphQL.swift
//  Tribe
//
//  MIT License
//
//  Copyright (c) 2016 Tribe
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation

class NonEscapedGraphQLValue {

    let value: String

    init(value: String) {
        self.value = value
    }
}

class GraphQL {

    enum QueryType {
        case query, mutation, subscription
    }

    private(set) var isMutation: Bool = false
    private(set) var isSubscription: Bool = false
    private(set) var name: String?
    private(set) var mutations: [String: GraphQL]
    private(set) var params: [String: AnyObject]
    private(set) var fields: [AnyObject]

    internal required init(name: String? = nil, queryType: QueryType = .query, params: [String: AnyObject] = [:], fields: [AnyObject] = [], mutations: [String: GraphQL] = [:]) {
        switch queryType {
        case .mutation:
            isMutation = true
        case .subscription:
            isSubscription = true
        default:
            isMutation = false
            isSubscription = false
        }
        self.name = name
        self.mutations = mutations
        self.params = params
        self.fields = fields
    }

    public func build(isSubquery: Bool) -> String {

        var string = ""

        if let name = self.name {
            string += name
        }

        if !mutations.isEmpty {
            string += " { \(mapParams(params: mutations)) }"
        }

        if !params.isEmpty {
            string += " ( \(mapParams(params: params)) )"
        }

        if !fields.isEmpty {
            string += " { \(mapFields(fields: fields)) }"
        }

        if !isSubquery && name != nil {
            string = "{ \(string) }"
        }

        if !isSubquery && isMutation {
            string = "mutation \(string)"
        }

        if !isSubquery && isSubscription {
            string = "subscription \(string)"
        }

        return string
    }

    // First methods

    static func query(name: String? = nil) -> Self {
        return self.init(name: name)
    }

    static func queries(queries: [String: GraphQL]) -> Self {
        return self.init(mutations: queries)
    }

    static func mutation(name: String? = nil) -> Self {
        return self.init(name: name, queryType: .mutation)
    }

    static func mutations(mutations: [String: GraphQL]) -> Self {
        return self.init(queryType: .mutation, mutations: mutations)
    }

    // Name

    func name(name: String) -> Self {
        self.name = name
        return self
    }

    // Fields

    func fields(fields: [AnyObject]) -> Self {
        self.fields = fields
        return self
    }

    func field(field: AnyObject) -> Self {
        fields.append(field)
        return self
    }

    // Params

    func params(key: String, value: AnyObject?) -> Self {
        params[key] = value
        return self
    }

    func param(key: String, value: AnyObject?) -> Self {
        params[key] = value
        return self
    }
}

extension GraphQL: CustomStringConvertible {

    var description: String {
        let desc = build(isSubquery: false)
        print("query desc = \(desc)")
        return desc
    }
}

private func mapValue(value: AnyObject) -> String {

    // STRING
    if let value = value as? NonEscapedGraphQLValue {
        return value.value

    } else if let value = value as? String {
        return "\"\(value.replacingOccurrences(of: "\"", with: "\\\""))\""

        // INT & BOOL
    } else if value is Int {

        // TODO: Find a better way to detect booleans
        if "\(type(of: value))" == "__NSCFBoolean" {
            return (value as! Bool) ? "true" : "false"
        } else {
            return "\(value)"
        }

        // FLOAT & DOUBLE
    } else if value is Float || value is Double {
        return "\(value)"

        // ARRAY
    } else if let value = value as? Array<AnyObject> {
        let mappedSubvalues = value
            .map({ subvalue in mapValue(value: subvalue) })
            .joined(separator: ", ")

        return "[ \(mappedSubvalues) ]"

        // DICTIONARY
    } else if let value = value as? Dictionary<String, AnyObject> {
        let mappedSubvalues = value
            .map({ key, subvalue in "\(key) : \(mapValue(value: subvalue))" })
            .joined(separator: ", ")

        return "{ \(mappedSubvalues) }"

    } else if let value = value as? GraphQL {
        return value.build(isSubquery: true)

    } else {
        return "null"
    }
}

private func mapParams(params: [String: AnyObject]) -> String {

    return params
        .map({ key, value in "\(key) : \(mapValue(value: value))" })
        .joined(separator: ", ")
}

private func mapFields(fields: [AnyObject]) -> String {

    return fields
        .map { field in

            if let field = field as? GraphQL {
                return "\(field.build(isSubquery: true))"
            } else {
                return "\(field)"
            }
        }
        .joined(separator: " ")
}
