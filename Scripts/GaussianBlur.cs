using UnityEngine;
using System.Collections;

public class GaussianBlur : PostEffectsBase
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

    [Range(1, 10)]
    public int renderTimes = 1;

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

        int rtW = src.width / downSample;
        int rtH = src.height / downSample;
        RenderTexture buffer0 = RenderTexture.GetTemporary(rtW, rtH, 0);
        Graphics.Blit(src, buffer0);
        for (int i = 0; i < renderTimes; i++)
        {
            RenderTexture buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
            Graphics.Blit(buffer0, buffer1, material, 0);
            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;

            buffer1 = RenderTexture.GetTemporary(rtW, rtH, 0);
            Graphics.Blit(buffer0, buffer1, material, 1);
            RenderTexture.ReleaseTemporary(buffer0);
            buffer0 = buffer1;
        }

        Graphics.Blit(buffer0, dest);
        RenderTexture.ReleaseTemporary(buffer0);
    }
}
