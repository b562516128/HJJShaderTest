Shader "Mine/HJJ/lerpTexture"
{
	Properties
	{
		_Texture1 ("_Texture1", 2D) = "white" {}
		_Texture2 ("_Texture2", 2D) = "white" {}
		_LerpNum ("_Lerp", Range(0, 1)) = 0.5
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
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			sampler2D _Texture1;
			sampler2D _Texture2;
			float4 _Texture1_ST;
			float4 _Texture2_ST;

			float _LerpNum;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv1 = TRANSFORM_TEX(v.uv, _Texture1);
				o.uv2 = TRANSFORM_TEX(v.uv, _Texture2);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = lerp(tex2D(_Texture1, i.uv1), tex2D(_Texture2, i.uv2), _LerpNum);

				return col;
			}
			ENDCG
		}
	}
}
