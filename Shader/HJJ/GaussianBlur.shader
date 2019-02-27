Shader "Mine/HJJ/GaussianBlur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
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

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;

			v2f vertHorizontal (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);


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
				UNITY_TRANSFER_FOG(o,o.vertex);


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
					col.rgb += tex2D(_MainTex, i.uv[idx]).rgb * weight[abs(idx - 2)];
				}

				return col;
			}

		ENDCG

		Pass
		{
			NAME "GAUSSIAN_BLUR_HORIZONTAL"

			CGPROGRAM
			#pragma vertex vertHorizontal
			#pragma fragment frag

			ENDCG
		}

		Pass
		{
			NAME "GAUSSIAN_BLUR_VERTICAL"

			CGPROGRAM
			#pragma vertex vertVertical
			#pragma fragment frag

			ENDCG
		}
	}
}
