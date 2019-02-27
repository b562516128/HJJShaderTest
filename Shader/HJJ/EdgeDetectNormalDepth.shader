Shader "Mine/HJJ/EdgeDetectNormalDepth"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
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
			sampler2D _CameraDepthNormalsTexture;
			half4 _MainTex_TexelSize;

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);

				half2 uv = v.uv;

				#if UNITY_UV_STARTS_AT_TOP
				 if(_MainTex_TexelSize.y < 0)
					uv.y = 1 - uv.y;
				#endif
				
				half distance = 1;

				o.uv[0] = uv ;
				o.uv[1] = uv + _MainTex_TexelSize.xy * half2(-1, -1) * distance;
				o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, 1) * distance;
				o.uv[3] = uv + _MainTex_TexelSize.xy * half2(1, -1) * distance;
				o.uv[4] = uv + _MainTex_TexelSize.xy * half2(-1, 1) * distance;

				return o;
			}

			fixed checkSame(half4 sample1, half4 sample2)
			{
				half2 normal1 = sample1.xy;
				half2 normal2 = sample2.xy;
				half2 deltNormal = abs(normal1 - normal2);

				half sameNormal = 0;
				if((deltNormal.x + deltNormal.y) < 0.1)
					sameNormal = 1;

				//float DecodeFloatRGBA (float4 enc) - decodes RGBA color into a float. 
				//Similarly, float2 EncodeFloatRG (float v) and float DecodeFloatRG (float2 enc) that use two color channels. 
				float depth1 = DecodeFloatRG( sample1.zw);
				float depth2 = DecodeFloatRG(sample2.zw);
				float deltDepth = abs(depth1 - depth2);

				fixed sameDepth = deltDepth < 0.1 * depth1 ? 1 : 0;
				
				return sameDepth * sameNormal;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				half4 sample1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
				half4 sample2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
				half4 sample3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
				half4 sample4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);

				half edge = 1.0;

				edge *= checkSame(sample1, sample2);
				edge *= checkSame(sample3, sample4);

				return lerp(fixed4(0, 0, 0, 1), tex2D(_MainTex, i.uv[0]), edge);
			}

			ENDCG
		}
	}
}
