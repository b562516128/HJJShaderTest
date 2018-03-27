// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Mine/Lighting/HJJSpecular"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Power("specularPower", Range(0, 100)) = 1
		_specularColor("specularColor", Color) = (1, 1, 1, 1)
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
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
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float3 spec : TEXCOORD1;
				float3 normal : TEXCOORD2;
				float4 worldPos : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Power;
			float3 _specularColor;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = v.normal;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float3 worldNormal = normalize(mul(i.normal, unity_WorldToObject));
				float4 worldPos = i.worldPos;

#ifdef USING_DIRECTIONAL_LIGHT
				float3 _lightDir = _WorldSpaceLightPos0.xyz;
				float  atten = 1.0;
#else
				float3 dectT = _WorldSpaceLightPos0.xyz - worldPos.xyz;
				float3 _lightDir = normalize(dectT);
				float dis = length(dectT);
				float  atten = 1.0 / (dis * dis);
#endif

				float3 refl = reflect(_lightDir, worldNormal);
				float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos.xyz);

				float3 spec = float3(0.0, 0.0, 0.0);
				if (dot(worldNormal, _lightDir) < 0.0)
					// light source on the wrong side?
				{
					spec = float3(0.0, 0.0, 0.0);
					// no specular reflection
				}
				else // light source on the right side
				{
					spec = max(0, dot(refl, viewDir));
					spec = pow(spec, _Power) * _LightColor0.rgb * atten;
				}

				float3 diff = (dot(worldNormal, _lightDir) + 1) * 0.5 *  _LightColor0.rgb * atten;

				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				col.rgb = diff * col.rgb * 0.5 +_specularColor.rgb *  spec * 2;
				return col;
			}
			ENDCG
		}

			Pass
			{
				Tags{ "LightMode" = "ForwardADD" }
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
				float3 spec : TEXCOORD1;
				float3 normal : TEXCOORD2;
				float4 worldPos : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _Power;
			float3 _specularColor;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = v.normal;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 worldNormal = normalize(mul(i.normal, unity_WorldToObject));
				float4 worldPos = i.worldPos;

#ifdef USING_DIRECTIONAL_LIGHT
				float3 _lightDir = _WorldSpaceLightPos0.xyz;
				float  atten = 1.0;
#else
				float3 dectT = _WorldSpaceLightPos0.xyz - worldPos.xyz;
				float3 _lightDir = normalize(dectT);
				float dis = length(dectT);
				float  atten = 1.0 / (dis * dis);
#endif

				float3 refl = reflect(_lightDir, worldNormal);
				float3 viewDir = normalize(_WorldSpaceCameraPos - worldPos.xyz);

				float3 spec = float3(0.0, 0.0, 0.0);
				if (dot(worldNormal, _lightDir) < 0.0)
					// light source on the wrong side?
				{
					spec = float3(0.0, 0.0, 0.0);
					// no specular reflection
				}
				else // light source on the right side
				{
					spec = max(0, dot(refl, viewDir));
					spec = pow(spec, _Power) * _LightColor0.rgb * atten;
				}

				float3 diff = (dot(worldNormal, _lightDir) + 1) * 0.5 *  _LightColor0.rgb * atten;

				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);

				col.rgb = diff * col.rgb * 0.5 + _specularColor.rgb *  spec * 2;
				return col;
			}
				ENDCG
			}
	}
}
