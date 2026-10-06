package unity.ui;

import unity.Material;

// Minimal UnityEngine.UI.IMaterialModifier shim.
interface IMaterialModifier {
    function GetModifiedMaterial(baseMaterial:Material):Material;
}
