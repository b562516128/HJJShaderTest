Shader "Mine/Lighting/PointLightDiff"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
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
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				fixed4 diff : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float3 worldNormal = UnityObjectToWorldNormal(v.normal);

				float nl = dot(worldNormal, _WorldSpaceLightPos0.xyz) * 0.5 + 0.5;
				o.diff = nl * _LightColor0;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				col *= i.diff;
				return col;
			}
			ENDCG
		}

		Pass
		{
			Tags{ "LightMode" = "ForwardAdd" }
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
				float3 normal: NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				fixed3 diff : TEXCOORD1;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float3 worldNormal = UnityObjectToWorldNormal(v.normal);

				#ifndef USING_DIRECTIONAL_LIGHT
					float4 worldPosition = mul(unity_ObjectToWorld, v.vertex).xyzw;
					float3 deltaVec = _WorldSpaceLightPos0.xyz - worldPosition.xyz;
					float  atten = 1 / length(deltaVec);
					float3 LightDir = normalize(deltaVec);
				#else
					float3 LightDir = _WorldSpaceLightPos0.xyz;
					float  atten = 1;
				#endif


				float nl = dot(worldNormal, LightDir) * 0.5 + 0.5;
				o.diff = nl * _LightColor0.rgb * atten * atten;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

			col.rgb *= i.diff;
			return col;
			}
				ENDCG
		}
	}
}