using UnityEngine;
using System.Collections;

public class EdgeDetectNormalDepth : PostEffectsBase
{
    public Shader briSatConShader;
    private Material briSatConMaterial;
    public Material material
    {
        get
        {
            briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
            return briSatConMaterial;
        }
    }

    [Range(0.0f, 0.9f)]
    public float blurAmount = 0.5f;

    // 采样精细度
    [Range(1, 8)]
    public int downSample = 1;

    //[Range(0.0f, 3.0f)]
    //public float saturation = 1.0f;

    //[Range(0.0f, 3.0f)]
    //public float contrast = 1.0f;

    private void OnEnable()
    {
        GetComponent<Camera>().depthTextureMode |= DepthTextureMode.DepthNormals;
    }
    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material == null) return;

        Graphics.Blit(src, dest, material);
    }
}
