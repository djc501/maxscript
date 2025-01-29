Only works with Vray
This script foes the following for an imported megascans material assigned to the selected object:
1. it makes sure that the maps color space and gamma are set correctly - srgb for color, and raw for data
2. filter set to 0.001
3. duplicates the displacement map from the objects vraydisplacementmod into the material's dispalcement slot (and disables it), so that this will travel with the material when merged into other scenes etc
4. Allows you to set the amount of displacement, and sets the shift to negtive half that value
