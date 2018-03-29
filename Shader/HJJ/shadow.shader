Shader "Mine/Lighting/shadow"
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
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
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
				float4 pos : SV_POSITION;
				float3  diff : TEXCOORD1;
				float3  ambient : COLOR0;
				SHADOW_COORDS(2)
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
				fixed nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz)); //dot(worldNormal, _WorldSpaceLightPos0.xyz) * 0.5 + 0.5;
				o.diff = nl * _LightColor0.rgb;

				o.ambient = ShadeSH9(fixed4(worldNormal, 1));

				TRANSFER_SHADOW(o)

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed shadow = SHADOW_ATTENUATION(i);

				fixed3 lighting = i.diff * shadow + i.ambient;
				col.rgb = col.rgb * lighting;

				return col;
			}
			ENDCG
		}

		Pass
		{
			Tags{ "LightMode" = "ShadowCaster" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
			struct v2f {
				V2F_SHADOW_CASTER;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
	}
}
