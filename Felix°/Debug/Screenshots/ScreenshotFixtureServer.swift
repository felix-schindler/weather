#if DEBUG

	import Foundation
	import HTTPTypes
	import OpenAPIRuntime

	final class ScreenshotFixtureServer: URLProtocol {
		override class func canInit(with request: URLRequest) -> Bool {
			guard ScreenshotMode.active, let url = request.url else { return false }
			return route(for: url) != nil
		}

		override class func canonicalRequest(for request: URLRequest) -> URLRequest {
			request
		}

		override func startLoading() {
			guard let staged = Self.stagedFetch(request) else {
				client?.urlProtocol(self, didFailWithError: URLError(.unsupportedURL))
				return
			}
			let (body, response) = staged
			client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
			client?.urlProtocol(self, didLoad: body)
			client?.urlProtocolDidFinishLoading(self)
		}

		override func stopLoading() {}

		// MARK: - Staged responses (non-URLProtocol paths)

		static func stagedResponse(for url: URL) -> (body: Data, contentType: String)? {
			guard ScreenshotMode.active, let route = route(for: url) else { return nil }
			return try? route(url)
		}

		static func stagedFetch(_ request: URLRequest) -> (Data, HTTPURLResponse)? {
			guard let url = request.url, let staged = stagedResponse(for: url) else { return nil }
			let response = HTTPURLResponse(
				url: url, statusCode: 200, httpVersion: "HTTP/1.1",
				headerFields: ["Content-Type": staged.contentType]
			)!
			return (staged.body, response)
		}

		// MARK: - Routing

		private typealias Route = (URL) throws -> (Data, String)

		private static func json(_ make: @escaping (URL) -> Any) -> Route {
			{ url in (try JSONSerialization.data(withJSONObject: make(url)), "application/json") }
		}

		private static func isBatchForecast(_ url: URL) -> Bool {
			URLComponents(url: url, resolvingAgainstBaseURL: false)?
				.queryItems?.first { $0.name == "latitude" }?.value?.contains(",") == true
		}

		private static func route(for url: URL) -> Route? {
			guard let host = url.host() else { return nil }
			let path = url.path()

			switch host {
			case "api.open-meteo.com" where path.hasPrefix("/v1/forecast"):
				return json { url in
					if isBatchForecast(url) {
						return ScreenshotFixtures.conditionsBatchJSON(for: url)
					}
					return ScreenshotFixtures.forecastJSON()
				}
			case "geocoding-api.open-meteo.com":
				return json { _ in ScreenshotFixtures.geocodeSearchJSON() }
			case "air-quality-api.open-meteo.com":
				return json { _ in ScreenshotFixtures.airQualityJSON() }
			case "ensemble-api.open-meteo.com":
				return json { _ in ScreenshotFixtures.ensembleJSON() }
			case "archive-api.open-meteo.com":
				return json { url in ScreenshotFixtures.archiveJSON(for: url) }
			default:
				return nil
			}
		}
	}

	struct ScreenshotFixtureMiddleware: ClientMiddleware {
		func intercept(
			_ request: HTTPRequest,
			body: HTTPBody?,
			baseURL: URL,
			operationID: String,
			next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
		) async throws -> (HTTPResponse, HTTPBody?) {
			if let url = URL(string: baseURL.absoluteString + (request.path ?? "")),
				let staged = ScreenshotFixtureServer.stagedResponse(for: url)
			{
				var response = HTTPResponse(status: .ok)
				response.headerFields[.contentType] = staged.contentType
				return (response, HTTPBody(staged.body))
			}
			return try await next(request, body, baseURL)
		}
	}
#endif
