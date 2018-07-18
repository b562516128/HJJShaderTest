using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class RenderToCubmapWizard : ScriptableWizard
{
   // public Transform renderPosition;
    public Camera renderCamera;
    public Cubemap cubemap;
   
    void OnWizardUpdate()
    {
        helpString = "Select transform to render from and cubemap to render into";
        isValid = (renderCamera != null) && (cubemap != null);
    }

    void OnWizardCreate()
    {
        //GameObject obj = new GameObject("renderCamera");
        //obj.AddComponent <Camera> ();
        //obj.GetComponent<Camera>().RenderToCubemap(cubemap);
        //DestroyImmediate(obj);

        renderCamera.RenderToCubemap(cubemap);
    }
    
    [MenuItem("GameObject/Render To Cubmap")]
    static void RenderToCubmap()
    {
        ScriptableWizard.DisplayWizard<RenderToCubmapWizard>("Render cubemap", "Render!");
    }
}

