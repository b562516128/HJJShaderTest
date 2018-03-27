Shader "Mine/Lighting/Reflectiion"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 reflectDir : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				float4 worldPos = mul(unity_ObjectToWorld, o.vertex);
				float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos.xyz);
				float3 worldNormal = UnityObjectToWorldNormal(v.normal); //normalize(mul(v.normal, unity_WorldToObject));
				o.reflectDir = reflect(-viewDir, worldNormal);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col1 = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, i.reflectDir);
				half3 skyColor = DecodeHDR(col1, unity_SpecCube0_HDR);
				col1.rgb = skyColor;
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv) * 0.3 + col1 * 0.7;
				return col;
			}
			ENDCG
		}
	}
}
