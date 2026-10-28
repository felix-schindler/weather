//
//  DailyEnsembleForecastTests.swift
//  Felix°Tests
//
//  Maps the generated ensemble payload onto the domain model, including the
//  per-member `_memberNN` series that the OpenAPI schema keeps in
//  `additionalProperties`.
//

import Foundation
import Testing

@testable import Felix

struct DailyEnsembleForecastTests {
	private func forecast(_ json: String) throws -> DailyEnsembleForecastResponse {
		let payload = try JSONDecoder().decode(
			Components.Schemas.EnsembleForecastResponse.self,
			from: Data(json.utf8)
		)
		return DailyEnsembleForecastResponse(payload)
	}

	@Test
	func mapsBaseAndMemberSeries() throws {
		let response = try forecast(
			"""
			{
			  "utc_offset_seconds": 3600,
			  "timezone": "Europe/Berlin",
			  "daily_units": { "temperature_2m_max": "°C" },
			  "daily": {
			    "time": ["2026-10-28", "2026-10-29"],
			    "temperature_2m_max": [10, 12],
			    "temperature_2m_max_member01": [11, 13],
			    "temperature_2m_max_member02": [9, 11],
			    "precipitation_sum": [0, 2]
			  }
			}
			"""
		)

		#expect(response.dailyUnits["temperature_2m_max"] == "°C")
		#expect(response.timeZone.identifier == "Europe/Berlin")
		#expect(response.daily.highs.count == 3)
		#expect(response.days.count == 2)
		#expect(response.days[0].runs == 3)
		#expect(response.days[0].high?.highest == 11)
		#expect(response.days[0].precipitation?.highest == 0)
		#expect(response.days[0].low == nil)
	}

	@Test
	func toleratesMissingUnits() throws {
		let response = try forecast(
			"""
			{
			  "daily": {
			    "time": ["2026-10-28"],
			    "temperature_2m_max_member01": [7]
			  }
			}
			"""
		)

		#expect(response.utcOffsetSeconds == 0)
		#expect(response.dailyUnits.isEmpty)
		#expect(response.days.count == 1)
		#expect(response.days[0].high?.highest == 7)
	}
}
