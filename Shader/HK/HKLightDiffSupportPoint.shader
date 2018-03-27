Shader "Mine/Lighting/HKLightDiffSupportPoint"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}
		SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		Tags{ "LightMode" = "ForwardAdd" }
		LOD 100

		Pass
	{
		CGPROGRAM
#pragma vertex vert
#pragma fragment frag
		// make fog work
#pragma multi_compile_fog

// for UNITY_LIGHT_ATTENUATION
#pragma multi_compile_fwdadd

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "UnityLightingCommon.cginc" // for _LightColor0
#include "AutoLight.cginc"

		struct appdata
	{
		float4 vertex : POSITION;
		float2 uv : TEXCOORD0;
		float3 normal : NORMAL;
	};

	struct v2f
	{
		float2 uv : TEXCOORD0;
		float4 vertex : SV_POSITION;
		float3 normal : TEXCOORD1;
		float3 worldPos : TEXCOORD2;
	};

	sampler2D _MainTex;
	float4 _MainTex_ST;

	v2f vert(appdata v)
	{
		v2f o;
		o.vertex = UnityObjectToClipPos(v.vertex);
		o.uv = TRANSFORM_TEX(v.uv, _MainTex);
		o.normal = UnityObjectToWorldNormal(v.normal);
		o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
		return o;
	}

	fixed4 frag(v2f i) : SV_Target
	{
		fixed3 lightDir = UnityWorldSpaceLightDir(i.worldPos);	
		#ifndef USING_DIRECTIONAL_LIGHT
			float distance = length(lightDir);
			fixed atten = 1.0 / distance; // linear attenuation 
			lightDir = normalize(lightDir);
		#else
			fixed atten = 1;
		#endif
	
		//#ifndef USING_DIRECTIONAL_LIGHT
		//	fixed3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
		//#else
		//	fixed3 lightDir = _WorldSpaceLightPos0.xyz;
		//#endif
		//UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);


		float nl = dot(i.normal, lightDir) * 0.5 + 0.5;		
		float4 diff = nl * _LightColor0 * atten;

		// sample the texture
		fixed4 col = tex2D(_MainTex, i.uv);

		col *= diff;

		return col;
	}
		ENDCG
	}
	}
}
