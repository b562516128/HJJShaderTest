Shader "Mine/HJJ/waterFlow"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Magnitude("Magnitude", float) = 0.04
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "Queue"="Transparent"}
		LOD 100

		Pass
		{
			Tags { "LightMode"="ForwardBase"}
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
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

			float _Magnitude;
			
			v2f vert (appdata v)
			{
				v2f o;
				float4 offset = float4(0.0, 0.0, 0.0, 0.0);

				
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);

			//	offset.x = sin((_Time.y * 3 + v.vertex.z * 5 + v.vertex.x * 5 + v.vertex.y * 5)) * _Magnitude;
				offset.x = sin((_Time.y + v.uv.y * 5) * 10) * _Magnitude;
				o.vertex = UnityObjectToClipPos(v.vertex + offset);

				o.uv.y += _Time.y * 0.5;
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
		
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
				return col;
			}
			ENDCG
		}
	}
}
