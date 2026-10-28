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
		let shuffled: [WeatherLoadingQuery] = [.airQuality, .forecast]
		#expect(shuffled.sorted() == [.forecast, .airQuality])
	}

	@Test
	func comparablePairsAreOrdered() {
		#expect(WeatherLoadingQuery.forecast < .airQuality)
	}

	@Test
	func everyCaseHasADisplayName() {
		for query in WeatherLoadingQuery.allCases {
			#expect(!query.displayName.isEmpty)
		}
	}
}
