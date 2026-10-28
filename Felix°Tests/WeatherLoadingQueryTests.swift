//
//  WeatherLoadingQueryTests.swift
//  Felix°Tests
//
//  Pure-logic tests for the loading-query ordering used to track in-flight refresh work.
//

import Testing

@testable import Felix

struct WeatherLoadingQueryTests {
	@Test
	func sortOrderFollowsDeclarationOrder() {
		let shuffled: [WeatherLoadingQuery] = [.alerts, .forecast, .airQuality]
		#expect(shuffled.sorted() == [.forecast, .airQuality, .alerts])
	}

	@Test
	func comparablePairsAreOrdered() {
		#expect(WeatherLoadingQuery.forecast < .airQuality)
		#expect(WeatherLoadingQuery.airQuality < .alerts)
	}

	@Test
	func everyCaseHasADisplayName() {
		for query in WeatherLoadingQuery.allCases {
			#expect(!query.displayName.isEmpty)
		}
	}
}
