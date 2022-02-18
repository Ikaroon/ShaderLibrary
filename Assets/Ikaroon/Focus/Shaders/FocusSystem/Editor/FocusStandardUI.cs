using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Linq;

public class FocusStandardUI : ShaderGUI
{
    override public void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
    {
        // render the shader properties using the default GUI
        base.OnGUI(materialEditor, properties);

        // get the current keywords from the material
        Material targetMat = materialEditor.target as Material;
        targetMat.globalIlluminationFlags = (MaterialGlobalIlluminationFlags)EditorGUILayout.EnumMaskPopup(new GUIContent("Emissive GI"), targetMat.globalIlluminationFlags);
        materialEditor.LightmapEmissionFlagsProperty(10, true);
    }
}
