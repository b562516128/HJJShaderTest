using UnityEngine;
using System.Collections;

public class HJJMotionBlur : PostEffectsBase
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

    private RenderTexture accumulateTex = null;

    [Range(0.0f, 0.9f)]
    public float blurAmount = 0.5f;

    // 采样精细度
    [Range(1, 8)]
    public int downSample = 1;

    //[Range(0.0f, 3.0f)]
    //public float saturation = 1.0f;

    //[Range(0.0f, 3.0f)]
    //public float contrast = 1.0f;

    void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        if (material == null) return;

        int rtW = src.width;
        int rtH = src.height;

        if (accumulateTex == null)
        {
            accumulateTex = RenderTexture.GetTemporary(rtW, rtH, 0);
            accumulateTex.hideFlags = HideFlags.HideAndDontSave;
            Graphics.Blit(src, accumulateTex);
        }

        accumulateTex.MarkRestoreExpected();

        material.SetFloat("_BlurAmount", 1 - blurAmount);
        Graphics.Blit(src, accumulateTex, material);
        Graphics.Blit(accumulateTex, dest);
    }

    private void OnDestroy()
    {
        RenderTexture.DestroyImmediate(accumulateTex);
    }
}
