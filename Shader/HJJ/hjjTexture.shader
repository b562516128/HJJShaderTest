Shader "Mine/util/hjjTexture"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Tex1 ("Texture1", 2D) = "white" {}
		_Slide ("Slide", Range(0, 1)) = 0.5
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
				float2 texcood : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			sampler2D _Tex1;
			float4 _MainTex_ST;
			float4 _Tex1_ST;

			fixed _Slide;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.texcood;
				// o.uv.xy = o.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv = TRANSFORM_TEX(v.texcood, _MainTex);
				o.uv1 = TRANSFORM_TEX(v.texcood, _Tex1);

				//o.uv.y = o.uv.y + _Time.y * 0.1;
				o.uv1.x = o.uv1.x - _Time.y ;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				fixed4 col1 = tex2D(_Tex1, i.uv1);

				//fixed temp = fmod(i.uv.y, 0.2);
				
				//frac()
				//temp = temp > 0.1 ? 1 : 0;
				//col = lerp(col, col1, frac(i.uv.y * 10));
				col += col1;
				/*float3 grey = float3(0.3, 0.59, 0.11);
				col.rgb = dot(col.rgb, grey);*/
				

				
				
				return col;

				//return fixed4(i.uv.x, i.uv.y, 0, 1);
			}
			ENDCG
		}
	}
}
