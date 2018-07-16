Shader "Mine/HJJ/AlphaBlend"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_AlphaScale("Alpha Scale", Range(0, 1)) = 0.8
	}
	SubShader
	{
		Tags { "Queue"="Transparent" "RenderType"="Transparent" "LightMode" = "ForwardBase"}


		// Extra pass that renders to depth buffer only
		Pass {
			ZWrite On
			ColorMask 0
		}

		Pass
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			// make fog work
			#pragma multi_compile_fog
			
			#include "UnityCG.cginc"
			#include "UnityLightingCommon.cginc" // for _LightColor0

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				fixed3 normal : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				fixed nl : TEXCOORD1; 
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed  _AlphaScale;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);

				o.nl = dot(worldNormal, _WorldSpaceLightPos0.xyz) * 0.5 + 0.5;



				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				
				fixed3 diffuse = col.rgb * _LightColor0.rgb * i.nl;

				return fixed4(diffuse, col.a * _AlphaScale);
			}
			ENDCG
		}
	}
}
