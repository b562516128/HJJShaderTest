Shader "Mine/Unlit/ReflCubeSample"
{
	Properties
	{
		
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 worldRefl : TEXCOORD0;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 worldViewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos);
				o.worldRefl = reflect(-worldViewDir, worldNormal);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, i.worldRefl);
				half3 skyColor = DecodeHDR(col, unity_SpecCube0_HDR);
				col.rgb = skyColor;
				return col;
			}
			ENDCG
		}
	}
}
