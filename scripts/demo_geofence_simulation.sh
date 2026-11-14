#!/bin/bash
# demo_geofence_simulation.sh
# Automates location simulation for Loom video recording.

echo "================================================="
echo "  GeoCircle - Live Geofence Exit Demo Simulator  "
echo "================================================="
echo ""

echo "Step 1: Setting simulator location INSIDE safe zone (Home, Baridih: 22.802772, 86.256396)..."
xcrun simctl location booted set 22.802772,86.256396
echo "✅ Location set inside Home safe zone."
echo ""

echo "Waiting 6 seconds while the app registers the region..."
for i in {6..1}; do
    echo -n "$i... "
    sleep 1
done
echo ""
echo ""

echo "Step 2: Simulating member EXITING the safe zone (moving 3km towards Sakchi: 22.805000, 86.210000)..."
xcrun simctl location booted set 22.805000,86.210000
echo "🚨 Exit simulated! CoreLocation will trigger didExitRegion event."
echo "Check your device / simulator for the geofence exit alert."
echo "================================================="
