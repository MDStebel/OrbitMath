# OrbitMath
## drawOrbital
Algorithm to correctly draw a real-time orbit at a satellite's position and inclination on the Earth as the Earth is rotated through x, y, and z coordinates.

Using the ISS as an example, we want:
	1.	The orbit plane to remain at a 52° inclination relative to Earth’s equatorial plane (i.e., 52° from the Earth’s y-axis in SceneKit).
	2.	The orbit ring itself to pass through the ISS’s current position on every update.

In other words, we need to reorient the ring plane so that:
	•	Its normal vector (n) is always 52° from the Earth’s +Y axis.
	•	That same plane contains the ISS’s position vector (S) from Earth’s center, meaning n · S = 0.

This is an optimized empirical solution.

Note: There are infinitely many planes that satisfy “angle(n, Y) = 52° and n·S=0.” We’ll just pick a consistent one so that we get a stable orientation for the ring.

## satelliteVisibilityDiameterWithMinElevation
Computes the diameter of the visibility circle from which a satellite is visible above a minimum elevation.
