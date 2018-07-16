Shader "Mine/HJJ/FlowMap"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_FlowMap ("Texture", 2D) = "black" {}
	}
	SubShader
	{
		Tags {"RenderType"="Opaque" }
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
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			sampler2D _FlowMap;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 colmap = tex2D(_FlowMap, i.uv);

				float time1 = frac(_Time.y);
				float deltX1 =  frac(colmap.r * time1) * 0.1;
				float deltY1 =  frac(colmap.g * time1)* 0.1;
				
				float time2 = frac(_Time.y + 0.5);
				float deltX2 =  frac(colmap.r * time2)* 0.1;
				float deltY2 =  frac(colmap.g * time2)* 0.1;

				float blend = abs(frac(_Time.y) - 0.5) * 2;

				 
				fixed4 col = lerp(tex2D(_MainTex, float2(i.uv.x + deltX1, i.uv.y + deltY1 )), tex2D(_MainTex, float2(i.uv.x + deltX2, i.uv.y + deltY2 )), blend);

				return col;
			}
			ENDCG
		}
	}
}
