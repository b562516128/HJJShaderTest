Shader "Mine/HJJ/AlphaTest"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_CutOff ("Cut Off", Range(0, 1)) = 0.5
	}
	SubShader
	{
		Tags { "Queue"="AlphaTest" "RenderType"="Opaque" "LightMode" = "ForwardBase"}
		LOD 100

		Pass
		{
			Cull Off
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
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				fixed  nl : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed _CutOff;
			
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
				clip(col.a - _CutOff);

				fixed3 diffuse = col.rgb * _LightColor0.rgb * i.nl;

				return fixed4(diffuse, 1.0);
			}
			ENDCG
		}
	}
}
