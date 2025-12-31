//
//  GoogleSheetsClient.swift
//  BEARDOWN
//
//  Created by Weston Crewe on 12/29/25.
//

import Foundation

struct GoogleSheetsClient {
    let accessToken: String

    /// Reads a range using Google Sheets API v4.
    /// Example range: "Schedule!A1:H20"
    func readValues(spreadsheetId: String, range: String) async throws -> [[String]] {
        var components = URLComponents(string: "https://sheets.googleapis.com/v4/spreadsheets/\(spreadsheetId)/values/\(range)")!
        // optional: valueRenderOption, dateTimeRenderOption, etc.
        components.queryItems = [
            URLQueryItem(name: "majorDimension", value: "ROWS")
        ]

        var req = URLRequest(url: components.url!)
        req.httpMethod = "GET"
        req.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? ""
            throw NSError(domain: "Sheets", code: 1, userInfo: [NSLocalizedDescriptionKey: "Sheets error: \(body)"])
        }

        struct Response: Decodable {
            let values: [[String]]?
        }

        let decoded = try JSONDecoder().decode(Response.self, from: data)
        return decoded.values ?? []
    }
}
