import SceneKit
import SwiftUI

/// Handles orbital transforms
extension EarthGlobe {

    /// Create an orbital track around the globe at the satellite's precise orbital inclination and location, heading, and altitude
    ///
    /// This is my empirical algorithm that keeps the orbital orientation correct no matter how the globe is rotated in all degrees of freedom, even though the position of the globe in the scene uses a different coordinate system.
    /// - Parameters:
    ///   - station: Type of satellite as a SatelliteID type
    ///   - lat: Latitude as a decimal value as a Float
    ///   - lon: Longitude as a decimal value as a Float
    ///   - headingFactor: Indicates whether the satellite is heading generally north or south as a Float
    public func addOrbitTrackAroundTheGlobe(for station: StationsAndSatellites, lat: Float, lon: Float, headingFactor: Float) {
        let orbitTrack = createOrbitTrack(for: station)
        guard let orbitTrackNode = orbitTrack else { return }
        
        globe.addChildNode(orbitTrackNode)
        
        let adjustedCoordinates = adjustCoordinates(lat: lat, lon: lon)
        let orbitalCorrectionForLon = adjustedCoordinates.lon * Float(Globals.degreesToRadians)
        let orbitalCorrectionForLat = adjustedCoordinates.lat * Float(Globals.degreesToRadians)
        let absLat = abs(lat)
        
        let orbitInclination = station.orbitalInclinationInRadians
        let multiplier = station.multiplier
        let exponent = calculateExponent(absLat: absLat, orbitInclination: orbitInclination, multiplier: multiplier)
        
        let orbitalCorrectionForInclination = calculateOrbitalCorrectionForInclination(for: station, absLat: absLat, exponent: exponent)
        let orbitInclinationInRadiansCorrected = pow(orbitInclination, orbitalCorrectionForInclination) * headingFactor
        
        let compositeRotationMatrix = createCompositeRotationMatrix(orbitInclinationInRadiansCorrected: orbitInclinationInRadiansCorrected, orbitalCorrectionForLon: orbitalCorrectionForLon, orbitalCorrectionForLat: orbitalCorrectionForLat)
        
        orbitTrackNode.transform = compositeRotationMatrix
    }

    // MARK: - Helper functions

    private func createOrbitTrack(for station: StationsAndSatellites) -> SCNNode? {
        let orbitTrack = SCNTorus()
        
        switch station {
        case .iss:
            orbitTrack.firstMaterial?.diffuse.contents = Theme.issrtt3dRedCGColor
            orbitTrack.ringRadius = CGFloat(Globals.issOrbitAltitudeInScene)
            orbitTrack.pipeRadius = pipeRadius
            orbitTrack.ringSegmentCount = ringSegmentCount
            orbitTrack.pipeSegmentCount = pipeSegmentCount
        case .tss:
            orbitTrack.firstMaterial?.diffuse.contents = Theme.issrtt3dGoldCGColor
            orbitTrack.ringRadius = CGFloat(Globals.tssOrbitAltitudeInScene)
            orbitTrack.pipeRadius = pipeRadius
            orbitTrack.ringSegmentCount = ringSegmentCount
            orbitTrack.pipeSegmentCount = pipeSegmentCount
        case .hst:
            orbitTrack.firstMaterial?.diffuse.contents = Theme.hubbleOrbitalCGColor
            orbitTrack.ringRadius = CGFloat(Globals.hubbleOrbitAltitudeInScene)
            orbitTrack.pipeRadius = pipeRadius
            orbitTrack.ringSegmentCount = ringSegmentCount
            orbitTrack.pipeSegmentCount = pipeSegmentCount
        case .none:
            return nil
        }
        return SCNNode(geometry: orbitTrack)
    }
    
    private func adjustCoordinates(lat: Float, lon: Float) -> (lat: Float, lon: Float) {
        let adjustedLat = lat + Float(Globals.oneEightyDegrees)
        let adjustedLon = lon - Float(Globals.oneEightyDegrees)
        return (lat: adjustedLat, lon: adjustedLon)
    }
    
    private func calculateExponent(absLat: Float, orbitInclination: Float, multiplier: Float) -> Float {
        return .pi / multiplier + absLat * Float(Globals.degreesToRadians) / orbitInclination
    }
    
    private func calculateOrbitalCorrectionForInclination(for station: StationsAndSatellites, absLat: Float, exponent: Float) -> Float {
        switch station {
        case .iss:
            return calculateOrbitalCorrection(absLat: absLat, exponent: exponent, thresholds: [12.0, 17.0, 25.0, 33.0, 40.0, 45.0, 49.0, 51.0], powers: [0.80, 0.85, 1.00, 1.25, 1.60, 2.00, 2.50, 3.20, 4.00])
        case .tss:
            return calculateOrbitalCorrection(absLat: absLat, exponent: exponent, thresholds: [15.0, 20.0, 25.0, 30.0, 35.0, 38.0, 40.0, 41.0, 41.5], powers: [0.75, 0.85, 1.00, 1.20, 1.45, 1.70, 2.00, 2.30, 2.50, 2.80])
        case .hst:
            return calculateOrbitalCorrection(absLat: absLat, exponent: exponent, thresholds: [10.0, 15.0, 18.0, 20.0, 22.0, 24.0, 26.0, 27.0], powers: [0.35, 0.50, 0.65, 0.80, 1.00, 1.30, 1.75, 2.10, 3.00])
        case .none:
            return 0.0
        }
    }
    
    private func calculateOrbitalCorrection(absLat: Float, exponent: Float, thresholds: [Float], powers: [Float]) -> Float {
        for (index, threshold) in thresholds.enumerated() {
            if absLat <= threshold {
                return pow(exponent, powers[index])
            }
        }
        return pow(exponent, powers.last ?? 1.0)
    }
    
    private func createCompositeRotationMatrix(orbitInclinationInRadiansCorrected: Float, orbitalCorrectionForLon: Float, orbitalCorrectionForLat: Float) -> SCNMatrix4 {
        var rotationMatrix1 = SCNMatrix4Identity
        var rotationMatrix2 = SCNMatrix4Identity
        var rotationMatrix3 = SCNMatrix4Identity
        
        rotationMatrix1 = SCNMatrix4RotateF(rotationMatrix1, orbitInclinationInRadiansCorrected, 0, 0, 1)
        rotationMatrix2 = SCNMatrix4RotateF(rotationMatrix2, orbitalCorrectionForLon, 0, 1, 0)
        rotationMatrix3 = SCNMatrix4RotateF(rotationMatrix3, orbitalCorrectionForLat, 1, 0, 0)
        
        let firstProduct = SCNMatrix4Mult(rotationMatrix3, rotationMatrix2)
        return SCNMatrix4Mult(rotationMatrix1, firstProduct)
    }
}
