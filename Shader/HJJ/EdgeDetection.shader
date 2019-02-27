Shader "Mine/HJJ/EdgeDetection"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Div ("Div", float) = 5.0
		_Brightness ("Brightness", float) = 1.0
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
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv[9] : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;

			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			float _Div;
			float _Brightness;

			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				UNITY_TRANSFER_FOG(o,o.vertex);


				o.uv[0] = v.uv + _MainTex_TexelSize.xy * half2(-1, -1);
				o.uv[1] = v.uv + _MainTex_TexelSize.xy * half2(0, -1);
				o.uv[2] = v.uv + _MainTex_TexelSize.xy * half2(1, -1);
				o.uv[3] = v.uv + _MainTex_TexelSize.xy * half2(-1, 0);
				o.uv[4] = v.uv + _MainTex_TexelSize.xy * half2(0, 0);
				o.uv[5] = v.uv + _MainTex_TexelSize.xy * half2(1, 0);
				o.uv[6] = v.uv + _MainTex_TexelSize.xy * half2(-1, 1);
				o.uv[7] = v.uv + _MainTex_TexelSize.xy * half2(0, 1);
				o.uv[8] = v.uv + _MainTex_TexelSize.xy * half2(1, 1);

				return o;
			}

			half luminance(fixed4 col){
				return 0.2125 * col.r + 0.7154 * col.g + 0.0721 * col.b;
			}

			half Sobel(v2f i){
				half Gx[9] = {
					-1, 0, 1,
					-2, 0, 2,
					-1, 0, 1
				} ;

				half Gy[9] = {
						-1, -2, -1,
						0, 0, 0,
						1, 2, 1
					} ;

				half2 edge = half2(0, 0);
				half edgeCol;

				for( int idx = 0; idx < 9; idx ++){
					edgeCol = luminance(tex2D(_MainTex, i.uv[idx]));
					edge.x += edgeCol * Gx[idx];
					edge.y += edgeCol * Gy[idx];
				}

				return abs(edge.x) + abs(edge.y);
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				half sobelEdge = 0;//Sobel(i);
				// sample the texture
				//sobelEdge = sobelEdge <_Div ? 0 : sobelEdge;
				fixed4 col = tex2D(_MainTex, i.uv[4]);
				// apply fog
				//UNITY_APPLY_FOG(i.fogCoord, col);
				return float4(col.r - sobelEdge, col.g - sobelEdge, col.b - sobelEdge, 1) * _Brightness;
			}
			ENDCG
		}
	}
}
