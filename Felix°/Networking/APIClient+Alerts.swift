import CoreLocation
import Foundation

enum AlertResponse {
	case canadian(Operations.getCanadianWeatherAlerts.Output.Ok.Body.jsonPayload)
}

extension APIClient {
	func getAlerts(
		coordinates: CLLocationCoordinate2D,
		countryCode: String? = nil
	) async throws -> AlertResponse {
		let useCanadian: Bool
		if let countryCode {
			useCanadian = countryCode == "CA"
		} else {
			useCanadian = isCanadianLocation(coordinates)
		}

		if useCanadian {
			return try await getCanadianWeatherAlerts(coordinates: coordinates)
		}
		return .canadian([])
	}

	private func isCanadianLocation(_ coordinates: CLLocationCoordinate2D) -> Bool {
		guard coordinates.latitude <= 84.0,
			coordinates.longitude >= -141.0,
			coordinates.longitude <= -52.0
		else {
			return false
		}

		let minimumLatitude = coordinates.longitude < -95.0 ? 49.0 : 45.0
		return coordinates.latitude >= minimumLatitude
	}

	private func getCanadianWeatherAlerts(coordinates: CLLocationCoordinate2D) async throws
		-> AlertResponse
	{
		let outboundCoordinates = LocationService.outboundCoordinate(coordinates)
		let response = try await canadaWeather.getCanadianWeatherAlerts(
			.init(
				path: .init(
					latitude: outboundCoordinates.latitude,
					longitude: outboundCoordinates.longitude
				)
			))

		switch response {
		case .ok(let response):
			switch response.body {
			case .json(let result):
				return .canadian(result)
			}
		case .undocumented:
			return .canadian([])
		}
	}
}
