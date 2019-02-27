Shader "Mine/HJJ/Bloom"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_BloomTex ("BloomTexture", 2D) = "white" {}
		_threshold ("threshold", float) = 0.5
	}
	SubShader
	{
		CGINCLUDE
		
			#include "UnityCG.cginc"
			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv[5] : TEXCOORD0;
				float4 vertex : SV_POSITION;

			};

			struct v2f_extract
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;

			};

			sampler2D _MainTex;
			sampler2D _BloomTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			float _threshold;

			v2f vertHorizontal (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv[0] = v.uv + _MainTex_TexelSize.xy * half2(-2, -0);
				o.uv[1] = v.uv + _MainTex_TexelSize.xy * half2(-1, 0);
				o.uv[2] = v.uv ;
				o.uv[3] = v.uv + _MainTex_TexelSize.xy * half2(1, 0);
				o.uv[4] = v.uv + _MainTex_TexelSize.xy * half2(2, 0);

				return o;
			}

			v2f vertVertical (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv[0] = v.uv + _MainTex_TexelSize.xy * half2(0, -2);
				o.uv[1] = v.uv + _MainTex_TexelSize.xy * half2(0, -1);
				o.uv[2] = v.uv;
				o.uv[3] = v.uv + _MainTex_TexelSize.xy * half2(0, 1);
				o.uv[4] = v.uv + _MainTex_TexelSize.xy * half2(0, 2);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float weight[3] = {0.4026, 0.2442, 0.0545};
				fixed4 col = fixed4(0, 0, 0, 1);
				for(int idx = 0; idx < 5; idx ++)
				{
					col.rgb += weight[abs(idx - 2)] * tex2D(_MainTex, i.uv[idx]);
				}
				return col;
			}

			v2f_extract vertNormal (appdata v)
			{
				v2f_extract o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				o.uv = v.uv;

				return o;
			}

			float luminance(fixed4 color)
			{
				return color.r * 0.2125 + color.g * 0.7154 + color.b*0.0721;
			}
			
			fixed4 frag_extract (v2f_extract i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) ;
				float val =  clamp(luminance(col) - _threshold, 0.0, 1.0);

				return col * val;
			}
			fixed4 frag_bloom (v2f_extract i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) + tex2D(_BloomTex, i.uv) ;
				//fixed4 col = tex2D(_BloomTex, i.uv) ;

				return col;
			}

		ENDCG

		Pass
		{
			NAME "BLOOM_EXTRACT_BRIGHT"

			CGPROGRAM
			#pragma vertex vertNormal
			#pragma fragment frag_extract

			ENDCG
		}

		Pass
		{
			NAME "BLOOM_BLOOM_HORIZONTAL"

			CGPROGRAM
			#pragma vertex vertHorizontal
			#pragma fragment frag

			ENDCG
		}

		Pass
		{
			NAME "BLOOM_BLOOM_VERTICAL"

			CGPROGRAM
			#pragma vertex vertVertical
			#pragma fragment frag

			ENDCG
		}

		Pass
		{
			NAME "BLOOM_BLOOM"

			CGPROGRAM
			#pragma vertex vertNormal
			#pragma fragment frag_bloom

			ENDCG
		}
	}
}
