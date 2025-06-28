import Foundation

/// Computes the diameter of the visibility circle from which a satellite is visible above a minimum elevation.
/// - Parameters:
///   - altitudeKm: Altitude of the satellite in kilometers.
///   - minElevationDegrees: Minimum elevation angle above the horizon for visibility (e.g. 10°).
/// - Returns: Ground visibility diameter in kilometers.
func satelliteVisibilityDiameterWithMinElevation(altitudeKm: Double, minElevationDegrees: Double) -> Double {
    let earthRadiusKm = 6371.0
    let satRadiusKm = earthRadiusKm + altitudeKm
    let elevationRad = minElevationDegrees * Double.pi / 180.0
    
    // Central angle alpha in radians
    let cosAlpha = (cos(elevationRad) * satRadiusKm) / earthRadiusKm
    guard cosAlpha <= 1 else { return 0 } // invalid geometry
    
    let alpha = acos(cosAlpha)
    let arcDistance = earthRadiusKm * alpha
    return 2 * arcDistance
}
